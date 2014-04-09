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
###
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
        #system($command);
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

my $script_path = "/BiO/hmkim87/IBDLD/Script"; checkDir($script_path); 
my $log_path = "/BiO/hmkim87/IBDLD/Log"; checkDir($log_path); 

my $out_prefix = "/BiO/hmkim87/IBDLD/output/out";
my $ped_file = "/BiO/hmkim87/IBDLD/input/papgi_wes94_KPGP38_pub25_smartpca.ped";
my $map_file = "/BiO/hmkim87/IBDLD/input/papgi_wes94_KPGP38_pub25_smartpca.map"; 
my $methodChoice = "GIBDLD";
my $ploci_n = 20;
my $dist_k = 2;
my $step_num = 0;
my $cmd_step1 = "$IBDLD -o $out_prefix -plink $ped_file -m_int $map_file -method $methodChoice -ploci $ploci_n -dist $dist_k -step $step_num";

my $q_name_step1 = "IBDLD";
my $q_sh_step1 = "$script_path/$q_name_step1.sh";
my $q_log_step1 = "$log_path/$q_name_step1.log";
writeScript($q_sh_step1,$cmd_step1,$q_name_step1,$q_log_step1);
runScript($q_sh_step1);

my $cmd_step2 = "$IBDLD -i idcoefFile -o prefix -method methodChoice -ploci n -dist k -step 2";



sub checkDir{
        my $dir = shift;
        if (!-d $dir){
                system("mkdir -p $dir");
        }
}
