#!/usr/bin/perl -w
###
## Function: 
## Author: Hyunmin Kim
## Senior Researcher
## Genome Research Foundation
## E-Mail: brandon.kim.hyunmin@gmail.com
##
## History:
## - Version 0.1 ( Apr 8, 2014)
## - Version 0.2 ( Apr 9, 2014) - step1, step2 split
###
use strict;
use File::Basename; 

sub runScript ($;$){
        my $job_script_file = shift;
        my $dependency_job = shift;

        my $command;
        if ($dependency_job){
                $command = "qsub -hold_jid $dependency_job $job_script_file";
        }else{
                $command = "qsub $job_script_file";
        }
        print "$command\n";
        system($command);
}

sub writeScript ($$$$;$){
        my $job_script_file = shift;
        my $job_command = shift;
        my $job_name = shift;
        my $job_logfile = shift;
        my $cpu = shift;

        my @cmd_set;
        push @cmd_set, "#!bin/sh";
        push @cmd_set, "#\$ -q all.q";
        push @cmd_set, "#\$ -N $job_name";
        push @cmd_set, "#\$ -o $job_logfile";
        push @cmd_set, "#\$ -j y";
        push @cmd_set, "#\$ -S /bin/bash";
        push @cmd_set, "#\$ -cwd";
        push @cmd_set, "#\$ -V";
        if (defined $cpu){ push @cmd_set, "#\$ -pe smp $cpu"; }
        push @cmd_set, "hostname -a";
        push @cmd_set, "date";
        push @cmd_set, $job_command;
        push @cmd_set, "date\n";
        my $content = join "\n", @cmd_set;
        if (open(my $fh, '>:encoding(UTF-8)', $job_script_file)) {
                print {$fh} $content;
        close($fh);
        }
}

my $IBDLD = "/BiOfs/hmkim87/BioTools/IBDLD/3.12/IBDLD";

# define project directory
my $proj= "/BiO/hmkim87/IBDLD/Test";
# define default directory
my $input_path = "$proj/Input"; checkDir($input_path);
my $script_path = "$proj/Script"; checkDir($script_path); 
my $log_path = "$proj/Log"; checkDir($log_path); 
my $result_path = "$proj/Result"; checkDir($result_path);

# define user-specific path
my $out_prefix = "$result_path/papgi";
my $ped_file = "/BiO/hmkim87/IBDLD/input/papgi_wes94_KPGP38_pub25_smartpca.ped";
my $map_file = "/BiO/hmkim87/IBDLD/input/papgi_wes94_KPGP38_pub25_smartpca.map"; 
my $methodChoice = "GIBDLD";
my $ploci_n = 20;
my $step_num = 1;
my $mem_size = "4000"; #Allow the program to use approximately n megabytes(Mb) of random-access memory (RAM). Defaults to n = 1000)

my ($filename,$filepath,$fileext) = fileparse($ped_file, qr/\.[^.]*/);

# split into each chromosomes and run the step (step1, step2)
my $plink = "/BiOfs/hmkim87/BioTools/plink/1.07/plink";

my $get_chrList = "cut -f 1 $map_file | sort | uniq ";
print "# Processing chromosome ..\n";
my @chr_list = split "\n", `$get_chrList`;
foreach my $chr (@chr_list){
	my $plink_exec="$plink --nonfounders --allow-no-sex --noweb";
	my $outfile_split_dir = "$result_path/$chr";
	my $outfile_split_base = "$result_path/$chr/scan";

	my $method = "GIBDLD";
	my $ploci_n = 20;
	my $mem_size = 4000;

	my $cmd_split = "mkdir -p $outfile_split_dir\n".
		"cd $outfile_split_dir\n".
		"$plink --nonfounders --allow-no-sex --noweb --file $filepath/$filename --chr $chr --recode --out $outfile_split_base\n".
		"$IBDLD -o $outfile_split_base -p $outfile_split_base.ped -m $outfile_split_base.map -method $method -ploci $ploci_n -step 1 -r $mem_size -phcol 1\n".
		"$IBDLD -o $outfile_split_base -method $method -ploci $ploci_n -step 2 -r $mem_size";

	my $q_name_split = "IBDLD_$chr";
	my $q_sh_split = "$script_path/$q_name_split.sh";
	my $q_log_split = "$log_path/$q_name_split.log";
	writeScript($q_sh_split,$cmd_split,$q_name_split,$q_log_split,2);
	runScript($q_sh_split);
}
=pod
## define output file
my $method_file = "$out_prefix.mthd";
my $aInd_file = "$out_prefix.aInd";
my $kinship_file = "$out_prefix.kinship";
#kinship_file column information
#column 1: family 1 ID
#column 2: individual 1 ID
#column 3: family 2 ID
#column 4: individual 2 ID
#column 5: indicating chromosome
#column 6: number of SNPs on the chromosome
#column 7-15: 9 average conditional condensed identity coecients. column 16: empirical kinship coecient
=cut

sub checkDir{
        my $dir = shift;
        if (!-d $dir){
                system("mkdir -p $dir");
        }
}
