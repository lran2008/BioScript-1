#!/usr/bin/perl -w

use strict;

my $infile = $ARGV[0];

my %hash;
open(DATA, $infile);
while(<DATA>){
	chomp;
	if ($_ =~ /^#/){ next; }

	my @line = split /\t/, $_;
	my $ref_base = $line[2];
	my $alt_base = $line[3];

	if (length ($ref_base) ne 1 or length ($alt_base) ne 1){
		next;
	}

	my $gene = $line[12];
	my $aa = $line[10];
	my $class = $line[8];

	if (defined $class and $class eq "SILENT"){
		next;
	}

	if (defined $aa and length($aa) > 0){
		$aa =~ /([a-zA-Z\*]+)(\d+)([a-zA-Z\*]+)/;
		my $aa_original = $1;
		my $aa_pos = $2;
		my $aa_change = $3;

		if (defined $hash{$gene}{$aa_pos}){
			next;
		}
		print "$gene\t$aa_pos\t$aa_original\t$aa_change\n";
		$hash{$gene}{$aa_pos}++;
	}else{
		next;
	}
}
close(DATA);
