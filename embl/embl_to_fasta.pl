#!/usr/bin/perl

use strict;
use warnings;

my $usage = "Usage $0 <infile.embl> <outfile.fa>\n";
my $infile = shift or die $usage;
my $outfile = shift or die $usage;

my $read_seq = '0';
my $current_id = '';
my %fasta = ();

my $item_number = '0';

open (IN,'<',$infile) || die "Could not open $infile: $!\n";
while(<IN>){
   chomp;
   next unless /^ID/ || /^SQ/ || $read_seq == '1';
   if (/^ID/){
      #ID   IS1     repeatmasker; DNA;  ???;  768 BP.
      if (/^ID\s+([.()0-9A-Za-z-_]+)\s+/){
         $current_id = $1;
         ++$item_number;
         #print "$current_id\n";
         next;
      } else {
         die "Could not parse ID line $.: $_\n";
      }
   }
   if (/^SQ/){
      $read_seq = '1';
      next;
   }
   if (/^\/\//){
      $read_seq = '0';
   }
   if ($read_seq){
      if (/\s+[atgcATGC]/){
         #agcaagcgat atacgcagcg aattgagcgg cataacctga atctgaggca gcacctggca   660
         s/\d+$//;
         s/\s+//g;
         die "Non DNA alphabet recognised on line $.: $_\n" if /^[^atgc]+$/i;
         $fasta{$current_id} .= $_;

      #line in embl file without any sequence but contains a line number
      } elsif (/\s+\d+$/){
         next;
      } else {
         die "Could not parse seq line $.: $_\n";
      }
   }
}
close(IN);

my @item = keys %fasta;
if (scalar(@item) != $item_number){
   my $difference = $item_number - scalar(@item);
   die "There may be an ID that is not unique in $infile: $difference items have not been stored\n";
}

open(OUT,'>',$outfile) || die "Could not open $outfile for writing: $!\n";

foreach my $id (keys %fasta){
   print OUT ">$id\n";
   print OUT "$fasta{$id}\n";
}

close(OUT);

exit(0);
