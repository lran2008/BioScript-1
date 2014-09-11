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

use lib (dirname abs_path $0) . '/lib';

use Queue;

use Data::Dumper;

my ($VCFTOOLS,$SAMTOOLS,$BOWTIE_PATH);

use Getopt::Long;

GetOptions(
	'VCFTOOLS=s' => \$VCFTOOLS,
	'SAMTOOLS=s' => \$SAMTOOLS,
	'BOWTIE=s' => \$BOWTIE_PATH,
);

if (!$SAMTOOLS){
	$SAMTOOLS = "/BiOfs/hmkim87/BioTools/samtools/0.1.19_CentOS/samtools";
}
if (!$VCFTOOLS){
	$VCFTOOLS = "/BiOfs/hmkim87/BioTools/vcftools/0.1.12b/bin/vcftools";
}
if (!$BOWTIE_PATH){
	$BOWTIE_PATH = "/BiOfs/hmkim87/BioTools/bowtie/1.1.0-linux-x86_64";	
}

my $file_pattern = $ARGV[0];

my @files = glob($file_pattern);

if (@ARGV != 1){
	printUsage();
}

# main routine
foreach my $file (@files){
	if ($file =~ /\.bam$/){
		bam_index($file);
	}elsif ($file =~ /\.vcf$/){
		vcf_index($file);
	}elsif ($file =~ /\.fa$/ or $file =~ /\.fasta$/){
		bowtie_index($file);
		#bwa_index($file);
	}else{
		warn "not support this file <$file>\nplease contact developer\n";
	}
}

sub bowtie_index{
	my $infile = shift;
	my ($filename,$filepath,$fileext) = fileparse($infile, qr/\.[^.]*/);
	my $tool_conf = {
		bowtie_path => $BOWTIE_PATH,
		app => 'index',
		input => $infile,
		output => $filepath."/".$filename
	};

	my $bowtie_build = $tool_conf->{bowtie_path}."/bowtie-build";
	my @cmd_set;
	push @cmd_set, $bowtie_build;
	push @cmd_set, $tool_conf->{input};
	push @cmd_set, $tool_conf->{output};

	my $command = join " ", @cmd_set;
	print $command."\n";
}

sub bam_index{
	my $infile = shift;
	my ($filename,$filepath,$fileext) = fileparse($infile, qr/\.[^.]*/);
	my $tool_conf = {
		samtools => undef,
		app => 'bam_index',
		input => $infile,
	};
#	my $job = Brandon::Bio::BioTools::SAMTOOLS->new($tool_conf);

#	my $debug = 0;	
#	my $q_job = Brandon::Bio::BioPipeline::Queue->new($job,$debug);
#	$q_job->run();
	
}

sub vcf_index{
	warn "no support vcf files\n";
}

sub printUsage{
	print "usage: perl $0 [-V $VCFTOOLS] [-S $SAMTOOLS] [-B $BOWTIE_PATH] <\"in.file.pattern\">\n";
	exit;
}
