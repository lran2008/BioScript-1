#!/usr/bin/perl
use warnings;
use strict;

if (@ARGV != 3){
	printUsage();
}
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
#   Version 1.0 (May 16, 2014): first non-beta release.
##

use File::Basename qw(dirname);
use Cwd qw(abs_path);
#use lib dirname(dirname abs_path $0) . '/perl/lib';
use lib '/BiOfs/BioPeople/brandon/language/perl/lib/';

use Brandon::General qw(say RoundXL);
use Brandon::Bio::BioTools qw(%TOOL $SAMTOOLS $GATK $PICARD_PATH $BWA $VCFTOOLS_PATH $VCFTOOLS_LIB_PATH $BEDTOOLS_PATH $JAVA);
#use Brandon::Bio::BioTools::GATK;

my $MEM_SIZE = "4g"; 

my $REF_FASTA = $ARGV[0];
my $INPUT = $ARGV[1];
my $OUTPUT = $ARGV[2];
my $PARAM = "--minimum_base_quality 0 --minimum_mapping_quality 0 --filtered_distribution";
#BaseCoverageDistribution($REF_FASTA,$INPUT,$OUTPUT,$PARAM);

my $cmd = BaseCoverageDistribution($REF_FASTA,$INPUT,$OUTPUT,$PARAM);
say $cmd;
system($cmd);

sub BaseCoverageDistribution{
	my $program = "BaseCoverageDistribution";
	my $ref = shift; 
	my $input = shift;
	my $output = shift;
	my $param = shift;
	my $command = "$JAVA -Xmx$MEM_SIZE -T $program -R $ref -I $input -o $output $param";

	return $command;
}

sub printUsage{
	print "Usage: perl $0 <reference_fasta> <in.bam> <out>\n";
	exit;
}
