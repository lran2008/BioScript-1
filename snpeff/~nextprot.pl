#!/usr/bin/perl -w

use strict;
use File::Basename;
use Cwd 'abs_path';

if (@ARGV !=4){
	printUsage();
}

my $genome_version = $ARGV[1];
my $in_vcf = $ARGV[0];
my $out_vcf = $ARGV[2];
my $logfile = $ARGV[3];

my $PWD = dirname(__FILE__);
my $root = abs_path($PWD); 

my $snpeff_path = "$root/../../tools/snpEff";
my $snpeff = "$snpeff_path/snpEff.jar";
my $snpeff_config = "$snpeff_path/snpEff.config";
snpeff_nextprot($in_vcf,$out_vcf,$logfile);

sub snpeff_nextprot{
	my $in = shift;
	my $out = shift;
	my $log = shift;

	my $mem = "4g";
	#java -Xmx4g -jar snpEff.jar -v -nextprot GRCh37.71 test.vcf > test.eff.vcf
	my $command = "java -jar -Xmx$mem $snpeff ".
	"-c $snpeff_config -v -nextprot $genome_version ".
	"$in > $out ".
	"2> $log";
	print STDERR $command."\n"; 
	#system($command);
}

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

