#!/usr/bin/perl
use warnings;
use strict;

use Data::Dumper qw(Dumper);
 
## Program Info:
#
# Name: NGSQCTOOLKIT Stat Parser 
#
# Function: ngsqctoolkit report output file (*_stat) parse
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
#   Version 1.0 (May 27, 2014): first non-beta release.
##

if (@ARGV != 1){ printUsage(); }
my $infile_pattern = $ARGV[0];

my @files = glob($infile_pattern);
my %Data;
for (my $i=0; $i<@files; $i++){
	my $file = $files[$i];
	read_ngsqctoolkit_statfile($file,\%Data);
}

my $total_num_reads = 0;
my $total_num_reads_afterFilter = 0;
foreach my $category (keys %Data){
	my $tmp = $Data{$category};

	foreach my $type (keys %$tmp){
		if ($category eq "QC" and $type eq "Total number of reads"){
			$total_num_reads = sum_in_array(\@{$tmp->{$type}});
		}
		if ($category eq "DETAIL" and $type eq "Total number of reads"){
			#print Dumper \@{$tmp->{$type}};
			#print Dumper @{$tmp->{$type}}[0];

			foreach my $entry (@{$tmp->{$type}}){
				my $before_filter =  @$entry[0];
				my $after_filter =  @$entry[1];
				$total_num_reads_afterFilter += $after_filter;
			} 
		}
	}
}
print "Total number of reads : $total_num_reads\n";
print "Total number of reads afterFilter : $total_num_reads_afterFilter\n";

sub sum_in_array{
	my $array_ref = shift;
	my $count = 0;
	foreach (@$array_ref){
		$count += $_;
	}
	return $count;
}

sub read_ngsqctoolkit_statfile{

	my @parameters=(
	"Input file",
	"Primer/Adaptor library", 
	"Cut-off read length for HQ",
	"Cut-off quality score",
	"Only statistics",   
	"Number of CPUs"
	);

	my @QC_statistics=(
	"File name",
	"Total number of reads",
	"Total number of HQ reads",
	"Percentage of HQ reads",
	"Total number of bases",
	"Total number of bases in HQ reads",
	"Total number of HQ bases in HQ reads",
	"Percentage of HQ bases in HQ reads",
	"Number of Primer/Adaptor contaminated HQ reads",
	"Total number of HQ filtered reads",
	"Percentage of HQ filtered reads"
	);

	my $infile = shift;
	my $hash_p = shift;
	open my $fh, '<:encoding(UTF-8)', $infile or die;
	my $key;
	while (my $row = <$fh>) {
		chomp $row;

		if ($row =~ /^Average/){ last; }

		if ($row !~ /^\s+/){
			$key = $row;
			next;
		}


		if ($key eq "Parameters"){
			foreach my $type (@parameters){
				if ($row =~ /$type/){
					$row =~ /$type\s+(.+)/;
					my $value = $1;
					#print "$type -> $value\n";
					push @{$hash_p->{"PARAM"}{$type}}, $value;
				}
			}

		}

		if ($key eq "QC statistics"){
			foreach my $type (@QC_statistics){
				if ($row =~ /$type/){
					$row =~ /$type\s+(.+)/;
					my $value = $1;
					#print "$type -> $value\n";
					push @{$hash_p->{"QC"}{$type}}, $value;
				}
			}
		}

		if ($key eq "Detailed QC statistics"){

			my @arr = split /\s{2,}/, $row;
			my $type = $arr[1];
			my $val1 = $arr[2];
			my $val2 = $arr[3];
			push @{$hash_p->{"DETAIL"}{$type}}, [$val1,$val2];	
		}
		#print "$key\t$row\n";

	}
	close($fh);
}

sub printUsage{
	print "Usage: perl $0 <\"*_stat\">\n";
	exit;
}
