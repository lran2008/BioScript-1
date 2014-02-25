#!/usr/bin/perl -w

use strict;
use File::Basename;
use Cwd 'abs_path'; 

my $PWD = dirname(__FILE__);
my $root = abs_path($PWD); 

my $vcf2tsv = "$root/../tools/vcflib/bin/vcf2tsv";

if (@ARGV !=2){
	printUsage();
}
my $invcf = $ARGV[0];
my $outvcf = $ARGV[1];
vcf2tsv($invcf,$outvcf);

sub vcf2tsv{
	#usage: vcf2tsv [-n null_string] [-g] [vcf file]
	#Converts stdin or given VCF file to tab-delimited format, using null string to replace empty values in the table.
	#Specifying -g will output one line per sample with genotype information.
	my $in = shift;
	my $out = shift;
	my $null_string = ".";
	my $command = "$vcf2tsv -n $null_string $in > $out";
	print "# command <$command>\n";
	system($command);
}

sub vcfaltcount{
	my $in = shift;
	my $vcfaltcount = "$root/../tools/vcflib/bin/vcfaltcount";
	my $command = "$vcfaltcount $in";
	system($command);
}

sub printUsage{
	print "Usage: perl $0 <in.vcf> <out.vcf>\n";
	exit;
}
