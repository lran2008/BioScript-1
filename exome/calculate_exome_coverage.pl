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
#   Version 1.0 (June 25,28 2014): first non-beta release.
##

use File::Basename;
use Cwd qw(abs_path);
use lib '/BiOfs/BioPeople/brandon/language/perl/lib/';

use Brandon::Bio::BioTools::PICARD;
use Brandon::Bio::BioPipeline::Queue;

use Getopt::Long;
use XML::Simple;

use Data::Dumper;

use File::Basename; 

my ( $config_file, $debug );
Getopt::Long::Configure("pass_through");
GetOptions(
	'config=s' => \$config_file,
	'debug' => \$debug,
);

if (@ARGV != 3 and !defined $config_file){
	printUsage();
}

if (defined $config_file){
	my $config = XMLin( $config_file, ForceArray => [ 'BAM', ], );
	my $ref_file = $config->{PARAMETERS}->{REFERENCE_FASTA};
	my $bed = $config->{BED};
	foreach (@{$config->{DATA}->{BAM}}){
		my $input_file = $_->{content};
		my $kit_name = $_->{kit_name};
		my $bed_file = $bed->{$kit_name};

		if (!-f $input_file){
			die "ERROR! not found $input_file\n";
		}
		my ($filename,$filepath,$fileext) = fileparse($input_file, qr/\.[^.]*/);
		my $sample_name = $filename;
		if ($sample_name =~ /\.final/){ $sample_name =~ s/\.final//g; } 
		run_PicardHsMetrics($input_file,$ref_file,$bed_file,$sample_name);
	}
}else{
	my $input_file = $ARGV[0];
	my $ref_file = $ARGV[1];
	my $bed_file = $ARGV[2];
	run_PicardHsMetrics($input_file,$ref_file,$bed_file);
}

sub run_PicardHsMetrics{
	my ($input, $ref, $bed, $name) = @_;

	my $output = $input.".CalculateHsMetrics";
	my $per_target = $input.".CalculateHsMetrics.per_target.txt";

	my ($inputname,$inputpath,$inputext) = fileparse($input, qr/\.[^.]*/); 
	my $tmp_dir = $inputpath.$inputname;
	if (!-d $tmp_dir){ system("mkdir -p $tmp_dir"); }

	my $tool_config={
		INPUT => $input,
		OUTPUT => $output,
		REFERENCE_SEQUENCE => $ref,
		PER_TARGET_COVERAGE => $per_target,
		TARGET_INTERVALS => $bed,
		BAIT_INTERVALS => $bed,
		VALIDATION_STRINGENCY => 'LENIENT',
		app => 'CalculateHsMetrics',
		TMP_DIR => $tmp_dir,
	};
	my $hsMetrics = Brandon::Bio::BioTools::PICARD->new($tool_config);
	if (defined $name){
		$hsMetrics->{name} = $name;
	}
	my $hsMetrics_q = Brandon::Bio::BioPipeline::Queue->mini($hsMetrics,$debug);
	$hsMetrics_q->run();
}

sub printUsage{
	print "Usage: perl $0 <in.bam> <in.ref> <in.bed>\n";
	print "Usage2: perl $0 -c config.xml\n";
	exit;
}
