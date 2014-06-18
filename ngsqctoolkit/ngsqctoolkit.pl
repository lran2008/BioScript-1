#!/usr/bin/perl -w
#144m9.844s
use strict;

if (@ARGV != 3){
	printUsage();
}
my $r1 = $ARGV[0];
my $r2 = $ARGV[1];
my $outputFolder = $ARGV[2];

my $bin = "/BiOfs/hmkim87/BioTools/NGSQCToolkit/2.3.3/QC/IlluQC_PRLL.pl";

my $library = "N";
my $type = "A";

my $cutOffReadLen4HQ = 70;
my $cutOffQualScore = 20;
my $processes = 1;
my $statOutFmt = 1; # 1 = formatted text, 2 = tab delimited
my $outputDataCompression = "g"; # t = text FASTQ files, g = gzip compressed files
my $cpu = 4;

#my $option = "-l $cutOffReadLen4HQ -s $cutOffQualScore -p $processes -t $statOutFmt -z $outputDataCompression -o $outputFolder -c $cpu";
my $option = "-l $cutOffReadLen4HQ -s $cutOffQualScore -t $statOutFmt -z $outputDataCompression -o $outputFolder -c $cpu";

my $command;
$command = "perl $bin -pe $r1 $r2 $library $type $option";
print $command."\n";
#system($command);

sub printUsage{
	print "Usage: perl $0 <r1.fastq> <r2.fastq> <output directory>\n";
	exit;
}
