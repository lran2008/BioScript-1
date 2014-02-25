#!/usr/bin/perl -w

use strict;

if (@ARGV != 1){
	printUsage();
}
my $infile = $ARGV[0];

my $PATH_tabix = "/nG/Process/Tools/tabix/tabix-0.2.6";
my $bgzip = $PATH_tabix."/bgzip";
my $tabix = $PATH_tabix."/tabix";

my $command = "$bgzip -c $infile > $infile.gz";
system($command);

$command = "$tabix -p vcf $infile.gz";
system($command);

sub printUsage{
	print "Usage: perl $0 <in.vcf>\n";
	exit;
}
