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
#   Version 1.0 (June 13, 2014): first non-beta release.
##

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib '/BiOfs/BioPeople/brandon/language/perl/lib/';

use Brandon::Bio::BioTools qw($VCFTOOLS_PATH $VCFTOOLS_LIB_PATH);

if (@ARGV != 2){
	printUsage();
}
my $in_vcf = $ARGV[0];
my $out_prefix = $ARGV[1];

my $vcftools = "$VCFTOOLS_PATH/vcftools";
my $cmd_vcf2plink = vcf2plink($in_vcf,$out_prefix);
print $cmd_vcf2plink."\n";
system($cmd_vcf2plink);

sub vcf2plink{
	my $infile = $_[0];
	my $prefix_output = $_[1];

	my $command = "$vcftools --vcf $infile --plink --out $prefix_output";
	return $command;
}

sub printUsage{
	print "Usage: perl $0 <in.vcf> <out_prefix>\n";
	exit;
}
