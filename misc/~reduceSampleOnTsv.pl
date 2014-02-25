#!/usr/bin/perl -w

use strict;

my $intsv = "/gg/tmp/t7_out/z.tsv";

open FH,"<$intsv";
while(<FH>){
	chomp;
	my @tmp=split("\t",$_);
	my $last = $#tmp;

	my @same_tmp = @tmp[0..36];
	my @diff_tmp = @tmp[37..$last];
	my $same = join "\t", @same_tmp;
	my $diff = join "\t", @diff_tmp;
	print $diff."\n";
	if ($_ =~ /^CHROM/){
		next;
	}else{
		my $sample_name = $diff_tmp[0];
		#print $sample_name."\n";
		#tr/\n//d;
	#	$key=$tmp[0]."|".$tmp[1];
	#	if(exists $hash{$key}){
	#		$hash{$key}=sprintf("%s|%s",$hash{$key},$tmp[2]);
	#	}
	#	else{
	#		$hash{$key}=$tmp[2];
	#	}
	}
}
close FH;

#for $key (sort keys %hash){
#	print $key,"|",$hash{$key},"\n";
#}
