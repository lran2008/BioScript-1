#!/usr/bin/perl -w

use strict;

if (@ARGV != 2){
	printUsage();
}
my $in_vcf = $ARGV[0];
my $out_prefix = $ARGV[1];

my $vcftools = "/BiOfs/hmkim87/BioTools/vcftools/0.1.12a/bin/vcftools";
my $cmd_vcf2plink = vcf2plink($in_vcf,$out_prefix);
print $cmd_vcf2plink."\n";


sub vcf2plink{
	my $infile = $_[0];
	my $prefix_output = $_[1];

	my $command = "$vcftools --vcf $infile --plink --out $prefix_output";
	return $command;
}
/BiOfs/hmkim87/BioTools/vcftools/0.1.12a/bin/vcftools --vcf PAPGI_94_samples.vcf --plink --out PAPGI_94_samples

sub printUsage{
	print "Usage: perl $0 <in.vcf> <out_prefix>\n";
	exit;
}
