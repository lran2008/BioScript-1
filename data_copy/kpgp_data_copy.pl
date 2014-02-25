#!/usr/bin/perl -w

use strict;

my $remote_server_ip = "182.162.88.17";
my $remote_server_username = "hmkim87";
my $remote_server_port = "22";
my $remote_server_password = "rlagusals";

#/BiO/BioProjects/KPGP-Human-WGS-2013-05/Data/P01_KT/TGP2011D0030/rawdata/fastq/*.gz
#/BiO/BioProjects/KPGP-Human-WGS-2013-05/Data/P05_Fam04/TG1111D2638/rawdata/fastq

my @arr_category=qw(
P01_KT
P02_Fam01
P03_Fam02
P04_Fam03
P05_Fam04
P08_Fam07
P09_Fam08
P10_Fam09
);

my @except_sample = qw(TGP2011D0010 TGP2011D0011 TGP2011D0012 TGP2011D0013 TGP2011D0014 TGP2011D0017 TGP2011D0018 TGP2011D0019 TGP2011D0020 TGP2011D0021 TGP2011D0022 TGP2011D0023 TGP2011D0024 TGP2011D0025 TGP2011D0026 TGP2011D0028 TGP2011D0029);

my $upper_path = "/BiO/BioProjects/KPGP-Human-WGS-2013-05/Data";
foreach my $category (@arr_category){
	my $category_path = "$upper_path/$category";

	my $cmd_get_sample_list = "ls $category_path | awk \"{print \$1}\"";
	my $sshpass_command = "sshpass -p $remote_server_password ssh -p$remote_server_port $remote_server_username\@$remote_server_ip '$cmd_get_sample_list'";
	#print $sshpass_command."\n";
	print "## retriving... the sample_list for <$category>\n";
	my $result_sshpass_command = `$sshpass_command`;
	print "## finished... the sample_list for <$category>\n";
	my @sample_list = split /\n/, $result_sshpass_command;
	
	foreach my $sample (@sample_list){
		#check except sample
		my $flag = 0;
		foreach my $sample_id (@except_sample){
			if ($sample_id eq $sample){
				$flag = 1;
			}
		}
		if ($flag == 1){
			print "## pass <$sample> : already exist files in server\n";
			next;
		}
		my $sample_path = "$category_path/$sample";
		my $rawdata_path = "$sample_path/rawdata/fastq";
		my $targetFile = "$rawdata_path/*.gz";

		my @l_folderName = split /\//, $rawdata_path;
		shift @l_folderName;
		shift @l_folderName;
		shift @l_folderName;
		shift @l_folderName;
		pop @l_folderName;
		pop @l_folderName;
		my $sample_folderName = join "\/", @l_folderName;

		my $root_path = "/Share/gisys/TotalOmics/KPGP_chul/Genome";
		my $targetFolderName = "$root_path/$sample_folderName";
		my $command = "mkdir -p $targetFolderName";
		print $command."\n";
		system($command);
		$command = "sshpass -p $remote_server_password scp -P$remote_server_port $remote_server_username\@$remote_server_ip\:$targetFile $targetFolderName";
		print $command."\n";
		system($command);
		
	}
}
