#!/usr/bin/perl -w

use strict;
use File::Basename;

if (@ARGV != 1){
	printUsage();
}
my $file_pattern = $ARGV[0];
#my $file_pattern = "/BiO/BioProjects/PGI-KOREF1-Genome-2013-06/KOREF1_Draft/0.Rawdata/*.gz";
my @files = glob($file_pattern);

print "filename_1\tfilename_2\n";
my @fastq_files = sort @files;
my $num_f = @fastq_files;
foreach my $i ( 0 .. ($num_f/2)-1 ){
	my $r1 = $fastq_files[2*$i]; # read1 fastq
	my ($r1_name,$r1_dir,$r1_ext) = fileparse($r1, qr/\.[^.]*/);
	my $r2 = $fastq_files[2*$i+1]; # read2 fastq
	my ($r2_name,$r2_dir,$r2_ext) = fileparse($r2, qr/\.[^.]*/);
	print "$r1\t$r2\n";
}

sub printUsage{
	print "Usage: perl $0 <file_pattern>\n";
	exit;
}
