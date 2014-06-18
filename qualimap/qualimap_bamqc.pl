#!/usr/bin/perl
use warnings;
use strict;

use Getopt::Long;

## Program Info:
#
# Name:
#
# Function:
#
# Author: Hyunmin Kim
#  Copyright (c) Genome Research Foundation, 2014,
#  all rights reserved.
#
# Licence: This script may be used freely as long as no fee is charged
#    for use, and as long as the author/copyright attributions
#    are not removed.
#
# History:
#   Version 1.0 (May 16, 2014): first non-beta release.
#   Version 1.1 (June 2, 2014): add supported Java heap size
##

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib '/BiOfs/BioPeople/brandon/language/perl/lib/';

use Brandon::Bio::BioTools qw($qualimap);

$qualimap = "/BiOfs/hmkim87/BioTools/QualiMap/qualimap-build-12-06-14/qualimap";

my $MEM_size_java;
my $THREAD;
GetOptions(
	'MEM_SIZE=s' => \$MEM_size_java,
	'THREAD=s' => \$THREAD
);

if (!defined $MEM_size_java){
	$MEM_size_java = '10g';
}
if (!defined $THREAD){
	$THREAD = 4;
}

if (@ARGV != 2){
	printUsage();
}


my $input = $ARGV[0];
my $out_dir = $ARGV[1];
my $cmd = qualimap($input,$out_dir);
print "$cmd\n";
system($cmd);

sub qualimap{
	my $in_bam = shift;
	my $out_dir = shift;
	my $out_coverage_file = "$out_dir/coverage.txt";
	my $out_report = "$out_dir/report.pdf";
	my $command = "$qualimap --java-mem-size=$MEM_size_java bamqc -bam $in_bam --gd HUMAN -nt $THREAD -outcov $out_coverage_file -outdir $out_dir -outfile $out_report";
	return $command;
}

sub printUsage{
	print "Usage: perl $0 [-T THREAD $THREAD] [-M JAVA MEM SIZE $MEM_size_java] <in.bam> <out directory>\n";
	exit;
}
