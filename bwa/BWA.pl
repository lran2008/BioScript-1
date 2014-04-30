#!/usr/bin/perl -w

use strict;

my $BWA = "/nG/Process/Tools/bwa-0.7.8/bwa";
my $BWA_PARAM = "-M -R '@RG\tID:dog\tSM:dog\tPL:Illumina 1.8+'";
my $REFERENCE_FASTA = $ARGV[0];
my $READ_1 = $ARGV[1];
my $READ_2 = $ARGV[2];
my $OUT_BAM = $ARGV[3];

my $command = "$BWA ";

#comment
#$ bwa mem ref.fa <(bzip2 -dc read1.bz2) <(bzip2 -dc read2.bz2)
#$ bwa sampe [OPTIONS] [DB] <(bwa aln [OPTIONS] [DB] [FASTQ1]) <(bwa aln [OPTIONS] [DB] [FASTQ2]) [FASTQ1] [FASTQ2] | samtools view -Su - | samtools sort - [PREFIX]
#$ bwa mem -t6 long read.1.fq read.2.fq | samtools view -@6 -Sub - | tee >(samtools flagstat - > stats.out) > aln.bam
#$ bwa sampe referencefile <(bwa aln ref fastq1)  <(bwa aln ref fastq2) fastq1 fastq2

