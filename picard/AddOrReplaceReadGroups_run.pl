#!/usr/bin/perl -w
##
# Function: Picard AddOrReplaceReadGroups Wrapper
# Author: Hyunmin Kim
# Senior Researcher
# Genome Research Foundation
# E-Mail: brandon.kim.hyunmin@gmail.com
#
# History:
# - Version 0.1 ( May 26, 2014)
##

use strict;
use File::Basename;
use Config;
use Getopt::Long;


my ($picard_path,$java_mem_size);
GetOptions(
    'PICARD_PATH=s' => \$picard_path,
    'JAVA_MEM=s' => \$java_mem_size
);

if (!defined $picard_path){
	$picard_path = "/BiOfs/hmkim87/BioTools/picard/1.114";
}

if (!defined $java_mem_size){
	$java_mem_size = "8g";
}

if (@ARGV != 6){
	printUsage();
}


my $AddOrReplaceReadGroups = $picard_path."/AddOrReplaceReadGroups.jar";


my $in_bam = $ARGV[0];
my $out_bam = $ARGV[1];

my ($file_name,$file_path,$file_ext) = fileparse($out_bam, qr/\.[^.]*/);
my $log_file = $file_path.$file_name.".log";

my $SAMPLE_ID = $ARGV[2];
my $LIBRARY = $ARGV[3];
my $PLATFORM = $ARGV[4];
my $BARCODE = $ARGV[5];
AddOrReplaceReadGroups($in_bam,$out_bam,$log_file);

sub AddOrReplaceReadGroups{
	my $INPUT = shift;
	my $OUTPUT = shift;
	my $LOG = shift;
	my $command = "java -Xmx$java_mem_size -jar $AddOrReplaceReadGroups INPUT=$INPUT OUTPUT=$OUTPUT RGSM=$SAMPLE_ID RGLB=$LIBRARY RGPL=$PLATFORM RGPU=$BARCODE VALIDATION_STRINGENCY=LENIENT 2> $LOG";
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
	print "Usage: perl $0 [-J Java memory size $java_mem_size] [-P Picard directory $picard_path] <in.bam> <out.bam> <SAMPLE_ID> <LIBRARY_ID> <PLATFORM> <BARCODE>\n";
	exit;
}
