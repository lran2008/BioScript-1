#!/usr/bin/perl
use warnings;
use strict;

## Program Info:
#
# Name: File Indexer
#
# Function: bam, vcf.. etc files indexing..
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
#   Version 1.0 (July 21, 2014): first non-beta release.
##

use File::Basename;
use Cwd qw(abs_path);
use lib '/BiOfs/BioPeople/brandon/language/perl/lib/';

use Brandon::Bio::BioTools::SAMTOOLS;
use Brandon::Bio::BioPipeline::Queue;

use Data::Dumper;


if (@ARGV != 1){
	printUsage();
}
my $file_pattern = $ARGV[0];

my @files = glob($file_pattern);


foreach my $file (@files){
	if ($file =~ /\.bam$/){
		bam_index($file);
	}elsif ($file =~ /\.vcf$/){
		vcf_index($file);
	}else{
		warn "not support this file <$file>\nplease contact developer\n";
	}
}

sub bam_index{
	my $infile = shift;

	my $tool_conf = {
		samtools => undef,
		app => 'bam_index',
		input => $infile,

	};
	my $job = Brandon::Bio::BioTools::SAMTOOLS->new($tool_conf);

	my $debug = 0;	
	my $q_job = Brandon::Bio::BioPipeline::Queue->new($job,$debug);
	$q_job->run();
	
}

sub vcf_index{
	warn "no support vcf files\n";
}

sub printUsage{
	print "usage: perl $0 <\"in.file.pattern\">\n";
	exit;
}
