#!/usr/bin/perl -w

use strict;

#cutadapt -e ERROR-RATE -a ADAPTER-SEQUENCE input.fastq > output.fastq
my $cutadapt = "cutadapt";

my $r1 = "/gg/data/exome/CDC-173/CDC-173_1.fastq.gz";
my $r2 = "/gg/data/exome/CDC-173/CDC-173_2.fastq.gz";
my $r1_out = "/gg/data/exome/CDC-173/Tool/cutadapt/CDC-173_1.cutadapt.fastq.gz";
my $r2_out = "/gg/data/exome/CDC-173/Tool/cutadapt/CDC-173_2.cutadapt.fastq.gz";
my $r1_tmp = "/gg/data/exome/CDC-173/Tool/cutadapt/CDC_173_1.cutadapt.tmp.fastq.gz";
my $r2_tmp = "/gg/data/exome/CDC-173/Tool/cutadapt/CDC_173_2.cutadapt.tmp.fastq.gz";

my $adapter_fwd = "AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC";
my $adapter_rev = "AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT";

my $min_len = 100; # required
my $error_rate = 0.1;
my $command;
$command = "$cutadapt -e $error_rate -a $adapter_fwd --minimum-length $min_len --paired-output $r2_tmp -o $r1_tmp $r1 $r2";
print $command."\n";
$command = "$cutadapt -e $error_rate -a $adapter_rev --minimum-length $min_len --paired-output $r1_out -o $r2_out $r2_tmp $r1_tmp";
print $command."\n";
$command = "rm $r1_tmp $r2_tmp";
print $command."\n";
