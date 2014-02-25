#!/usr/bin/perl -w

use strict;

my $sickle = "/gg/bio/tools/sickle/sickle";

my $command;
my $type = "pe";

my $r1 = "/gg/data/exome/CDC-173/CDC-173_1.fastq.gz";
my $r2 = "/gg/data/exome/CDC-173/CDC-173_2.fastq.gz";
my $quality_type = "sanger";
my $r1_out = "/gg/data/exome/CDC-173/CDC-173_1.fastq.sickle.clean.fastq";
my $r2_out = "/gg/data/exome/CDC-173/CDC-173_2.fastq.sickle.clean.fastq";
my $trimmed_single_file = "/gg/data/exome/CDC-173/CDC-173.sickle.trimmed_singles_file.fastq";

my $qual_threshold = 20; # default 20
my $length_threshold = 100; # default 20
# -n 
$command = "$sickle $type -f $r1 -r $r2 -t $quality_type -o $r1_out -p $r2_out -s $trimmed_single_file -n -q $qual_threshold -l $length_threshold";
print $command."\n";

=pod
FastQ paired records kept: 32226796 (16113398 pairs)
FastQ single records kept: 4491135 (from PE1: 3060946, from PE2: 1430189)
FastQ paired records discarded: 6008188 (3004094 pairs)
FastQ single records discarded: 4491135 (from PE1: 1430189, from PE2: 3060946)
real    2m35.966s
user    2m28.141s
sys     0m5.740s
===================================
If your have separate files for forward and reverse reads...

Usage: sickle pe -f <paired-end fastq file 1> -r <paired-end fastq file 2> -t <quality type> -o <trimmed pe file 1> -p <trimmed pe file 2> -s <trimmed singles file>

If your have one file with interleaved forward and reverse reads...

Usage: sickle pe -c <combined input file> -t <quality type> -m <combined trimmed output> -s <trimmed singles file>

 Options:
-t, --qual-type, Type of quality values (solexa (CASAVA < 1.3), illumina (CASAVA 1.3 to 1.7), sanger (which is CASAVA >= 1.8)) (required)
-f, --pe-file1, Input paired-end fastq file 1 (optional, must have same number of records as pe2)
-r, --pe-file2, Input paired-end fastq file 2 (optional, must have same number of records as pe1)
-c, --pe-combo, Combined input paired-end fastq (optional)
-o, --output-pe1, Output trimmed fastq file 1 (optional)
-p, --output-pe2, Output trimmed fastq file 2 (optional)
-m, --output-combo, Output combined paired-end fastq file (optional)
-s, --output-single, Output trimmed singles fastq file (required)
-q, --qual-threshold, Threshold for trimming based on average quality in a window. Default 20.
-l, --length-threshold, Threshold to keep a read based on length after trimming. Default 20.
-x, --no-fiveprime, Don't do five prime trimming.
-n, --discard-n, Discard sequences with any Ns in them.
--quiet, do not output trimming info
--help, display this help and exit
--version, output version information and exit
=cut
