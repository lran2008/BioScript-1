#!/usr/bin/perl -w

use strict;

if (@ARGV != 1){
	printUsage();
}
my $infile = $ARGV[0];

open my $fh, '<:encoding(UTF-8)', $infile or die;
while (my $row = <$fh>) {
        chomp $row;
	if ($row =~ /^>/){
		my @l = split /\s+/, $row;
		$row = (split /\s+/, $row)[0];
	}
	print $row."\n";
}
close($fh);

sub printUsage{
	print "Usage: perl $0 <in.fasta>\n";
	exit;
}
