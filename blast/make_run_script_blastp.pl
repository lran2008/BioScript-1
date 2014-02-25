#!/usr/bin/perl -w

use strict;
use warnings;

my $indir = "/BiO3/hmkim87/orthoMCL/69_fasta/split";
my @infiles = glob("$indir/*");

my $bin = "/BiOfs/BioTools/blast-2.2.23/bin/blastall";
my $program = "blastp";
my $db = "/BiO3/hmkim87/orthoMCL/69_fasta/goodProteins.fasta";

for (my $i=0; $i<@infiles; $i++){
    open DATA, ">$infiles[$i].sh";
    print DATA "\#\!/bin/sh/\n";
    print DATA "date\n";
    print DATA "$bin -p $program -F 'm S' -v 100000 -b 100000 -z 372661 -e 1e-5 -d $db -i $infiles[$i] -m 8 -o $infiles[$i].out\n";
    print DATA "date\n";
    close DATA;
}
