#!/usr/bin/perl -w

use strict;
use Data::Dumper qw(Dumper);


my $bin = "/gg/bio/tools/annovar/annotate_variation.pl";
my $database_path = "/gg/reference/annovar/humandb";

# Test Download
#my $db = "1000g2012feb";
#annovar_down_db("hg19",$db,$database_path);
#die;

my %hash = ();
my @refGene_set = ("_refGeneMrna.fa","_refGene.txt","_refLink.txt");
my @avsift_set = ("_avsift.txt","_avsift.txt.idx");
my @cosmic67_set = ("_cosmic67.txt","_cosmic67.txt.idx");
my @cosmic67wgs_set = ("_cosmic67wgs.txt","_cosmic67wgs.txt.idx");
my @esp5400_set = ("_esp5400_aa.txt","_esp5400_aa.txt.idx");
my @_1000g2012feb = ("_ALL.sites.2012_02.txt","_ALL.sites.2012_02.txt.idx");
push @{$hash{"refGene"}}, @refGene_set;
push @{$hash{"avsift"}}, @avsift_set;
push @{$hash{"cosmic67"}}, @cosmic67_set;
push @{$hash{"cosmic67wgs"}}, @cosmic67wgs_set;
push @{$hash{"esp5400"}}, @esp5400_set;
push @{$hash{"1000g2012feb"}}, @_1000g2012feb;

my @arr = qw(refGene avsift cosmic67 cosmic67wgs esp5400 1000g2012feb);

foreach my $target_db (@arr){
	if (annovar_db_check("hg19",$target_db,$database_path)){
		annovar_down_db("hg19",$target_db,$database_path);
	}
}

sub annovar_down_db{
	my $buildver = shift;
	my $downdb = shift;
	my $db_path = shift;

	my $param = "-buildver $buildver -webfrom annovar -downdb $downdb $db_path";
	my $command = "perl $bin $param";
	print $command."\n";
	system($command);
}

sub annovar_db_check{
	my $buildver = shift;
	my $downdb = shift;
	my $db_path = shift;

	if (defined $hash{$downdb}){
		foreach (@{$hash{$downdb}}){
			my $targetFile = $db_path."/".$buildver.$_;
			if (!-f $targetFile){
				print "$downdb\t$targetFile\n";
				return 0;
			}
		}
	}else{
		die "ERROR! not recognize the db_type <$downdb>\n";
	}
}
