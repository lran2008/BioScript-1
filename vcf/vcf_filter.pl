#!/usr/bin/perl -w

use strict;

#my $in_vcf = $ARGV[0];
#my $in_bed = $ARGV[1];

#my $in_vcf = "/BiO/BioProjects/PGI-PAPGI-Genome-2012-08/Analyses/WES.MultiSampleCalling.with.gATK/WES.MultiSampleCalling.with.gATK_SAMPLE_VCF/T1304D2113.vcf";
my $in_tsv = "/BiO/BioProjects/PGI-PAPGI-Genome-2012-08/Analyses/WES.MultiSampleCalling.with.gATK/WES.MultiSampleCalling.with.gATK_SAMPLE_TSV/T1304D2113.tsv";
my $in_bed = "/BiO/hmkim87/BED/SureSelect_Human_All_Exon_V4/S03723314_Covered.NoOverlap.ChrName.slop_10.bed";

my %regions = read_bedfile($in_bed);

#open(DATA, $in_vcf);
open(DATA, $in_tsv);
while(<DATA>){
	chomp;
	my @l = split /\t/, $_;
	my $chr = $l[0];
	my $pos = $l[1];
	my $gt = $l[7]; ### only tsv

	my $flag = check_target($chr,$pos);

	if ($flag == 0){
		next;
	}else{
		print "$chr\t$pos\t$gt\n";
	}
}
close(DATA);

sub check_target{
	my $chr = shift;
	my $pos = shift;

	if (defined $regions{$chr}){
		foreach my $region (@{$regions{$chr}}){
			my @l = split /\-/, $region;
			my $start = $l[0];
			my $end = $l[1];
			if ($pos >= $start and $pos <= $end){
				return 1;
			}
		}
		return 0;
	}else{
		return 0;
	}
}

sub read_bedfile{
	my $file = shift;
	open(DATA, $file);
	my %hash;
	while(<DATA>){
		chomp;
		if ($_ =~ /^#/){
			next;
		}
		my @l = split /\t/, $_;
		my $chr = $l[0];
		my $start = $l[1];
		my $end = $l[2];
		my $region = $start."-".$end;
		
		push @{$hash{$chr}}, $region;
	}
	close(DATA);
	return %hash;
}
