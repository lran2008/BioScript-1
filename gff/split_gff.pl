#!/usr/bin/perl -w

use strict;
use File::Basename; 

my $in_gff = $ARGV[0];
my ($filename,$filepath,$fileext) = fileparse($in_gff, qr/\.[^.]*/); 


my %hash;
open my $fh, '<:encoding(UTF-8)', $in_gff or die;
while (my $row = <$fh>) {
        chomp $row;
	if ($row =~ /^#/){ next; }
	my @l = split /\t/, $row;
	my $source = $l[1];
	my $type = $l[2];
	push @{$hash{$source}{$type}}, $row;
}
close($fh);

foreach my $source (keys %hash){
	foreach my $type (keys %{$hash{$source}}){
		my $out_gff = "$filepath/$source\_$type.gff";
		open my $fh, '>:encoding(UTF-8)', $out_gff or die;
		foreach (@{$hash{$source}{$type}}){
			print $fh $_."\n";
		}
		close ($fh);
	}
}
