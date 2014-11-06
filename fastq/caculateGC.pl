#!/usr/bin/env perl

#
# by  Dr. Xiaodong Bai
# for the calculation of the GC contents of DNA sequences in FASTA format
# the ID and GC content of each sequence are on one line separated with a tab character
#

use strict;
use warnings;
use Bio::SeqIO;

die ("Usage: $0 <sequence_file> (output_file>\n"), unless (@ARGV == 2);

my ($infile,$outfile) = @ARGV;
open (OUT,">$outfile");
my $in = Bio::SeqIO->new(-file => $infile, -format => 'fasta');
while (my $seqobj = $in->next_seq) {
    my $id = $seqobj->id;
    my $seq = $seqobj->seq;
    my $length = $seqobj->length;
    my $count = 0;
    for (my $i = 0; $i < $length; $i++) {
	my $sub = substr($seq,$i,1);
	if ($sub =~ /G|C/i) {
	    $count++;
	}
    }
    my $gc = sprintf("%.1f",$count * 100 /$length);
    print OUT $id,"\t",$gc,"\n";
}

