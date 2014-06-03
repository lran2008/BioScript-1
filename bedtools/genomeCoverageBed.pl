#!/usr/bin/perl
use warnings;
use strict;

## Program Info:
#
# Name: BEDTOOLS genomeCoverageBed 
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
#   Version 1.0 (May 29, 2014): first non-beta release.
##

use File::Basename qw(dirname);
use Cwd qw(abs_path);
#use lib dirname(dirname abs_path $0) . '/../../BioPeople/brandon/language/perl/lib';
use lib '/BiOfs/BioPeople/brandon/language/perl/lib';

use Brandon::General qw(say RoundXL);
use Brandon::Bio::BioTools qw(%TOOL $SAMTOOLS $GATK $PICARD_PATH $BWA $VCFTOOLS_PATH $VCFTOOLS_LIB_PATH $BEDTOOLS_PATH);

if (@ARGV != 3){
	printUsage();
}
my $input_bam = $ARGV[0];
my $genome = $ARGV[1];
my $out = $ARGV[2];

my $genomeCoverageBed = $BEDTOOLS_PATH."/genomeCoverageBed";

my $command = "$genomeCoverageBed -ibam $input_bam -g $genome > $out";
say $command;
system($command);

sub printUsage{
	print "perl $0 <in.bam> <genome> <outfile>\n";
	print "<genome> -> fai\n";
	exit;
}
