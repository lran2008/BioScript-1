#!/usr/bin/perl -w

use strict;

my $makeblastdb = "/BiOfs/hmkim87/BioTools/ncbi-blast/2.2.29/bin/makeblastdb";
my $blastn = "/BiOfs/hmkim87/BioTools/ncbi-blast/2.2.29/bin/blastn";

my $db_fasta = "/BiOfs/hmkim87/BioResources/Reference/Human/Resources/rRNA/human_all_rRNA.fasta.txt";

my $dbtype = "nucl";
my $title = "human_all_rRNA";
my $out = $db_fasta;
my $command = "$makeblastdb -in $db_fasta -dbtype $dbtype -title $title -out $out -parse_seqids";
print $command."\n";
#$command = "/BiOfs/hmkim87/BioTools/ncbi-blast/2.2.29/bin/blastn -db /BiOfs/hmkim87/BioResources/Reference/Human/Resources/rRNA/human_all_rRNA.fasta.txt -query /BiO/brandon/Koref0/Input/test.fa -outfmt 8 -out test.out";
