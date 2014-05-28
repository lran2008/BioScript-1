#!/usr/bin/perl -w

use strict;
use File::Basename;

if (@ARGV != 3){
	printUsage();
}


my $pattern = $ARGV[0];
my $outfile = $ARGV[1];
my $outfile_chart = $ARGV[2];

my @files = glob($pattern);

my $sum_all = 0;
my $sum_somatic = 0;
my $sum_germline = 0;
my $sum_loh = 0;

open(OUT, ">$outfile") or die;
#print OUT "Chr\tAll\tsomatic\tgermline\tLOH\n";
print OUT "Chr\tSomatic\n";
for (my $i=0; $i<@files; $i++){
	my $file = $files[$i];

	my $arr_ = read_infile($file);
	my @arr = @$arr_;

	$sum_all += $arr[0];
	$sum_somatic += $arr[1];
	$sum_germline += $arr[2];
	$sum_loh += $arr[3];

	my ($filename,$dir,$ext) = fileparse($file,qr/\.[^.]*/);
	my $chrName = (split /\./, $filename)[0];
	
	unshift @arr, $chrName;
	
	my $last_ = join "\t", @arr;
	#print OUT "$last_\n";
	print OUT "$chrName\t$arr[1]\n";
}
#print OUT "Sum\t$sum_all\t$sum_somatic\t$sum_germline\t$sum_loh\n";
close(OUT);

open(OUT_CHART,">$outfile_chart") or die;
print OUT_CHART "Variantion type\tVariation count\n";
print OUT_CHART "Somatic\t$sum_somatic\n";
print OUT_CHART "Germline\t$sum_germline\n";
print OUT_CHART "LOH\t$sum_loh\n";
close(OUT_CHART);

sub read_infile{
	open(DATA, shift);
	my @result;
	while(<DATA>){
		chomp;

		my @line = split /\s+/, $_;
		
		my $value = $line[0];
		push @result, $value;
	}
	close(DATA);
	return \@result;
}

sub printUsage{
	print "Usage: perl $0 <\"*.varscan.stat\"> <out.table.tsv> <out.piechart.tsv>\n";
	exit;
}
