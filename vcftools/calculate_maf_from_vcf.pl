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
#   Version 1.0 (July 1, 2014): first non-beta release.
##

use File::Basename;
use Cwd qw(abs_path);
use lib '/BiOfs/BioPeople/brandon/language/perl/lib/';

use Brandon::Bio::BioTools::VCFTOOLS;
use Brandon::Bio::BioPipeline::Queue;

use Data::Dumper;

if (@ARGV != 2){
	printUsage();
}

my $vcf_file = $ARGV[0];
my $out_file = $ARGV[1];

my $tool_config={
	file => $vcf_file,
	app => 'freq',
	out => $out_file,
};
my $cal_maf = Brandon::Bio::BioTools::VCFTOOLS->new($tool_config);

my $debug = 1;

my $job_cal_maf = Brandon::Bio::BioPipeline::Queue->mini($cal_maf,$debug);
$job_cal_maf->run();

sub printUsage{
	print "usage: perl $0 <in.vcf> <out_prefix>\n";
	print "description: out_prefix.frq\n";
	exit;
}
