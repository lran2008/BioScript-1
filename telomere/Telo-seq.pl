#!/usr/bin/perl

#October 25 2012, Uppsala
#Author: Nagarjun Vijay
#Purpose:To count the number of telomeric reads and report the relative telomere length

if (@ARGV != 3){
    printUsage();
}

use strict;
use warnings;

my $read1 = $ARGV[0]; # read1 
my $read2 = $ARGV[1]; # read2
my $repeats = $ARGV[2]; # Number 

if ($read1 =~ /\.gz/ and $read2 =~ /\.gz/){
    open(READ1, "gunzip -c $read1 |");
    open(READ2, "gunzip -c $read2 |");
}
else{
    open(READ1, $read1);
    open(READ2, $read2);
}

my $vertMotif="TTAGGG";

my $motif=$vertMotif x $repeats;
my $reversemot=reverse_complement_motif($motif);

my $totalCount=0;
my $teloCount=0;


while(<READ1>) {
my @readhead=split(' ',$_);
	my $id = $readhead[0];
	my $seq=<READ1>;
	my $plus=<READ1>;
	my $score=<READ1>;
	my $id2=<READ2>;
	my $seq2=<READ2>;
	my $plus2=<READ2>;
	my $score2=<READ2>;

	$id =~ s/@//;
	$id =~ s/\/\d//;
	chomp($id);

	if(($seq=~m/$motif/)||($seq=~m/$reversemot/)||($seq2=~m/$motif/)||($seq2=~m/$reversemot/)){$teloCount++;}
	$totalCount++;
}
close(READ1);
close(READ2);

print "Motifs used to search: $motif, $reversemot\n";
print "Total read pairs:$totalCount\n";
print "Total telomere read pairs:$teloCount\n";
print "Relative telomere length:". ($teloCount/$totalCount) . "\n";


sub reverse_complement_motif {
        my $motif = shift;
        my $reversemotif = reverse($motif);
        $reversemotif =~ tr/ACGTacgt/TGCAtgca/;
        return $reversemotif;
}

sub printUsage{
    print "Usage: perl $0 <read1> <read2> <repeatCount>\n";
    print "Example: perl $0 read1.fq.gz read2.fq.gz 1\n";
    exit;
}
