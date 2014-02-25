#!/usr/bin/perl -w

use strict;

my $in_tsv = $ARGV[0];
$in_tsv = "/gg/tmp/single_out_2//all.annotated.tsv";

my $command;

$command = "head -n 1 $in_tsv | tr \"\t\" \"\n\" | grep -n dbNSFP";
my $res = `$command` or die;
my @arr = split /\n/, $res;

my @target_num;
foreach (@arr){
	my $num = (split /\:/, $_)[0];
	#print $num."\n";
	push @target_num, $num-1; # numeric index to array index
}

open(DATA, $in_tsv);
while(<DATA>){
	chomp;
	if ($_ =~ /^CHR/){
		#print $_."\n";
		next;
	}
	my @l = split /\t/, $_;
	print "$l[0]\t$l[1]\t$l[2]\t$l[3]\t$l[4]\t$l[19]\t$l[20]\t$l[22]\t$l[23]\t$l[27]\n";
	foreach my $num (@target_num){
		#print $l[$num]."\n";
		$l[$num] = "";
	}
}
close(DATA);
