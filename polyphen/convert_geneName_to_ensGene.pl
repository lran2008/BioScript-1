#!/usr/bin/perl -w

use strict;

my $id_file = $ARGV[0];
my $pph_input = $ARGV[1];

my %id_hash = read_id($id_file);

open(DATA, $pph_input);
while(<DATA>){
	chomp;
	if ($_ =~ /^ENS/){
		print "$_\n";
		next;
	}

	my @line = split /\t/, $_;

	my $gene = $line[0];
	my $ensID = $line[1];

	if (defined $id_hash{$gene}){
		$line[0] = $id_hash{$gene};
		my $res = join "\t", @line;
		print "$res\n";
	}
}
close(DATA);

sub read_id{
	open(DATA, shift);
	my %hash;
	while(<DATA>){
		chomp;
		my @line = split /\t/, $_;

		my $geneName = $line[0];
		my $ensGeneID = $line[1];

		if (length($geneName) < 1){
			next;
		}else{
			$hash{$geneName} = $ensGeneID;
		}
	}
	close(DATA);
	return %hash;
}
