#!/usr/bin/perl -w

use strict;
use File::Basename;
use Cwd 'abs_path';

if (@ARGV != 1){
	printUsage();
}
my $PWD = dirname(__FILE__);
my $ROOT = abs_path($PWD);

my $bam_file_pattern = $ARGV[0];

my @files = glob($bam_file_pattern);

my $script = "$ROOT/SortSam.pl";

foreach my $file (@files){
	my ($filename,$filepath,$fileext) = fileparse($file, qr/\.[^.]*/);

	my $infile = $file;
	my $outfile = "$filepath/$filename.sorted$fileext";

	my $cmd = "perl $script $infile $outfile";

	my $job_script_name = "$filepath/$filename.SortSam.sh";
	my $job_script_out = "$filepath/$filename.SortSam.o";
	writeScript($job_script_name,$cmd,$filename,$job_script_out);
	runScript($job_script_name);
}

sub runScript{
        my $q_sh = shift;
        my $dependency_job = shift;

        my $command;
        if ($dependency_job){
                $command = "qsub -hold_jid $dependency_job $q_sh";
        }else{
                $command = "qsub $q_sh";
        }
        print "$command\n";
        system($command);
}

sub writeScript{
        my $filename = shift;
        my $command = shift;
        my $q_name = shift;
        my $logfile = shift;
        my $cpu = shift;

        my @cmd_set;
        push @cmd_set, "#!bin/sh";
        push @cmd_set, "#\$ -q all.q";
        push @cmd_set, "#\$ -N $q_name";
        push @cmd_set, "#\$ -o $logfile";
        push @cmd_set, "#\$ -j y";
        push @cmd_set, "#\$ -S /bin/bash";
        push @cmd_set, "#\$ -cwd";
        push @cmd_set, "#\$ -V";
        if (defined $cpu){ push @cmd_set, "#\$ -pe smp $cpu"; }
        push @cmd_set, "hostname -a";
        push @cmd_set, "date";
        push @cmd_set, $command;
        push @cmd_set, "date\n";
        my $content = join "\n", @cmd_set;
        if (open(my $fh, '>:encoding(UTF-8)', $filename)) {
                print {$fh} $content;
                close($fh);
        }
}

sub printUsage{
	print "Usage: perl $0 <\"in.bam.pattern\">\n";
	exit; 
}
