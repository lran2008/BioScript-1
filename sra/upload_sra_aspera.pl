#!/usr/bin/perl -w

use strict;

my $ascp = "/home/hmkim87/.aspera/connect/bin/ascp";
my $secure = "/BiOfs/hmkim87/script/sra-3.ppk";
my $option = "-QT -l600m -k1";
my $server = "asp-sra\@upload.ncbi.nlm.nih.gov:incoming";

if (@ARGV != 1){
	printUsage();
}

my $target = $ARGV[0];
my @input = glob($target);

my $count = 0;
for (my $i=0; $i<@input; $i++){
	my $file = $input[$i];
	my $cmd = "$ascp -i $secure $option $file $server";
	print $cmd."\n";
	#system($cmd);
	$count++;
}

print $count."\n";

sub printUsage{
	print "Usage: perl $0 <\"target files\">\n";
	exit;
}
