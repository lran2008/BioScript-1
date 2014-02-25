#!/usr/bin/perl -w

use strict;
use warnings;

my $targetDir = "/BiO3/hmkim87/orthoMCL/69_fasta/split";

my @infiles = glob("$targetDir/*.sh");

for (my $i=0; $i<@infiles; $i++){
    my $cmd = "qsub $infiles[$i]";
    print $cmd."\n";
    system($cmd);
}
