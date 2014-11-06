#!/usr/bin/perl -w

use strict;

my $bb_md5sum = "analysis.md5sum";
my $aa_md5sum = "exp.md5sum";

my %hash_aa = read_md5sum($aa_md5sum);
my %hash_bb = read_md5sum($bb_md5sum);

foreach my $value (keys %hash_aa){
	if (!defined $hash_bb{$value}){
		print "$aa_md5sum\t$value\t$hash_aa{$value}\n";
	}
}


foreach my $value (keys %hash_bb){
	if (!defined $hash_aa{$value}){
		print "$bb_md5sum\t$value\t$hash_bb{$value}\n";
	}
}



sub read_md5sum{
	my $file = shift;
	open my $fh, '<:encoding(UTF-8)', $file or die;
	my %hash;
	while (my $row = <$fh>) {
		chomp $row;
		my @l = split /\s+/, $row;

		my $value = $l[0];
		my $file = $l[1];
		$hash{$value} = $file;
	}
	close($fh);
	return %hash;
}
