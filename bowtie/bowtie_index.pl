#!/usr/bin/perl
use warnings;
use strict;

## Program Info:
#
# Name: bowtie index
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
#   Version 1.0 (July 10, 2014): first non-beta release.
##

use File::Basename;
use Cwd qw(abs_path);
#use lib '/BiOfs/BioPeople/brandon/language/perl/lib/';
#use Brandon::Bio::BioTools qw($BOWTIE_PATH);

#my $bowtie_build = "/BiO/hmkim87/BioTools/bowtie/1.0.1-linux-x86_64/bowtie-build";
my $bowtie_build = "/BiOfs/hmkim87/BioTools/bowtie/1.0.1-linux-x86_64/bowtie-build";

if (@ARGV != 1){
	printUsage();
}
my $in_fasta = $ARGV[0];

my ($filename,$filepath,$fileext) = fileparse($in_fasta, qr/\.[^.]*/);

if ($in_fasta =~ /\.gz$/){
	my $cmd_extract_gzip = "gzip -d -c $in_fasta > $filepath$filename";
	print $cmd_extract_gzip."\n";
	system($cmd_extract_gzip);
	$in_fasta =~ s/\.gz$//;
}

($filename,$filepath,$fileext) = fileparse($in_fasta, qr/\.[^.]*/);

my $out_dir = $filepath."/bowtie_index";
if (!-d $out_dir){
	system("mkdir $out_dir");
}

my $command = $bowtie_build." ".$in_fasta." ".$out_dir."/".$filename;
print $command."\n";
system($command);

chdir $out_dir;

$command = "ln -s ../$filename$fileext ./";
print $command."\n";
system($command);

sub printUsage{
	print "Usage: perl $0 <in.fa|in.fa.gz>\n";
	exit;
}
