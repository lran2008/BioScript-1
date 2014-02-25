#!/usr/bin/perl -w

use strict;
use File::Basename; 

if (@ARGV != 1){
	printUsage();
}
my $file_pattern = $ARGV[0];

my @files = glob($file_pattern);

foreach my $file (@files){
	my ($filename,$filepath,$fileext) = fileparse($file, qr/\.[^.]*/); 
	if (-f $filepath.$filename){
		next;
	}
	my $sh_script = "$filepath/$filename.sh";
	my $sh_command = "gzip -d -c $file > $filepath$filename";
	write_qsub_script($sh_script,$sh_command);
	my $sh_err = "$filepath/$filename.err";
	my $sh_out = "$filepath/$filename.out";
	run_qsub_script($sh_script,$sh_err,$sh_out);
}

sub run_qsub_script{
        my $q_sh = shift;
        my $q_err = shift;
        my $q_out = shift;
        my $command = "qsub -e $q_err -o $q_out $q_sh";
        print $command."\n";
} 

sub write_qsub_script{
        my $sh = shift;
        my $command = shift;
        open my $fh, '>:encoding(UTF-8)', $sh or die;
        print $fh "#\$ -S /bin/sh\n";
        print $fh "date\n";
        print $fh $command."\n";
        print $fh "date\n";
        close($fh);
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

