#!/usr/bin/perl
use warnings;
use strict;

## Program Info:
#
# Name:
#
# Function:
#
# Author: Hyunmin Kim
#  Copyright (c) Genome Research Foundation, 2014,
#  all rights reserved.
#
# Licence: This script may be used freely as long as no fee is charged
#    for use, and as long as the author/copyright attributions
#    are not removed.
#
# History:
#   Version 1.0 (June 28, 2014): just one vcf file processing
#   Version 1.1 (June 30, 2014): multi vcf file pattern processing
# Update (required)
#   - set the cpu param in qsub (because, If you analysis the chr3 with WGS 66 sample, require about 10 cpu)
##

use File::Basename;
use Cwd qw(abs_path);
use lib '/BiOfs/BioPeople/brandon/language/perl/lib/';

use Brandon::Bio::BioTools qw($GATK);
use Brandon::Bio::BioTools::GATK;
use Brandon::Bio::BioPipeline::Queue;
use Brandon::Bio::BioPipeline::ProcessData;

use Data::Dumper;

use Getopt::Long;
use XML::Simple;

###### get arguments      ###
my ( $config_file, $debug );
Getopt::Long::Configure("pass_through");
GetOptions(
	'config=s' => \$config_file,
	'debug' => \$debug,
);

if ( scalar @ARGV ) {
        warn "Unknown options:", Dumper \@ARGV, "\n";
        exit 0;
}

####### general parameters ###
my $config = XMLin( "$config_file");

my $ref_fasta = $config->{REF_FASTA};

my $set = Brandon::Bio::BioPipeline::ProcessData->new($config->{DATA});

foreach my $vcf_pattern ( @{$set->{data}->{VCFs}} ){
	my @input_vcf = glob($vcf_pattern);
	checkFiles(\@input_vcf);
	my $param = $config->{GATK_CombineVariants_PARAM};
	my $outdir = $config->{PARAMETERS}->{PROJECT_DIR};

	my $chrName = (split /\./, $vcf_pattern)[-2];
	my $outfile = $outdir."/".$chrName.".vcf";

	my $gatk_config = {
		input_file => \@input_vcf,
		output => $outfile,
		reference_sequence => $ref_fasta,
		app => "CombineVariants",
		param => $param,	
		java_opts => "-Xmx24g -jar",
	};
	my $combine_vcf = Brandon::Bio::BioTools::GATK->new($gatk_config);

	#$combine_vcf->{name} = $chrName;

	my $q_config ={
		command => $combine_vcf->{command},
		name => $chrName,
		slot_range => 10,
		depend_name => undef,
	};
	my $job_combine_vcf = Brandon::Bio::BioPipeline::Queue->mini($q_config,$debug);
	$job_combine_vcf->make();
	$job_combine_vcf->run();
}

sub checkFiles{
	my $input_ref = shift;

	foreach (@{$input_ref}){
		if (!-f $_){
			die "ERROR! not found $_\n";
		}
	}
}

=pod
 java -Xmx2g -jar GenomeAnalysisTK.jar \
   -R ref.fasta \
   -T CombineVariants \
   --variant input1.vcf \
   --variant input2.vcf \
   -o output.vcf \
   -genotypeMergeOptions UNIQUIFY

 java -Xmx2g -jar GenomeAnalysisTK.jar \
   -R ref.fasta \
   -T CombineVariants \
   --variant:foo input1.vcf \
   --variant:bar input2.vcf \
   -o output.vcf \
   -genotypeMergeOptions PRIORITIZE
   -priority foo,bar
=cut


