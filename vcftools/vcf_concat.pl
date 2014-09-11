#!/usr/bin/perl -w
use strict;
use File::stat;

## Program Info:
#
# Name: vcf concat script
#
# Function: vcf file concat (chromosome) using vcftools
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
#   Version 1.0 (Aug 26, 2014): vcftools 0.1.12a
##

use Getopt::Long;

my ($PATH_tabix,$vcftools);
GetOptions(
	'VCFTOOLS=s' => \$vcftools,
	'TABIX=s' => \$PATH_tabix
);

if (!$vcftools){
	$vcftools = "/BiOfs/hmkim87/BioTools/vcftools/0.1.12a/";
}
if (!$PATH_tabix){
	$PATH_tabix = "/BiOfs/hmkim87/BioTools/tabix/0.2.6";
}

if (@ARGV != 2){
	printUsage();
}

my $INPUT_S = $ARGV[0];
my $VCF_OUT = $ARGV[1];

my $bgzip = $PATH_tabix."/bgzip";
my $tabix = $PATH_tabix."/tabix";

my $LIB_vcftools = $vcftools."/lib/perl5/site_perl";
my $PATH_vcftools = $vcftools."/bin";
my $concat = $PATH_vcftools."/vcf-concat";
my $vcf_sort = $PATH_vcftools."/vcf-sort";

#print "export PATH=$PATH_tabix:\$PATH\n";
$ENV{'PATH'} .= ":".$PATH_tabix;

my @FILES = glob($INPUT_S);
my @FILES_;
for (my $i=0; $i<@FILES; $i++){
	my $filesize = stat($FILES[$i])->size;
	if ($filesize eq 0){
		next;
	}
	push @FILES_, $FILES[$i];
}

for (my $i=0; $i<@FILES_; $i++){
	my $command = "$bgzip -c $FILES_[$i] > $FILES_[$i].gz";
	if (!-f "$FILES_[$i].gz"){
		#print "$command\n";
		system($command);
	}
	if (!-f "$FILES_[$i].gz.tbi"){
		$command = "$tabix -p vcf $FILES_[$i].gz";
		#print "$command\n";
		system($command);
	}
	$FILES_[$i] = $FILES_[$i].".gz";
}

my $infiles = "";
$infiles .= "$_ " foreach @FILES_;

#my $sc = "perl -I $LIB_vcftools $concat $infiles | $bgzip -c > $VCF_OUT";
my $sc = "perl -I $LIB_vcftools $concat $infiles > $VCF_OUT.noSorted";
#print $sc."\n";
system($sc);
#system($sc);

my $command = "cat $VCF_OUT.noSorted | $vcf_sort > $VCF_OUT";
#print $command."\n";
system($command);

sub printUsage{
	print "Usage: perl $0 <\"PATH/*.vcf\"> <out.vcf>\n";
	print "Description: Concatenates VCF files (for example split by chromosome). Note that the input and output VCFs will have the same number of columns, the script does not merge VCFs by position\n";
	exit;
}
