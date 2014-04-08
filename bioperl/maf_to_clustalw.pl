#!/usr/bin/perl -w

use Bio::AlignIO;

$infile = $ARGV[0];
$outfile = $ARGV[1];

$in  = Bio::AlignIO->new(-file => $infile ,
                         -format => 'maf');
$out = Bio::AlignIO->new(-file => ">".$outfile,
                         -format => 'clustalw');
 
while ( my $aln = $in->next_aln ) {
  $out->write_aln($aln); 
}
