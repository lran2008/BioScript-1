#!/usr/bin/perl -w

use strict;

if (@ARGV !=2 ){
    printUsage();
}

my $id_file = $ARGV[0];
my $pep_file = $ARGV[1];
#my $id_file = "/BiO3/hmkim87/Cow/cow_pep_geneneme.txt";
#my $pep_file = "/BiO3/hmkim87/Cow/ensPep.txt";

my %id_hash = read_id($id_file);
read_pep($pep_file);

sub read_pep{
	open(DATA, shift);
	while(<DATA>){
		chomp;

		my @line = split /\t/, $_;
		
		my $ens_id = $line[0];
		my $seq = $line[1];
		if (defined $id_hash{$ens_id}){
			print ">$id_hash{$ens_id}\n$seq\n";
		}
	}
	close(DATA);
}

sub read_id{
	my %hash;
	open(DATA, shift);
	while(<DATA>){
		chomp;
		if ($_ =~ /Ensembl/){
			next;
		}
		my @line = split /\t/, $_;

		my $ENS = $line[0];
		my $NP = $line[1];

		if (!defined $NP){
			next;
		}

		$hash{$ENS} = $NP;
	}
	close(DATA);

	return %hash;
}

sub printUsage{
    print "Usage: perl $0 <id_file> <peptide fasta file>\n";
    exit;
}
