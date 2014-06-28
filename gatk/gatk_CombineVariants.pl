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
#   Version 1.0 (June 28, 2014): first non-beta release.
##

use File::Basename;
use Cwd qw(abs_path);
use lib '/BiOfs/BioPeople/brandon/language/perl/lib/';

use Brandon::Bio::BioTools qw($GATK);
#use Brandon::Bio::BioPipeline::Project;
#use Brandon::Bio::BioPipeline::ProcessData;
use Brandon::Bio::BioTools::GATK;
#use Brandon::Bio::BioPipeline::Queue;

use Data::Dumper;

use XML::Simple;
use Getopt::Long;

=pod
 java -Xmx2g -jar GenomeAnalysisTK.jar \
   -R ref.fasta \
   -T CombineVariants \
   --variant input1.vcf \
   --variant input2.vcf \
   -o output.vcf \
   -genotypeMergeOptions UNIQUIFY

 java -Xmx2g -jar GenomeAnalysisTK.jar \
   -R ref.fasta \
   -T CombineVariants \
   --variant:foo input1.vcf \
   --variant:bar input2.vcf \
   -o output.vcf \
   -genotypeMergeOptions PRIORITIZE
   -priority foo,bar
=cut

my $aa_vcf = "/home/brandon/a.vcf";
my $bb_vcf = "/home/brandon/b.vcf";
my $ref_fasta = "/BiOfs/hmkim87/BioResources/Reference/Human/hs37d5/chrAll.fa";
my @input_vcf;
push @input_vcf, $aa_vcf;
push @input_vcf, $bb_vcf;

my $param = "-genotypeMergeOptions UNIQUIFY";

my $outfile = "/home/brandon/merged.gatk.vcf";

my $gatk_config = {
	input_file => \@input_vcf,
	output => $outfile,
	reference_sequence => $ref_fasta,
	app => "CombineVariants",
	param => $param, 
};
my $combine_vcf = Brandon::Bio::BioTools::GATK->new($gatk_config);
print Dumper $combine_vcf;
