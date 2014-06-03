#!/usr/bin/perl -w

use strict;

if (@ARGV != 2){
	printUsage();
}
my $infile = $ARGV[0];

#my $out_dir = "./pph_input";
my $out_dir = $ARGV[1];
if (!-d $out_dir){ system("mkdir -p $out_dir"); }

my %hash;
open(DATA, $infile);
while(<DATA>){
	chomp;
	my @line = split /\t/, $_;

	my $id = $line[0];
	my $pos = $line[1];
	my $ref = $line[2];
	my $alt = $line[3];
	push @{$hash{$id}}, "$pos\t$ref\t$alt";
}
close(DATA);

foreach my $key (keys %hash){
	open(PPH, ">$out_dir/$key.pph.input");
	foreach my $val (@{$hash{$key}}){
		print PPH "$key\t$val\n";
	}
	close(PPH);
}

sub printUsage{
	print "Usage: perl $0 <pph input> <split out dir>\n";
	exit;
}
