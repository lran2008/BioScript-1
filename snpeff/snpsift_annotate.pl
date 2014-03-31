#!/usr/bin/perl -w

use strict;
use File::Basename;
use Cwd 'abs_path';

if (@ARGV !=4){
	printUsage();
}

my $in_vcf = $ARGV[0];
my $out_vcf = $ARGV[1];
my $dbsnp_vcf = $ARGV[2];
my $logfile = $ARGV[3];

my $PWD = dirname(__FILE__);
my $root = abs_path($PWD); 

my $java_path = "java";

my $snpeff_path = "/BiOfs/hmkim87/BioTools/snpEff/3.5c_build_2014-02-21/";
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

