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
#   Version 1.0 (June 2, 2014): first non-beta release.
##

use File::Basename;
use Cwd qw(abs_path);
#use lib dirname(dirname abs_path $0) . '/perl/lib';
use lib '/BiOfs/BioPeople/brandon/language/perl/lib/';

use Brandon::General qw(say RoundXL);
use Brandon::Bio::BioTools qw(%TOOL $SAMTOOLS $GATK $PICARD_PATH $BWA $VCFTOOLS_PATH $VCFTOOLS_LIB_PATH $BEDTOOLS_PATH $JAVA $qualimap $SNPEFF_PATH);

if (@ARGV !=4){
	printUsage();
}

my $in_vcf = $ARGV[0];
my $genome_version = $ARGV[1];
my $out_vcf = $ARGV[2];
my $out_log = $ARGV[3];

my $snpeff = "$SNPEFF_PATH/snpEff.jar";
my $snpeff_config = "$SNPEFF_PATH/snpEff.config";


my ($filename,$filepath,$fileext) = fileparse($out_vcf, qr/\.[^.]*/); 
my $snpeff_option;
if ($genome_version eq "GRCh37.71"){
	$snpeff_option = "-motif -nextprot -s $filepath$filename.csv -csvStats";
}else{
	$snpeff_option = "-s $filepath$filename.csv -csvStats";
}	

my $snpeff_param = $snpeff_option;
my $snpeff_genome_version = $genome_version;
my $snpeff_infile = $in_vcf;
my $snpeff_outfile = $out_vcf;
my $snpeff_logfile = $out_log;
my $cmd = snpeff_eff($snpeff_param,$snpeff_genome_version,$snpeff_infile,$snpeff_outfile,$snpeff_logfile);

print "$cmd\n";
system($cmd);

sub snpeff_eff{
	my $param = shift;
	my $genome_version = shift;
	my $infile = shift;
	my $outfile = shift;
	my $logfile = shift;
	my $command = "$JAVA -jar $snpeff eff -c $snpeff_config $param $genome_version $infile > $outfile 2> $logfile";
	return $command;
}

sub printUsage{
	print "Usage: perl $0 <in.vcf> <snpeff_dbname> <out_snpeff.vcf> <logfile>\n";
	print "Example: perl $0 in.vcf hg19 out_snpeff.vcf out_snpeff.log\n";
	exit;
}

