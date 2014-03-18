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
#my $bam_file_pattern = "/BiO3/BioProjects/KRISS-Korean-Reference-2013-05/Analyses/Insert_Size_Calculation/mapping_bwa/*.bam";

my @files = glob($bam_file_pattern);

foreach my $file (@files){
	my ($filename,$filepath,$fileext) = fileparse($file, qr/\.[^.]*/);
	my $sc = "perl $ROOT/CollectInsertSizeMetrics.pl $file /BiOfs/BioResources/References/Human/hg19/BWA_0.7.7_Index/hg19.fa";
	my $job_script_name = "$filepath/$filename.CollectInsertSizeMetrics.sh";
	my $job_script_out = "$filepath/$filename.filename.CollectInsertSizeMetrics.o";
	writeScript($job_script_name,$sc,$filename,$job_script_out);
	runScript($job_script_name);
}

sub runScript{
        my $q_sh = shift;
        #my $q_err = shift;
        #my $q_out = shift;
        #my $jobname = shift;
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
