#!/usr/bin/perl -w

use strict;

my $infile = $ARGV[0];

read_infile($infile);

sub read_infile{
	open(DATA, $infile);
	my $snv_cnt = 0;
	while(<DATA>){
		chomp;
		if ($_ =~ /^#/){
			next;
		}
		my @line = split /\t/, $_;

		my $CHROM = $line[0];
		my $POS = $line[1];
		my $ID = $line[2];
		my $REF = $line[3];
		my $ALT = $line[4];

		if ($REF =~ /\,/){ die "ERROR! $_\n"; } # No need?

		if ($ALT =~ /\,/){
			print "$_\n";
			my @arr = split /\,/, $ALT;
			my $standard_length_var = 1; # SNP variation allele length
			foreach my $var (@arr){
				if (length($var) != 1){
					
				}	
			}
			next;
		}
		if (length($REF) != 1 or length($ALT) != 1){
			next;
		}
		$snv_cnt++;
	}
	close(DATA);

	print "$snv_cnt\n";
}
