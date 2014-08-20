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
#  Copyright (c) Genome Research Foundation, 2014,
#  all rights reserved.
#
# Licence: This script may be used freely as long as no fee is charged
#    for use, and as long as the author/copyright attributions
#    are not removed.
#
# History:
#   Version 1.0 (June 8, 2014): first non-beta release.
##

# future
#my $command = "$genomeCoverageBed -ibam $input_bam -g $genome > $out"; 

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib '/BiOfs/BioPeople/brandon/language/perl/lib/';

use Brandon::General qw(say RoundXL);
use Brandon::Bio::BioTools qw($SAMTOOLS $GATK $PICARD_PATH $BWA $VCFTOOLS_PATH $VCFTOOLS_LIB_PATH $BEDTOOLS_PATH $JAVA $qualimap $SNPEFF_PATH);

use Data::Dumper;

if (@ARGV !=2){
	printUsage();
}
my $infile = $ARGV[0];

my %Data;
read_genomecov($infile,\%Data);

#print Dumper %Data;

my $targetX = $ARGV[1];
#print "# Target $targetX depth\n";
foreach my $chrName (sort keys %Data){
	#print Dumper $chrName;
	foreach my $chrSize (keys %{$Data{$chrName}}){

	my @arr = @{$Data{$chrName}{$chrSize}};
	
	my $sum_depth = getXdepthFromArray($targetX,\@arr);

	my $average_depth = $sum_depth/$chrSize;
	$average_depth = &RoundXL($average_depth,2);
	print $chrName."\t".$sum_depth."\t".$chrSize."\t".$average_depth."\n";
	}
}

sub getXdepthFromArray{
	my $val = shift;
	my $array_ = shift;

	my @arr = @$array_;
	my $sum = 0;
	for (my $i=0; $i<@arr; $i++){
		if ($i < $val){
			next;
		}
		my $target_depth = $i*$arr[$i];
		$sum += $target_depth;
	}
	return $sum;
}

sub read_genomecov{
	my $file = shift;
	my $hash_p = shift;
	open my $fh, '<:encoding(UTF-8)', $file or die;
	my $sum_depth = 0;
	while (my $row = <$fh>) {
        	chomp $row;
		my @l = split /\t/, $row;
		
		my $chr = $l[0];

		my $idx_depth = $l[1];
		my $count = $l[2];
		my $chr_size = $l[3];
		push @{$hash_p->{$chr}{$chr_size}}, $count;

		
	}
	close($fh);
}

sub printUsage{
	print "Usage: perl $0 <bedtools.genomecov> <targetX>\n";
	print "Description: targetX-> upper 1\n";
	exit;
}
