#!/usr/bin/perl
#use warnings;
#use strict;
#
### Program Info:
##
## Name: GATK multi-sample SNP calling
##
## Function: multi-sample SNP calling
##
## Author: Hyunmin Kim
##  Copyright (c) Genome Research Foundation, 2014,
##  all rights reserved.
##
## Licence: This script may be used freely as long as no fee is charged
##    for use, and as long as the author/copyright attributions
##    are not removed.
##
## History:
##   Version 1.0 (June 24, 2014): first non-beta release.
###
#
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib '/BiOfs/BioPeople/brandon/language/perl/lib/';

use Brandon::Bio::BioTools qw($GATK);
use Brandon::Bio::BioPipeline::Project;
use Brandon::Bio::BioPipeline::ProcessData;
use Brandon::Bio::BioTools::GATK;
use Brandon::Bio::BioPipeline::Queue;

use Data::Dumper;

use XML::Simple;
use Getopt::Long;

###### get arguments      ###
my ( $config_file, $debug, $params_file );
Getopt::Long::Configure("pass_through"); #If pass_through is also enabled, options processing will terminate at the first unrecognized option, or non-option, whichever comes first.
GetOptions(
	'config=s' => \$config_file,
	'debug' => \$debug,
	'params=s' => \$params_file,
);

if ( scalar @ARGV ) {
	warn "Unknown options:", Dumper \@ARGV, "\n";
	exit 0;
}

####### general parameters ###
my $config = XMLin( "$config_file", ForceArray => [ 'BAM', ], );
#print Dumper $config;
my $params = XMLin( $params_file );
for my $param ( keys %{ $params->{PARAMETERS} } ) {
	$config->{PARAMETERS}->{$param} = $params->{PARAMETERS}->{$param}
	unless exists $config->{PARAMETERS}->{$param};
}

my $project = Brandon::Bio::BioPipeline::Project->new( $config, $debug );

$project->make_folder_structure();

my $data = Brandon::Bio::BioPipeline::ProcessData->new($project->{DATA});

my $out_path = $project->set_outdir( $project->{CONFIG}->{SAMPLE_NAME} );
my $outfile = $out_path."/".$project->{CONFIG}->{SAMPLE_NAME}.".vcf";

my $ug_config = {
	input_file => $data->{data},
	output => $outfile,
	reference_sequence => $project->{CONFIG}->{GENOME},
	app => "UnifiedGenotyper",
	dbsnp => $project->{CONFIG}->{DBSNP},
	param => $project->{CONFIG}->{GATK}->{UnifiedGenotyper}->{param},
	intervals => $project->{CONFIG}->{SAMPLE_NAME},
	java => $project->{CONFIG}->{JAVA},
	java_opts => "-Xmx8g -jar",
	gatk => $project->{CONFIG}->{GATK}->{program},
};
my $ug_multi = Brandon::Bio::BioTools::GATK->new($ug_config);

my $jobname = $project->{CONFIG}->{SAMPLE_NAME};
my $script_path = $project->set_scriptdir( $project->{CONFIG}->{SAMPLE_NAME} );
my $script_file = $script_path."/".$project->{CONFIG}->{SAMPLE_NAME}.".sh";
my $log_path = $project->set_errdir( $project->{CONFIG}->{SAMPLE_NAME} );
my $log_file = $log_path."/".$project->{CONFIG}->{SAMPLE_NAME}.".log";
my $q_config = {
	command => $ug_multi->{command},
	name => $jobname,
	script_file => $script_file,
	log_file => $log_file,
	err_file => undef,
	hold_jid => undef,
	slot_range => 4, # cpus
};

my $job_ug_multi = Brandon::Bio::BioPipeline::Queue->new( $q_config, $debug);
$job_ug_multi->make;
$job_ug_multi->run;
