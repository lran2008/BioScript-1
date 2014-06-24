#!/usr/bin/perl
use warnings;
use strict;

## Program Info:
#
# Name: vcf2plink with qsub
#
# Function: Convert vcf to plink (ped,map)
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
#   Version 1.0 (June 24, 2014): first non-beta release.
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
my $vcf_file = shift;
my $out_prefix = shift;

my $tool_config = {
	file => $vcf_file,
	out => $out_prefix,
	app => 'vcf2plink',
};

my $vcf2plink = Brandon::Bio::BioTools::VCFTOOLS->new($tool_config);

my $debug = 1; # no run, just print

my $vcf2plink_q = Brandon::Bio::BioPipeline::Queue->mini($vcf2plink->{command},$debug);
$vcf2plink_q->run();

sub printUsage{
	print "Usage: perl $0 <in.vcf> <out_prefix>\n";
	exit;
}
