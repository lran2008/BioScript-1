#!/usr/bin/perl -w
##
# Function: only split fasta if has more shorter than N length in multi fasta file.
# Author: Hyunmin Kim
# Senior Researcher
# Genome Research Foundation
# E-Mail: brandon.kim.hyunmin@gmail.com
#
# History:
# - Version 0.1 ( Apr 8, 2014)
##
use strict;

if (@ARGV != 3){ printUsage(); }

my $samtools = "/BiOfs/hmkim87/BioTools/samtools/0.1.19/samtools";
my $fastaFromBed = "/BiOfs/hmkim87/BioTools/bedtools/2.19.0/bin/fastaFromBed";

my $command;

my $in_fasta = $ARGV[0];
my $selectSeqFa = $ARGV[1];
my $length = $ARGV[2];
if (!-f $in_fasta.".fai"){
	$command = "$samtools faidx $in_fasta";
	print "indexing...<$in_fasta>\n";
	system($command) and die $!;
	print "indexing...end<$in_fasta.fai>\n";
}

my $selectSeq = "selectSeq.bed";
$command = "awk '{if(\$2 > $length) print \$1 \"\\t0\\t\" \$2 \"\\t\" \$1}' $in_fasta.fai > $selectSeq";
print $command."\n";
system($command) and die $!;

$command = "$fastaFromBed -fi $in_fasta -bed $selectSeq -name -fo $selectSeqFa";
print $command."\n";
system($command) and die $!;

$command = "rm $selectSeq";
system($command) and die $!;

sub printUsage{
	print "Usage: perl $0 <in.fasta> <out.fasta> <length>\n";
	print "Description: extract fasta seq with length more than <length>\n";
	exit;
}
