#!/usr/bin/perl -w

use strict;

my $samtools = "/nG/Process/Tools/SAMtools/samtools-0.1.19/samtools";
my $fastaFromBed = "/nG/Process/Tools/BEDTools/bedtools-2.17.0/bin/fastaFromBed";
my $command;

my $in_fasta = "/nG/Reference/climb.genomics.cn/pub/10.5524/100001_101000/100067/FASTA/chrAll.fa";
$command = "$samtools faidx $in_fasta";

my $selectSeq = "selectSeq.bed";
$command = "awk '{if(\$2 < 300) print \$1 \"\\t0\\t\" \$2 \"\\t\" \$1}' $in_fasta.fai > $selectSeq";
print $command."\n";

my $selectSeqFa = "selectSeq.fa";
$command = "$fastaFromBed -fi $in_fasta -bed $selectSeq -name -fo $selectSeqFa";
print $command."\n";
