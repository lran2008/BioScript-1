#!/usr/bin/perl -w

use strict;
if (@ARGV !=1){
	printUsage();
}
my $fasta = $ARGV[0];
my $command = "sed '/\^\$/d' $fasta";
print $command."\n";
system($command);

sub printUsage{
	print "Usage: perl $0 <in.fasta>\n";
	exit;
}
