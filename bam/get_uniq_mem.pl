#!/usr/bin/perl -w

use strict;

if (@ARGV != 1){
	printUsage();
}

#my $samtools = "/nG/Process/Tools/SAMtools/samtools-0.1.19/samtools";
my $samtools = "/gg/bio/tools/samtools-0.1.19/samtools";
#print STDERR "SAMTOOLS: [$samtools]\n";

#my $inbam = "/nG/Data/$job_id/__OUTPUT__/final.bam";
my $inbam = $ARGV[0];

my $command = "$samtools view -q 1 $inbam | grep -v -P \"\\tSA:\" | wc -l";
print $command."\n";
system($command);

sub printUsage{
	print "Usage: perl $0 <in.bam>\n";
	exit;
}
