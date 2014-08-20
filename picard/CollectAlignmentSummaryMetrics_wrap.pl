#!/usr/bin/perl -w

use strict;

my $script = "/BiOfs/hmkim87/BioScript/picard/CollectAlignmentSummaryMetrics.pl";

if (@ARGV != 1){
	printUsage();
}
my $bam_file_pattern = $ARGV[0];

my @bam_files = glob($bam_file_pattern);

use File::Basename; 

my $ref = "/BiOfs/hmkim87/BioResources/Reference/Human/hg19/chrAll.fa";

my $cnt = 1;
foreach my $bam_file (@bam_files){
	my ($filename,$filepath,$fileext) = fileparse($bam_file, qr/\.[^.]*/); 

	my $job_name = $filename."_".$cnt;
	my $cmd = "perl $script -i $bam_file -o $filepath/$filename.CollectAlignmentSummaryMetrics -r $ref -n $job_name";
	print $cmd."\n";
	$cnt++;
}

sub printUsage{
	print "Usage: perl $0 <\"in.bam\">\n";
	exit;
}
