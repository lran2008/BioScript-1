#!/usr/bin/perl -w

use strict;

my $script = "/BiO/hmkim87/OTG-snpcaller/Script/vcfsorter.pl";
my $genome_dict = "/BiOfs/jinsilhanna/BioResources/References/Human/hg19/hg19.dict";

my $in_file_pattern = "/BiO/hmkim87/OTG-snpcaller/Data/SampleVCF/*/*.filter.vcf";

my @files = glob($in_file_pattern);

foreach my $file (@files){
	my $in_vcf = $file;
	my $tmp_vcf = $file.".tmp";
	my $out_vcf = $file;

	my $command = "perl $script $genome_dict $in_vcf > $tmp_vcf";
	system($command);
	$command = "mv $tmp_vcf $out_vcf";
	system($command);
}

