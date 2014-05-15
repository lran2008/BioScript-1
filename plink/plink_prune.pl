#!/usr/bin/perl
use warnings;
use strict;

## Program Info:
#
# Name:  
#
# Function: prune SNP with plink
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
#   Version 1.0 (August 1, 2002): first non-beta release.
##

my $inprefix = $ARGV[0];

my $plink = "/BiOfs/hmkim87/BioTools/plink/1.07/plink";

#step1
my $window_size_in_SNPs = 50;
my $num_SNPs_to_shift_the_window = 5;
my $VIF_threshold = 2;
my $prune_param = "--indep $window_size_in_SNPs $num_SNPs_to_shift_the_window $VIF_threshold";
my $prune_in = $inprefix;

my $cmd_prune = plink_prune($prune_in,$prune_param);
print $cmd_prune."\n";

#step2
my $r_2_threshold = 0.5;
$prune_param = "--indep-pairwise $window_size_in_SNPs $num_SNPs_to_shift_the_window $r_2_threshold"; 
$cmd_prune = plink_prune($prune_in,$prune_param);
print $cmd_prune."\n";

# get pruned ped file
#plink --file data --extract plink.prune.in --make-bed --out pruneddata
my $out_prefix = "plink_test_out";
$prune_param = "--extract plink.prune.in --out $out_prefix --recode";
$cmd_prune = plink_prune($prune_in,$prune_param);
print $cmd_prune."\n";


sub plink_prune{
	my $plink_in = shift;
	my $plink_param = shift;
	my $command = "$plink --file $plink_in $plink_param --noweb";
	return $command;
}
