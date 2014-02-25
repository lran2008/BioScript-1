#!/usr/bin/perl -w

use strict;

if (@ARGV != 2){
	printUsage();
}

my $invcf = $ARGV[0];
my $each_chr_line_count = $ARGV[1];

my %hash;

open(DATA, $invcf);
while(<DATA>){
	chomp;
	if ($_ =~ /^#/){
		print $_."\n";
		next;
	}
	my @l = split /\t/, $_;
	my $chrom = $l[0];
	
	$hash{$chrom}++;

	if ($hash{$chrom} > $each_chr_line_count){
		next;
	}else{
		print $_."\n";	
	}
}
close(DATA);

sub printUsage{
	print "Usage: perl $0 <in.vcf> <countKey>\n";
	print "Description: This program will extract <countKey> line of each chromosome from VCF\n".
		"WARN! Result vcf has no sorted content! (e.g chromosome)\n";
	exit;
}
