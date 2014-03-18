#!/usr/bin/perl -w

if (@ARGV != 2){
	printUsage();
}
my $in_bed = $ARGV[0];
my $out_dir = $ARGV[1];

if (!-d $out_dir){
	system("mkdir -p $out_dir");
}
chdir $out_dir;
my $command = "cat $in_bed | split -d -a 3 -l 1000 - part";
system($command);

sub printUsage{
	print "Usage: perl $0 <in.bed> <out directory>\n";
	exit;
}

