#!/usr/bin/perl -w

use strict;

if (@ARGV != 1){
	printUsage();
}

my $infile = $ARGV[0];

my $command = "cat $infile | perl -ne '\$s=<>;<>;<>;chomp(\$s);print length(\$s).\"\\n\";'";
$command = $command." | sort - | uniq -c";
print $command."\n";

sub printUsage{
	print "Usage: perl $0 <in.fastq>\n";
	exit;
}
