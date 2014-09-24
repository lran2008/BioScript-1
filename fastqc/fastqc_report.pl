#!/usr/bin/perl
use warnings;
use strict;

if (@ARGV != 1){ printUsage();}

## Program Info:
#
# Name: FastQC Report 
#
# Function: fastqc result -> report
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
#   Version 1.0 (May 15, 2014) : support FastQC version 0.10.1 (http://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
##

# Future Plan
# Overrepresented sequences check!
# grep "TruSeq" */*_fastqc/fastqc_data.txt  | less -S

my $fastqc_data_file_pattern = $ARGV[0];
#$fastqc_data_file_pattern = "/BiO/hmkim87/PAPGI/WGS/SRP001453/Result/Raw_FastQC/*/*_fastqc/fastqc_data.txt";

my @files = glob($fastqc_data_file_pattern);
if ($#files < 0){ die; }

my $total_seq = 0;
print "# Filename\tEncoding\tTotal Sequences\tSequence length\t\%GC\n";
foreach my $file (@files){
	my %result_ = parse_fastqc_data_file($file);

	# print
	my @line_;
	push @line_, $result_{"Filename"};
	push @line_, $result_{"Encoding"};
	push @line_, $result_{"Total Sequences"};
	push @line_, $result_{"Sequence length"};
	push @line_, $result_{"\%GC"};

	my $line = join "\t", @line_;
	print $line."\n";

	$total_seq += $result_{"Total Sequences"};
}
print "Total Sequences\t$total_seq\n";

sub parse_fastqc_data_file{
	my $infile = $_[0];

	open my $fh, '<:encoding(UTF-8)', $infile or die;
	my %hash;
	while (my $row = <$fh>) {
		chomp $row;
		if ($row =~ /^Filename/ or $row =~ /^Encoding/ or $row =~ /^Total Sequences/ or $row =~ /^Sequence length/ or $row =~ /^\%GC/){
			my @l = split /\t/, $row;
			my $key = $l[0];
			my $value = $l[1];
			$hash{$key} = $value;	
		}
	}
	close($fh);

	return %hash;
}

sub printUsage{
	print "Usage: perl $0 \"FastQC_result/*/fastqc_data.txt\"\n";
	exit;
}
