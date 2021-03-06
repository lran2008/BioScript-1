#!/usr/bin/perl -w
##
# Function: Picard CollectAlignmentSummaryMetrics Wrapper
# Author: Hyunmin Kim
# Senior Researcher
# Genome Research Foundation
# E-Mail: brandon.kim.hyunmin@gmail.com
#
# History:
# - Version 0.1 ( Apr 11, 2014)
# - Version 0.2 ( May 26, 2014)
##

use strict;
use File::Basename;
use Config;
use Getopt::Long;


# check perl threads
$Config{usethreads} or die "Recomplie Perl with threads to run this program.";
use threads;

my $picard_path;
GetOptions(
    'PICARD_PATH=s' => \$picard_path
);

if (!defined $picard_path){
	$picard_path = "/BiOfs/hmkim87/BioTools/picard/1.114";
}

if (@ARGV != 2){
	printUsage();
}

my $bam_pattern = $ARGV[0];
my $REFERENCE_SEQUENCE = $ARGV[1];

my $CollectAlignmentSummaryMetrics = "$picard_path/CollectAlignmentSummaryMetrics.jar";

my @bam_files = glob($bam_pattern);
my @thread;
foreach my $bam_file (@bam_files){
	my ($file_name,$file_path,$file_ext) = fileparse($bam_file, qr/\.[^.]*/);
	my $out_metrics = $file_path.$file_name.".CollectAlignmentSummaryMetrics";
	my $out_log = $file_path.$file_name.".CollectAlignmentSummaryMetrics.log";
	$_ = threads->new(\&CollectAlignmentSummaryMetrics,$bam_file,$out_metrics,$out_log);
	push @thread, $_;
}

foreach (@thread){
	my $t_res = $_ -> join;
}

sub CollectAlignmentSummaryMetrics{
	my $INPUT = shift;
	my $OUTPUT = shift;
	my $LOG = shift;
	my $command = "java -jar $CollectAlignmentSummaryMetrics INPUT=$INPUT OUTPUT=$OUTPUT REFERENCE_SEQUENCE=$REFERENCE_SEQUENCE ASSUME_SORTED=false VALIDATION_STRINGENCY=LENIENT 2> $LOG";
	#my $command = "java -jar $CollectAlignmentSummaryMetrics INPUT=$INPUT OUTPUT=$OUTPUT ASSUME_SORTED=false";
	print $command."\n";
	system($command);
}

sub checkFile{
        my $file = shift;
        if (!-f $file){
                die "ERROR! not found <$file>\n";
        }
}

sub printUsage{
	print "Usage: perl $0 [-P Picard directory $picard_path] <\"in*.bam\"> <reference.fasta>\n";
	print "Example: perl $0 \"/BiO/T*.bam\" /BiOfs/hmkim87/BioResources/Reference/Human/hg19/chrAll.fa\n";
	exit;
}
