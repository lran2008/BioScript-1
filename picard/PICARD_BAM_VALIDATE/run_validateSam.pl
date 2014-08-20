#!/usr/bin/perl
use warnings;
use strict;

## Program Info:
#
# Name: Untitled
#
# Function: GATK BAM Processing + UnifiedGenotyper
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
#   Version 1.0 (Aug 19, 2014): first non-beta release.
##

use File::Basename;
use Cwd qw(abs_path);
use lib (dirname abs_path $0) . '/lib';

use PICARD;
use Queue;

use Data::Dumper;

if (@ARGV != 2){
	printUsage();
}
#input
my $in_bam_pattern = $ARGV[0];
my @bam_files = glob($in_bam_pattern);

my $script_path = $ARGV[1];
if (!-d $script_path){
	die "ERROR ! check your script path\n";
}

my $debug;

#tool
my $picard_path = "/BiOfs/shsong/BioTools/picard-tools-1.92";
foreach my $bam_file (@bam_files){

	my ($filename,$filepath,$fileext) = fileparse($bam_file, qr/\.[^.]*/);

	my $out_report = "$bam_file.validate";
	my $config_ValidateSamFile={
		JAVA => "java",
		PICARD_PATH => $picard_path,
		app => "ValidateSamFile",
		INPUT => $bam_file,
		OUTPUT => $out_report,
	};

	my $validate = PICARD->new($config_ValidateSamFile);

	my $q_config = {
		name => "validate_$filename",
		command => $validate->{command},
		script => "$script_path/$filename.sh",
		stdout => "$script_path/$filename.log"
	};
	my $job = Queue->new($q_config,$debug);
	$job->make();
	$job->run();
}

sub printUsage{
	print "Usage: perl $0 <\"in*.bam\"> <qsub log temp path>\n";
	exit;
}
