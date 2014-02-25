#!/usr/bin/perl -w

use strict;

my $in_tsv = $ARGV[0];
$in_tsv = "/gg/tmp/single_out_2/sample.final.raw.tmp";

my $chr_num = get_column_num($in_tsv,"CHROM");
my $pos_num = get_column_num($in_tsv,"POS");
my $ref_num = get_column_num($in_tsv,"REF");
my $alt_num = get_column_num($in_tsv,"ALT");
my $AA_num = get_column_num($in_tsv,".AA"); # EFF[*].AA, EFF[*].AA_LEN... (Warn!! first select!!)

open(DATA, $in_tsv);
while(<DATA>){
	chomp;
	if ($_ =~ /^#/){
		next;
	}
	my @l = split /\t/, $_;
	my $chr = $l[$chr_num];
	my $pos = $l[$pos_num];
	my $ref = $l[$ref_num];
	my $alt = $l[$alt_num];
	my $aa_info = $l[$AA_num];
	if (length($aa_info) == 0){
		next;
	}
	$aa_info =~ /([a-zA-Z]+)[\d]+([a-zA-Z]+)/;
	if (!defined $2){
		next;
	}
	print $1."\t".$2."\n";
	print "$chr\t$pos\t$ref\t$alt\t$aa_info\n";
}
close(DATA);

sub get_column_num{
        my $tsv = shift;
        my $keyword = shift;
        my $command = "head -n 1 $tsv | tr \"\\t\" \"\\n\" | grep -n \"$keyword\"";
#	print $command."\n";
        my $num = `$command`;
	$num = (split /\:/, $num)[0];
#	print $num."\n";
	$num = $num-1;
        return $num;
}
