#!/usr/bin/perl
use warnings;
use strict;

## Program Info:
#
# Name:
#
# Function:
#
# Author: Hyunmin Kim
#  Copyright (c) Theragen Bio Institute, 2014,
#  all rights reserved.
#
# Licence: This script may be used freely as long as no fee is charged
#    for use, and as long as the author/copyright attributions
#    are not removed.
#
# History:
#   Version 1.0 (Aug 25, 2014): first non-beta release.
##

use File::Basename;
use Cwd qw(abs_path);
use Data::Dumper;

use Getopt::Long;

my $TOOL_PATH;
GetOptions(
    'BEDTOOLS=s' => \$TOOL_PATH
);

if (!defined($TOOL_PATH)){
    $TOOL_PATH = "/BiOfs/hmkim87/BioTools/bedtools/2.20.1";
}

my $sortBed = "$TOOL_PATH/bin/sortBed";
my $mergeBed = "$TOOL_PATH/bin/mergeBed";

if (@ARGV != 1){
	printUsage();
}
my $in_bed_pattern = $ARGV[0];
my @files = glob($in_bed_pattern);

my $bed_file_list = join " ", @files;

my $command = "cat $bed_file_list | $sortBed | $mergeBed -i stdin";
print $command."\n";

sub printUsage{
    print "Usage: perl $0 [-S BEDTOOLS Directory $TOOL_PATH] <\"in*.bam\">\n";
    exit(0);
}
