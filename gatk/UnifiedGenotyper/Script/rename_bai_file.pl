#!/usr/bin/perl -w

use strict;

use File::Basename; 

my $target_path = "/BiO/hmkim87/PAPGI/BAM_FILE";

my @bai_files = glob("$target_path/*.bai");

foreach my $bai_file (@bai_files){
	my ($filename,$filepath,$fileext) = fileparse($bai_file, qr/\.[^.]*/);
	$filename =~ s/\.final\.bam//;
	my $sc = "ls /BiO/hmkim87/PAPGI/BAM_FILE/*_$filename.bam";
	my $result = `$sc`;
	chomp($result);

	my $command = "mv $bai_file $result.bai";
	print $command."\n";

}
