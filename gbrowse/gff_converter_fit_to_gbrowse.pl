#!/usr/bin/perl -w

use strict;

my $in_gff =$ARGV[0];


open my $fh, '<:encoding(UTF-8)', $in_gff or die;
while (my $row = <$fh>) {
        chomp $row;
	if ($row =~ /^#/){
		print $row."\n";
		next;
	}
	my @l = split /\t/, $row;
	my $attributes = $l[8];
	my @arr = split /\;/, $attributes;
	my $tmp_var = "";
	my $flag = 0;
	my @arr_real;
	foreach (@arr){
		#print $_."\n";
		if ($_ =~ /=\"/){
			$flag = 1;
			$tmp_var .= $_;
			next;
		}
		if ($flag == 1){
			$tmp_var .= $_;
		}else{
			push @arr_real, $_;
		}
		if ($_ =~ /^\"/){
			push @arr_real, $tmp_var;
			$flag = 0;
		}
	}
	my $real_var = (join "\;", @arr_real)."\;";
	$l[8] = $real_var;
	$row = join "\t", @l;
	print $row."\n";
}
close($fh);
