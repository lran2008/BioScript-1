#!/usr/bin/perl
use warnings;
use strict;

## Program Info:
#
# Name: consensus calling with BAM
#
# Function: input BAM, input REF, output FASTQ (consensus calling)
#
# Author: Hyunmin Kim
# Support : Hyunho Kim
#
#  Copyright (c) Genome Research Foundation, 2014,
#  all rights reserved.
#
# Licence: This script may be used freely as long as no fee is charged
#    for use, and as long as the author/copyright attributions
#    are not removed.
#
# History:
#   Version 1.0 (June 20, 2014): first non-beta release.
##

use strict;

if (@ARGV < 3){
	printUsage();
}
my $bcftools = "/BiOfs/hmkim87/BioTools/consensus-calling-via-vcf2fq/bcftools/bcftools";
my $samtools = "/BiOfs/hmkim87/BioTools/consensus-calling-via-vcf2fq/samtools/samtools";
my $vcfutils = "/BiOfs/hmkim87/BioTools/consensus-calling-via-vcf2fq/bcftools/vcfutils.pl";

#my $ref = "/BiOfs/hmkim87/BioResources/Reference/Human/hg19/chrAll.fa";
#my $bam = "/BiO/BioProjects/PGI-PAPGI-Genome-2012-08/Reports/GR/WGS/Data/PUB-MAS0001-U01-G/final.bam";
#my $cns_fq = "/BiO/BioProjects/PGI-PAPGI-Genome-2012-08/Reports/GR/WGS/Data/PUB-MAS0001-U01-G/chrM.fq";

my $bam = $ARGV[0];
my $ref = $ARGV[1];
my $cns_fq = $ARGV[2];
my $region = $ARGV[3];

my $command;
if (defined $region){
	$command = "$samtools mpileup -uf $ref $bam -r $region  | $bcftools call -c | $vcfutils vcf2fq > $cns_fq";
}else{
	$command = "$samtools mpileup -uf $ref $bam  | $bcftools call -c | $vcfutils vcf2fq > $cns_fq";
}

#print STDERR "#command:".$command."\n";
system($command);

sub printUsage{
	print "usage: perl $0 <in.bam> <ref.fa> <out.fq> <optional;region>\n";
	print "example: perl $0 in.bam ref.fa out.fq chrM\n";
	print "example: perl $0 in.bam ref.fa out.fq\n";
	exit;
}
