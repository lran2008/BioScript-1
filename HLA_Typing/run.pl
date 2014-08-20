#!/usr/bin/perl -w

use strict;

#my $script = "/BiO/sgpark/Project/CBU_Exome_HLA_Typing/Script/TotalHLATyping.py";
my $script = "/BiO/hmkim87/PAPGI/HLA_Typing/TotalHLATyping.py";
my $r1_fastq = "/BiO/hmkim87/PAPGI/Exome/RawData/T1303D1399/T1303D1399_1.fastq";
my $r2_fastq = "/BiO/hmkim87/PAPGI/Exome/RawData/T1303D1399/T1303D1399_2.fastq";
my $out_dir = "/BiO/hmkim87/PAPGI/HLA_Test_Output/";
my $cmd = "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/BiOfs/BioTools/bamtools/lib/\n".
	"python $script $r1_fastq $r2_fastq $out_dir";

my $sh_file = "$out_dir/HLA_Typing.sh";
write_qsub_script($sh_file,$cmd);
my $sh_err = "$out_dir/HLA_Typing.err";
my $sh_out = "$out_dir/HLA_Typing.out";
run_qsub_script($sh_file,$sh_err,$sh_out);

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
