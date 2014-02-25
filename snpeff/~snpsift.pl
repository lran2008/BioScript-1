#!/usr/bin/perl -w

use strict;
use File::Basename;
use Cwd 'abs_path';

if (@ARGV !=4){
	printUsage();
}

my $in_vcf = $ARGV[0];
my $genome_version = $ARGV[1];
my $out_vcf = $ARGV[2];
my $logfile = $ARGV[3];

my $PWD = dirname(__FILE__);
my $root = abs_path($PWD); 

my $java_path = "java";

my $snpeff_path = "$root/../../tools/snpEff";
my $snpeff = "$snpeff_path/snpEff.jar";
my $snpeff_config = "$snpeff_path/snpEff.config";


my $command;
#check_snpeff_db($snpeff_config,$genome_version);

my ($filename,$filepath,$fileext) = fileparse($out_vcf, qr/\.[^.]*/); 
my $snpeff_option;
if ($genome_version eq "GRCh37.71"){
	$snpeff_option = "-c $snpeff_config -o gatk -motif -nextprot -v $genome_version -s $filepath$filename";
}else{
	$snpeff_option = "-c $snpeff_config -o gatk -v $genome_version -s $filepath$filename";

}	

my $snpeff_program = "eff";
$command = "$java_path -jar $snpeff $snpeff_program $snpeff_option $in_vcf > $out_vcf 2> $logfile";
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
	print "Usage: perl $0 <in.vcf> <snpeff_dbname> <out_snpeff.vcf> <logfile>\n";
	print "Example: perl $0 in.vcf hg19 out_snpeff.vcf out_snpeff.log\n";
	exit;
}

