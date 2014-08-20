#!/usr/bin/perl
use warnings;
use strict;

open (IN,'contaminant_list.txt') or die $!;
open (OUT,'>','contaminant_list.fa') or die $!;

while (<IN>) {
next if (/^\#/);
chomp;
next unless ($_);
my ($name,$seq) = split(/\t+/);
next unless ($seq);
$name =~ s/\s+/_/g;
print OUT ">$name\n$seq\n";
}
close OUT or die $!;

