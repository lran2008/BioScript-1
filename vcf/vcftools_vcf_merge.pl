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
#   Version 1.0 (June 19, 2014): vcftools 0.1.12a
##

use File::Basename qw(dirname);
use Cwd qw(abs_path);
#use lib dirname(dirname abs_path $0) . '/perl/lib';
use lib '/BiOfs/BioPeople/brandon/language/perl/lib/';

use Brandon::General qw(say RoundXL);
use Brandon::Bio::BioTools qw($SAMTOOLS $GATK $PICARD_PATH $BWA $VCFTOOLS_PATH $VCFTOOLS_LIB_PATH $BEDTOOLS_PATH $JAVA $qualimap $SNPEFF_PATH $VCFLIB_PATH $FASTQC);

my $PWD = dirname(__FILE__);
my $root = abs_path($PWD);  

if (@ARGV != 2){
	printUsage();
}

my $INPUT_S = $ARGV[0];
my $VCF_OUT = $ARGV[1];

my $PATH_tabix = "/BiOfs/hmkim87/BioTools/tabix/0.2.6";
my $bgzip = $PATH_tabix."/bgzip";
my $tabix = $PATH_tabix."/tabix";

my $LIB_vcftools = $VCFTOOLS_LIB_PATH;
my $PATH_vcftools = $VCFTOOLS_PATH;
my $merge = $PATH_vcftools."/vcf-merge";

$ENV{'PATH'}.= ":".$PATH_tabix;
#print "export PATH=$PATH_tabix:\$PATH\n";

my @FILES = glob($INPUT_S);
for (my $i=0; $i<@FILES; $i++){
	if ($FILES[$i] =~ /\.gz$/){
		next;	
	}
	my $command = "$bgzip -c $FILES[$i] > $FILES[$i].gz";
	if (!-f "$FILES[$i].gz"){
		print STDERR "$command\n";
		system($command);
	}
	if (!-f "$FILES[$i].gz.tbi"){
		$command = "$tabix -p vcf $FILES[$i].gz";
		print STDERR "$command\n";
		system($command);
	}
	$FILES[$i] = $FILES[$i].".gz";
}

my $infiles = "";
$infiles .= "$_ " foreach @FILES;

my $sc = "perl -I $LIB_vcftools $merge $infiles | $bgzip -c > $VCF_OUT";
print STDERR "$sc\n";
system($sc);

sub printUsage{
	print "Usage: perl $0 <\"PATH/*.vcf\"> <out.vcf.gz>\n";
	exit;
}

