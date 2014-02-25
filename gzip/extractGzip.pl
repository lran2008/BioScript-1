#!/usr/bin/perl -w

use strict;
use File::Basename; 
use Config;

# check perl threads
$Config{usethreads} or die "Recomplie Perl with threads to run this program.";
use threads;

if (@ARGV != 1){
	printUsage();
}
my $file_pattern = $ARGV[0];

my @files = glob($file_pattern);

my @thread;
foreach my $file (@files){
	my ($filename,$filepath,$fileext) = fileparse($file, qr/\.[^.]*/); 
	if (-f $filepath.$filename){
		next;
	}
	$_ = threads->new(\&runCommand, "gzip -d -c $file > $filepath$filename");
	push @thread, $_;
}


foreach (@thread){
	my $t_res = $_ -> join;
} 

sub runCommand{
	my $command = shift;
	print $command."\n";
	system($command);
}

sub printUsage{
	print "Usage: perl $0 <file_pattern>\n";
	exit;
}

