#!/usr/bin/perl -w

use strict;

use File::Basename; 

my $script = "/BiOfs/hmkim87/BioScript/qseq/qseq2fastq.pl";

my $pattern_qseq_file = $ARGV[0];
my $outdir = "/BiO3/BioProjects/SMU-Potato-SmallRNA-2014-09/Data/fastq/";

my @qseq_files = glob($pattern_qseq_file);

foreach my $qseq_file (@qseq_files){
	my ($filename,$filepath,$fileext) = fileparse($qseq_file, qr/\.[^.]*/);
	my $command = "perl $script $qseq_file > $outdir/$filename.fastq";
	print $command."\n";
}
