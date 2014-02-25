#!/usr/bin/perl -w

use strict;
use File::Basename;

my @ids = qw(2122 2121 2120 2119 2118 2117 2116 2115 2114 2113 2111 2110 2109 2108 2107 2106 2105 2104 2103 2102 2101 2100 2099 2098 2097 2096 2095 2094 2093 2092 2091 2090 2089 2088 2087 2086 2085 2084 2083 2082 2081 2080 2079 2078 2077 2076 2075 2074 2073 2072 2071 2070 2069 2068 2067 2066 2065 2064 2063 2062 2061 2060 2059 2058 2057 2056 2055 2054 2053 2052 2051 2050 2049 2048 1700 1699 1698 1697 1696 1695 1694 1693 1692 1691 1690 1689 1688 1687 1686 1685 1684 1683 1682 1681 1680 1679 1678 1677 1646 1569);

foreach my $id (@ids){
	my @target_files;

	my $path = "/nG/Data/".$id;
	my $out_path = $path."/__OUTPUT__";
	my $report_path = $path."/__REPORT__";

	my $conf = $path."/pipeline.conf";

	my $r1_clean = $path."/rawdataqcfiltered/fastqc/afterfilter.1.fastq.gz";
	my $r2_clean = $path."/rawdataqcfiltered/fastqc/afterfilter.2.fastq.gz";
	my $bam = $out_path."/final.bam"; # except unmappped reads
	my $raw_vcf = $out_path."/all.target.vcf";
	my $anno_vcf = $out_path."/all.annotated.vcf"; 
	my $anno_tsv = $report_path."/all.annotated.tsv";

	push @target_files, $r1_clean;
	push @target_files, $r2_clean;
	push @target_files, $bam;
	push @target_files, $raw_vcf;
	push @target_files, $anno_vcf;
	push @target_files, $anno_tsv;

	my $get_id = "cat $conf | grep SAMPLEID= | sed 's/SAMPLEID=//'";
	my $sample_id = `$get_id`;
	chomp($sample_id);
	#print "No. $sample_id: ";
	foreach my $file (@target_files){
		#file check
		fileCheck($file);
		#print "$file ok\t";

		my ($name,$path,$ext) = fileparse($file,qr/\.[^.]*/);

		#copy to server	
		my $password = "rlagusals";
		my $server_ip = "182.162.88.8";
		my $user_id = "hmkim87";
		my $origin = "";
		my $remote_path = "/BiO/BioProjects/PGI-PAPGI-Genome-2012-08/Reports/GR";

		my $filePath;
		my $fileName;
		if ($file =~/afterfilter/){
			$filePath = "rawdata";
			if ($file =~ /1/){
				$fileName = "1.clean.fastq";
			}elsif ($file =~ /2/){
				$fileName = "2.clean.fastq";
			}
		}elsif ($file =~ /final\.bam/){
			$filePath = "bam";
			$fileName = "final";
		}elsif ($file =~ /target/){
			$filePath = "vcf";
			$fileName = "raw";
		}elsif ($file =~ /annotated\.vcf/){
			$filePath = "annotated_vcf";
			$fileName = "raw.annotated";
		}elsif ($file =~ /annotated\.tsv/){
			$filePath = "annotated_tsv";
			$fileName = "raw.annotated";
		}else {
			die "ERROR ! <$file>\n";
		}

		my $scp_command = "scp -r $file $user_id\@$server_ip:$remote_path/$filePath/$sample_id.$fileName$ext";

		my $command = "sshpass -p $password $scp_command";
		print "$command\n";
		
	}
	print "\n";
}

sub fileCheck{
	my $file = shift;
	if (!-f $file){
		die "ERROR! not found <$file>\n";
	}
}
