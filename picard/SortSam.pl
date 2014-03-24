#!/usr/bin/perl -w

use strict;
use File::Basename; 

if (@ARGV !=2){
	printUsage();
}

my $samtools = "/BiOfs/hmkim87/BioTools/samtools/0.1.19_CentOS/samtools";
my $picard_path = "/BiOfs/hmkim87/BioTools/picard/1.107";
my $picard_program = "$picard_path/SortSam.jar";

my $infile = $ARGV[0];
my $outfile = $ARGV[1];

#my ($filename,$filepath,$fileext) = fileparse($IN_BAM, qr/\.[^.]*/);

my $sortOrder = "coordinate"; # Possible values: {unsorted, queryname, coordinate}

my $command = "java -Xmx4g -Djava.io.tmpdir=`pwd`/tmp -jar $picard_program I=$infile OUTPUT=$outfile VALIDATION_STRINGENCY=LENIENT COMPRESSION_LEVEL=0 SORT_ORDER=$sortOrder";
print $command."\n";
system($command);

sub printUsage{
	print "Usage: perl $0 <infile> <outfile>\n";
	exit;
}
