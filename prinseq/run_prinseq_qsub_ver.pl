#!/usr/bin/perl -w

use strict;

use File::Basename;
use Cwd 'abs_path';
#use Config;

if (@ARGV != 2){
	printUsage();
}

my $info_tsv = $ARGV[0];
my $proj = $ARGV[1];
checkDir($proj);

my $PWD = dirname(__FILE__);
my $ROOT = abs_path($PWD);  

# tool	
#my $prinseq_path = "$ROOT/prinseq-lite-0.20.4";
my $prinseq_path = "/BiOfs/BioTools/prinseq-lite-0.20.4/";
#my $fastqc = "/nG/Process/Tools/FastQC/fastqc_v0.10.1/fastqc";
my $fastqc = "/BiOfs/BioTools/FastQC/FastQC_v0.10.1/fastqc";

my @input_files = read_input_set($info_tsv);

# check perl threads
#$Config{usethreads} or die "Recomplie Perl with threads to run this program.";
#use threads;

my $output_dir = "$proj/OUTPUT";
checkDir($output_dir);
my @thread;
foreach my $input_file_set (@input_files){
	my $r1_read = (split /\t/, $input_file_set)[0];
	my $r2_read = (split /\t/, $input_file_set)[1];

	my ($r1_filename,$r1_filepath,$r1_fileext) = fileparse($r1_read, qr/\.[^.]*/);
	my ($r2_filename,$r2_filepath,$r2_fileext) = fileparse($r2_read, qr/\.[^.]*/);
	 
	my $out_prinseq_path = "$output_dir/prinseq";
	checkDir($out_prinseq_path);
	#KR01_MATE_5Kb_L2_1
	my @tmp_r1_name = split /\_/, $r1_filename;
	pop @tmp_r1_name;
	my $read_filename = join "\_", @tmp_r1_name;

	my $prinseq_clean = "$out_prinseq_path/$read_filename.clean";
	my $prinseq_bad = "$out_prinseq_path/$read_filename.bad";
	my $prinseq_log = "$out_prinseq_path/$read_filename.prinseq.log";
		
	my $cmd_prinseq = prinseq($r1_read,$r2_read,$prinseq_log,$prinseq_clean,$prinseq_bad);

	my $sh_prinseq = "$output_dir/$read_filename.sh";
	my $q_err_prinseq = "$output_dir/$read_filename.err";
	my $q_out_prinseq = "$output_dir/$read_filename.out";
	write_qsub_script($sh_prinseq,$cmd_prinseq);
	my $jobname = "prinseq_$read_filename";
	run_qsub_script($sh_prinseq,$q_err_prinseq,$q_out_prinseq,$jobname);
}

sub run_qsub_script{
        my $q_sh = shift;
        my $q_err = shift;
        my $q_out = shift;
	my $job_name = shift;
        my $command = "qsub -N $job_name -e $q_err -o $q_out $q_sh";
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

sub prinseq{
	my $r1 = shift;
	my $r2 = shift;
	my $log = shift;
	my $out_good =shift;
	my $out_bad = shift;
	my $prinseq = $prinseq_path."/prinseq-lite.pl";
#perl prinseq-lite.pl -fastq /root/Filter/02.filter/test/input/shortjump_1.fastq -fastq2 /root/Filter/02.filter/test/input/shortjump_2.fastq -derep 1 -exact_only -derep_min 2 -trim_tail_left 6 -trim_tail_right 6 -log /nG/Data/Filter_output/OUTPUT/prinseq/shortjump_1.prinseq.log -ns_max_p 5 -trim_left 1 -trim_right 1 -out_good /nG/Data/Filter_output/OUTPUT/prinseq/shortjump_1.clean -out_bad /nG/Data/Filter_output/OUTPUT/prinseq/shortjump_2.clean
	my @params = qw(
-derep 1
-derep_min 2
);
#-trim_left 1
#-trim_right 1
#-ns_max_p 5
#-trim_tail_left 6
#-trim_tail_right 6

	my $param = join " ", @params;
	my $command = "perl $prinseq -fastq $r1 -fastq2 $r2 $param -log $log -out_good $out_good -out_bad $out_bad";
	#my $command = "perl $prinseq -fastq $r1 -fastq2 $r2 $param -log $log -out_good $out_good -out_bad $out_bad -graph_data test.gd";
	#my $command = "perl $prinseq -fastq $r1 -fastq2 $r2 $param -log $log -out_good $out_good -out_bad $out_bad -stats_all";
	#print $command."\n";
	return $command;
}

sub read_input_set{
	my $filename = shift;
	open my $fh, '<:encoding(UTF-8)', $filename or die;
	my @arr;
	while (my $row = <$fh>) {
        	chomp $row;
		if ($row =~ /^filename_1/){
			next;
		}
		my @l = split /\t/, $row;
		my $read_1 = $l[0];
		my $read_2 = $l[1];
		push @arr, $read_1."\t".$read_2;
	}
	close($fh);
	return @arr;
}

sub checkDir{
        my $dir = shift;
        if (!-d $dir){
                system("mkdir -p $dir");
        }
}

sub printUsage{
	print "Usage: perl $0 <info.tsv> <project directory>\n";
	print "Example: perl $0 ~/Filter/02.filter/test/info.tsv /nG/Data/Filter_output\n";
	exit;
}

