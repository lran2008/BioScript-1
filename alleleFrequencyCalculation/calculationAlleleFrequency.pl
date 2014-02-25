#!/usr/bin/perl -w

use strict;

if (@ARGV != 2){
	printUsage();
}
my $in_vcf = $ARGV[0];
my $out = $ARGV[1];

my $vcftools = "/gg/bio/tools/vcftools_0.1.11/bin/vcftools";

my $command = "$vcftools --vcf $in_vcf --freq --out $out";
print $command."\n";
system($command);

sub printUsage{
	print "Usage: perl $0 <in.vcf> <out_prefix>\n";
	exit;
}
