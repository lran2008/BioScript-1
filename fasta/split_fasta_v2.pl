#!/usr/bin/perl

use strict;
use Bio::SeqIO;

if (@ARGV !=3){ printUsage(); }
my $from = shift;
my $toprefix = shift;
my $seqs = shift;

my $in  = new Bio::SeqIO(-file  => $from);

my $count = 0;
my $fcount = 1;
my $out = new Bio::SeqIO(-file => ">$toprefix.$fcount", -format=>'fasta');
while (my $seq = $in->next_seq) {
        if ($count % $seqs == 0) {
                $fcount++;
                $out = new Bio::SeqIO(-file => ">$toprefix.$fcount", -format=>'fasta');
        }
        $out->write_seq($seq);
        $count++;
}

sub printUsage{
	print "perl $0 allseqs.fa splitseqs_prefix 100";
	exit;
}
