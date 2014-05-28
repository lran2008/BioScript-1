#!/usr/bin/perl -w

use strict;

if (@ARGV != 2){
	printUsage();
}
my $sra_file = $ARGV[0];
my $out_dir = $ARGV[1];

my $fastq_dump = "/BiOfs/hmkim87/BioTools/sratoolkit/2.3.5-2_CentOS/bin/fastq-dump";

my $cmd_sra2fastq = sra2fastq($sra_file,$out_dir);

sub sra2fastq{
	my $infile = $_[0];
	my $out_path = $_[1];
	if (!-d $out_path){
		system("mkdir -p $out_path") and die;
	}
	my $command = "$fastq_dump $infile -O $out_path";
	print $command."\n";
	system($command);
}

sub printUsage{
	print "usage: perl $0 <in.sra> <out directory>\n";
	exit;
}
