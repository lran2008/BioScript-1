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
#   Version 1.0 (July 23, 2014): first non-beta release.
##

use File::Basename;
use Cwd qw(abs_path);
use lib '/BiOfs/BioPeople/brandon/language/perl/lib/';

use Brandon::Bio::BioTools qw($SAMTOOLS $BCFTOOLS);
use Data::Dumper;

if (@ARGV != 3){
	printUsage();
}
my $in_ref = $ARGV[0];
my $in_bam = $ARGV[1];
my $out_vcf = $ARGV[2];

my $cmd = samtools_bam_to_vcf($in_ref,$in_bam,$out_vcf);
print $cmd."\n";

sub samtools_bam_to_vcf{
	my $ref = shift;
	my $bam = shift;
	my $vcf = shift;
	my $command = "$SAMTOOLS mpileup -uf $ref $bam | $BCFTOOLS view -vcg - > $vcf";
	return $command;
}

sub printUsage{
	print "Usage: perl $0 <ref.fa> <in.bam> <out.vcf>\n";
	exit;
}
