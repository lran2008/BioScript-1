#!/usr/bin/perl -w

use strict;

if (@ARGV != 1){
	printUsage();
}
my $bgt = $ARGV[0];

open(DATA, $bgt);
while(<DATA>){
	chomp;
	my @line = split /\t/, $_;

	my $protein = $line[22];
	my $region = $line[23];
	my $refAA = $line[26];
	my $altAA = $line[29];
	my $posAA = $line[32];

	if ($refAA eq "." or $refAA eq "*"){
		next;
	}
	if ($altAA eq "." or $altAA eq "*"){
		next;
	}
	print "$protein\t$posAA\t$refAA\t$altAA\n";
}
close(DATA);

sub printUsage{
	print "Usage: perl $0 <bgt file>\n";
	exit;
}
