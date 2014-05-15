#!/usr/bin/perl -w

use strict;

if (@ARGV != 3){
	printUsage();
}
my $db_fasta = $ARGV[0];
#my $db_fasta = "/BiOfs/hmkim87/BioResources/Reference/Human/Resources/rRNA/human_all_rRNA.fasta.txt";
my $dbtype = $ARGV[1];
#my $dbtype = "nucl";
my $title = $ARGV[2];
#my $title = "human_all_rRNA";
my $out = $db_fasta;

my $makeblastdb = "/BiOfs/hmkim87/BioTools/ncbi-blast/2.2.29/bin/makeblastdb";
my $blastn = "/BiOfs/hmkim87/BioTools/ncbi-blast/2.2.29/bin/blastn";

my $command = "$makeblastdb -in $db_fasta -dbtype $dbtype -title $title -out $out -parse_seqids";
print $command."\n";
system($command);
#$command = "/BiOfs/hmkim87/BioTools/ncbi-blast/2.2.29/bin/blastn -db /BiOfs/hmkim87/BioResources/Reference/Human/Resources/rRNA/human_all_rRNA.fasta.txt -query /BiO/brandon/Koref0/Input/test.fa -outfmt 8 -out test.out";

sub printUsage{
	print "Usage: perl $0 <db.fasta> <dbtype:nucl|prot> <title>\n";
	exit;
}
