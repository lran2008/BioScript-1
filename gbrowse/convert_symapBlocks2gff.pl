#!/usr/bin/perl -w

use strict;

if (@ARGV != 1){
	printUsage();
}
my $infile = $ARGV[0];
#my $infile = "/var/lib/gbrowse2/databases/koref1/hg19_vs_koref1.symap.blocks";


open my $fh, '<:encoding(UTF-8)', $infile or die;
my $l_cnt = 1;
while (my $row = <$fh>) {
        chomp $row;
	if ($row =~ /^grp/){
		next;
	}
	my @l = split /\t/, $row;
	my $chr_id = $l[0];
	my $scaffold_id = $l[1];
	my $chr_start = $l[3];
	my $chr_end = $l[4];
	my $scaffold_start = $l[5];
	my $scaffold_end = $l[6];
	my $hit_count = $l[7];
	print "scaffold$scaffold_id\tsymap\tsynteny\t$scaffold_start\t$scaffold_end\t.\t+\t.\tID=syn_$l_cnt;Target=$chr_id $chr_start $chr_end;type=chromosome;Annotation=$hit_count;\n";
	$l_cnt++;
}
close($fh);

sub printUsage{
	print "Usage: perl $0 <in.symap.blocks> > out.gff>\n";
	exit;
}
