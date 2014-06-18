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
#   Version 1.0 (June 9, 2014): first non-beta release.
##

use File::Basename qw(dirname);
use Cwd qw(abs_path);
#use lib dirname(dirname abs_path $0) . '/perl/lib';
use lib '/BiOfs/BioPeople/brandon/language/perl/lib/';

use Brandon::General qw(say RoundXL);
use Brandon::Bio::BioTools qw(%TOOL $SAMTOOLS $GATK $PICARD_PATH $BWA $VCFTOOLS_PATH $VCFTOOLS_LIB_PATH $BEDTOOLS_PATH $JAVA $qualimap $SNPEFF_PATH);

if (@ARGV !=4){
	printUsage();
}

my $in_vcf = $ARGV[0];
my $out_vcf = $ARGV[1];
my $dbsnp_vcf = $ARGV[2];
my $logfile = $ARGV[3];

my $PWD = dirname(__FILE__);
my $root = abs_path($PWD); 

my $java_path = $JAVA;

my $snpeff_path = $SNPEFF_PATH;
my $snpeff = "$snpeff_path/snpEff.jar";
my $snpeff_config = "$snpeff_path/snpEff.config";
my $snpsift = "$snpeff_path/SnpSift.jar";

#check_snpeff_db($snpeff_config,$genome_version);
#my ($filename,$filepath,$fileext) = fileparse($out_vcf, qr/\.[^.]*/); 

my $snpsift_program = "annotate";
my $command = "$java_path -jar $snpsift $snpsift_program $dbsnp_vcf $in_vcf > $out_vcf 2> $logfile";
print "$command\n";
system($command);

sub check_snpeff_db{
	my $snpeff_confg = shift;
	my $db_name = shift;
	
	my $sc = "cat snpEff.config |  grep \"data_dir =\" | cut -d= -f2";
	my $res = `$sc` or die;
	chomp($res);
	## not work, now developing...
}

sub printUsage{
	print "Usage: perl $0 <in.vcf> <out.vcf> <dbsnp.vcf> <logfile>\n";
	print "Description:  command assumes that both the database and the input VCF files are sorted by position. Chromosome sort order can differ between files.\n";
	exit;
}

