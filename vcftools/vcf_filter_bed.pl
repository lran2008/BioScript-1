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
#   Version 1.0 (Aug 26, 2014): first non-beta release.
##

use File::Basename;
use Cwd qw(abs_path);
use Getopt::Long;

my $VCFTOOLS_PATH;
GetOptions(
    'VCFTOOLS=s' => \$VCFTOOLS_PATH
);

if (!$VCFTOOLS_PATH){
	$VCFTOOLS_PATH = "/BiOfs/hmkim87/BioTools/vcftools/0.1.12a";
}

if (@ARGV != 3){
	printUsage();
}

my $vcf_file = $ARGV[0];
my $bed_file = $ARGV[1];
my $out_file = $ARGV[2];

my $vcftools_bin_path = $VCFTOOLS_PATH."/bin";
my $vcftools = "$vcftools_bin_path/vcftools";

my $out_vcf_name = "$out_file.recode.vcf";
my $command = "$vcftools --vcf $vcf_file --recode --bed $bed_file --out $out_file"; # --gzvcf
system($command);
$command = "mv $out_vcf_name $out_file";
system($command);


sub printUsage{
    print "Usage: perl $0 [-V VCFTOOLS Directory $VCFTOOLS_PATH] <in.vcf> <in.bed> <outvcf_prefix>\n";
    exit;
}
