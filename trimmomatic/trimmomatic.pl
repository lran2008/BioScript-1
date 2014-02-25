#!/usr/bin/perl -w

use strict;

my $bin = "/gg/tool/Trimmomatic-0.32/trimmomatic-0.32.jar";

#java -jar trimmomatic-0.30.jar PE --phred33 input_forward.fq.gz input_reverse.fq.gz output_forward_paired.fq.gz output_forward_unpaired.fq.gz output_reverse_paired.fq.gz output_reverse_unpaired.fq.gz ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36


my $phred = 33;
my $threads = 8;
my $trimLogFile = "/gg/data/exome/CDC-173/Tool/Trimmomatic/trim.log";
my $general_param = "-threads $threads $phred -trimlog $trimLogFile";

my $adapter_fa = "/gg/tool/Trimmomatic-0.32/adapters/TruSeq3-PE-2.fa"; #TruSeq2 (as used in GAII machines) and TruSeq3 (as used by HiSeq and MiSeq machines)
my $seed_mismatch = 2;
my $palindrome_clip_threshold = 30;
my $simple_clip_threshold = 10;
my $LEADING = 3; # Remove low quality bases from the beginning / quality: Specifies the minimum quality required to keep a base
my $TRAILING = 3; # Remove low quality bases from the end. / quality: Specifies the minimum quality required to keep a base

my $windowSize = 4;
my $requiredQuality = 15;
my $SLIDINGWINDOW = "$windowSize:$requiredQuality";
my $MINLEN = 100; # required: readLength
#my $targetLength;
#my $strictness;
#my $MAXINFO = "$targetLength:$strictness";

my $option = "ILLUMINACLIP:$adapter_fa:$seed_mismatch:$palindrome_clip_threshold:$simple_clip_threshold LEADING:$LEADING TRAILING:$TRAILING SLIDINGWINDOW:$SLIDINGWINDOW MINLEN:$MINLEN";

my $r1 = "/gg/data/exome/CDC-173/CDC-173_1.fastq.gz";
my $r2 = "/gg/data/exome/CDC-173/CDC-173_2.fastq.gz";
my $r1_out = "/gg/data/exome/CDC-173/Tool/Trimmomatic/CDC-173_1.trimmomatic.clean.fastq.gz";
my $r2_out = "/gg/data/exome/CDC-173/Tool/Trimmomatic/CDC-173_2.trimmomatic.clean.fastq.gz";
my $r1_un_out = "/gg/data/exome/CDC-173/Tool/Trimmomatic/CDC-173_1.unclean.fastq.gz";
my $r2_un_out = "/gg/data/exome/CDC-173/Tool/Trimmomatic/CDC-173_2.unclean.fastq.gz";

my $command;
#$command = "java -jar $bin PE $general_param $r1 $r2 $r1_out $r1_un_out $r2_out $r2_un_out $option";
$command = "java -jar $bin PE $r1 $r2 $r1_out $r1_un_out $r2_out $r2_un_out $option";
print $command."\n"; 
