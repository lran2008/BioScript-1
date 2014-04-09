#!/usr/bin/perl -w

use strict;

if (@ARGV !=2){
	printUsage();
}

my $in_fasta = $ARGV[0];
my $out_gff = $ARGV[1];

#my $in_fasta = "/var/lib/gbrowse/databases/koref0_scaffolds/Korean55.scafSeq.fill.gapclose.1.fa";
#my $out_gff = "/var/lib/gbrowse/databases/koref0_scaffolds/Korean55.scafSeq.fill.gapclose.1.gff3";
#my $bwa = "/BiO/BioTools/bwa-0.7.8/bwa";
my $samtools = "/BiOfs/BioTools/samtools-0.1.19/samtools";

# fa index with samtools
my $fai_file = $in_fasta.".fai";
if (!-f $fai_file){
	my $cmd_fa_idx = "$samtools faidx $in_fasta";
	print $cmd_fa_idx."\n";
}


open my $gff, '>:encoding(UTF-8)', $out_gff or die;
print $gff "##gff-version 3\n";
open my $fh, '<:encoding(UTF-8)', $fai_file or die;
while (my $row = <$fh>) {
        chomp $row;
	my @l = split /\t/, $row;
	my ($seqid, $source, $type, $start, $end, $score, $strand, $phase, $attributes);
	$seqid = $l[0];
	$source = "PGI";
	$type = "scaffold";
	$start = 1;
	$end = $l[1];
	$score = ".";
	$strand = ".";
	$phase = ".";
	my $name = $seqid;
	$name =~ s/(\w+)/\u$1/g;
	$attributes = "ID=$seqid;Name=$name";

	my $line = "$seqid\t$source\t$type\t$start\t$end\t$score\t$strand\t$phase\t$attributes\n";
	print $gff $line;
}
close($fh);
close($gff);

sub printUsage{
	print "Usage: perl $0 <in.fasta> <out.gff>\n";
	exit;
}
