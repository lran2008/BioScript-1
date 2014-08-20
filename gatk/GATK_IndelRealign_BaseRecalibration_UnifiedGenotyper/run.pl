#!/usr/bin/perl
use warnings;
use strict;

## Program Info:
#
# Name: Untitled
#
# Function: GATK BAM Processing + UnifiedGenotyper
#
# Author: Hyunmin Kim
#  Copyright (c) Genome Research Foundation, 2014,
#  all rights reserved.
#
# Licence: This script may be used freely as long as no fee is charged
#    for use, and as long as the author/copyright attributions
#    are not removed.
#
# History:
#   Version 1.0 (Aug 14, 2014): first non-beta release.
##

use File::Basename;
use Cwd qw(abs_path);
use lib (dirname abs_path $0) . '/lib';

use Queue;

use Data::Dumper;

if (@ARGV !=2){
	printUsage();
}
#my $in_bam_pattern = "/BiO/hmkim87/OTG-snpcaller/Result/OTG_ResultBAM/AJ.*.bam";
my $in_bam_pattern = $ARGV[0];
my @bam_files = glob($in_bam_pattern);
my $proj_dir = $ARGV[1];
#my $proj_dir = "/BiO/hmkim87/OTG-snpcaller/Result/OTG_ResultVariant/AJ";

# tool
my $gatk = "/BiOfs/shsong/BioTools/GenomeAnalysisTKLite-2.3-9/GenomeAnalysisTKLite-2.3-9.jar";
my $samtools = "/BiOfs/shsong/BioTools/samtools-0.1.19/samtools";
# reference files
my $ref_fasta = "/BiOfs/jinsilhanna/BioResources/References/Human/hg19_LT/hg19.fasta";
my $INDELS_RECAL_VCF = "/BiOfs/jinsilhanna/BioResources/GATK_Bundle/2.8/hg19_LT/Mills_and_1000G_gold_standard.indels.hg19_LT.ReOrder.vcf";
my $KGIND_VCF = "/BiOfs/jinsilhanna/BioResources/GATK_Bundle/2.8/hg19_LT/1000G_phase1.indels.hg19_LT.ReOrder.vcf";
my $DBSNP_VCF = "/BiOfs/jinsilhanna/BioResources/GATK_Bundle/2.8/hg19_LT/dbsnp_138.hg19_LT.ReOrder.vcf";

foreach my $inbam (@bam_files){
	my ($filename,$filepath,$fileext) = fileparse($inbam, qr/\.[^.]*/);

	my $debug = 1;

	# set directory
	my $outdir = "$proj_dir/out";
	if (!-d $outdir){
		system("mkdir -p $outdir");
	}
	my $tmpdir = "$proj_dir/tmp";
	if (!-d $tmpdir){
		system("mkdir -p $tmpdir");
	}
	my $scriptdir = "$proj_dir/script";
	if (!-d $scriptdir){
		system("mkdir -p $scriptdir");
	}

	# bam index check
	my $jobname_bamIndex;
	if (!-f $inbam.".bai"){
		my $script_file = $scriptdir."/$filename.bam_index.sh";
		my $stdout_file = $scriptdir."/$filename.bam_index.log";
		$jobname_bamIndex = "bamIndex_$filename";
		my $config = {
			command => "$samtools index $inbam",
			name => $jobname_bamIndex,
			script => $script_file,
			stdout => $stdout_file,
		};
		my $job = Queue->new($config,$debug);
		$job->make();
		$job->run();
	}

	# set reference file in gatk app
	my @known_files_LocalRealign;
	push @known_files_LocalRealign, $INDELS_RECAL_VCF;
	push @known_files_LocalRealign, $KGIND_VCF;

	my $interval_file = $outdir."/$filename.intervals";
	my $realigned_file = $outdir."/$filename.realigned.bam";
	my $recal_file = $outdir."/$filename.realigned.recal.bam";

	my $info_rtc;
	$info_rtc->{java_bin} = "java";
	$info_rtc->{gatk} = $gatk;
	$info_rtc->{java_mem_size} = "4g";
	$info_rtc->{appName} = "RealignerTargetCreator";
	$info_rtc->{reference_fasta} = $ref_fasta;
	$info_rtc->{known_file} = \@known_files_LocalRealign;
	$info_rtc->{infile} = $inbam;
	$info_rtc->{outfile} = $interval_file;
	$info_rtc->{param} = "-nt 6";
	my $cmd_RealignerTargetCreator = gatk_program($info_rtc);
	my $jobname_Realign = "Realign_$filename";
	my $script_file = $scriptdir."/$filename.realigner.sh";
	my $stdout_file = $scriptdir."/$filename.realigner.log";
	my $config = {
		command => $cmd_RealignerTargetCreator,
		name => $jobname_Realign,
		script => $script_file,
		stdout => $stdout_file,
		slot_range => 6,
	};

	if (defined $jobname_bamIndex){
		$config->{depend_name} = $jobname_bamIndex;
	}

	my $job = Queue->new($config,$debug);
	$job->make();
	$job->run();

	my $info_ir;
	$info_ir->{java_bin} = "java";
	$info_ir->{gatk} = $gatk;
	$info_ir->{java_mem_size} = "4g";
	$info_ir->{java_tmp_path} = $tmpdir;
	$info_ir->{appName} = "IndelRealigner";
	$info_ir->{reference_fasta} = $ref_fasta;
	$info_ir->{known_file} = \@known_files_LocalRealign;
	$info_ir->{java_mem_size} = "4g";
	$info_ir->{targetIntervals} = $interval_file;
	$info_ir->{infile} = $inbam;
	$info_ir->{outfile} = $realigned_file;
	my $cmd_IndelRealigner = gatk_program($info_ir);
	$script_file = $scriptdir."/$filename.IndelRealigner.sh";
	$stdout_file = $scriptdir."/$filename.IndelRealigner.log";
	my $jobname_IndelRealigner = "IndelRealigner_$filename";
	my $config_IndelRealigner = {
		command => $cmd_IndelRealigner,
		name => $jobname_IndelRealigner,
		script => $script_file,
		stdout => $stdout_file,
		depend_name => $jobname_Realign,
	};
	my $job_IndelRealigner = Queue->new($config_IndelRealigner,$debug);
	$job_IndelRealigner->make();
	$job_IndelRealigner->run();
	
	my @known_files_BQSR;
	push @known_files_BQSR, $DBSNP_VCF;
	push @known_files_BQSR, $KGIND_VCF;
	push @known_files_BQSR, $INDELS_RECAL_VCF;

	my $info_br;
	$info_br->{java_bin} = "java";
	$info_br->{gatk} = $gatk;
	$info_br->{java_mem_size} = "4g";
	$info_br->{appName} = "BaseRecalibrator";
	$info_br->{reference_fasta} = $ref_fasta;
	$info_br->{infile} = $realigned_file;
	$info_br->{outfile} = "$outdir/$filename.recal_data.table";
	$info_br->{param} = "--disable_indel_quals"; # gatk 2.3.9
	$info_br->{known_file} = \@known_files_BQSR;
	my $cmd_BaseRecal = gatk_program($info_br);
	$script_file = $scriptdir."/$filename.BaseRecal.sh";
	$stdout_file = $scriptdir."/$filename.BaseRecal.log";
	my $jobname_BaseRecal = "BaseRecal_$filename";
	my $config_BaseRecal = {
		command => $cmd_BaseRecal,
		name => $jobname_BaseRecal,
		script => $script_file,
		stdout => $stdout_file,
		depend_name => $jobname_IndelRealigner,
	};
	my $job_BaseRecal = Queue->new($config_BaseRecal,$debug);
	$job_BaseRecal->make();
	$job_BaseRecal->run();

	my $info_pr;
	$info_pr->{java_bin} = "java";
	$info_pr->{gatk} = $gatk;
	$info_pr->{java_mem_size} = "2g";
	$info_pr->{appName} = "PrintReads";
	$info_pr->{reference_fasta} = $ref_fasta;
	$info_pr->{infile} = $realigned_file;
	$info_pr->{bqsr_table} = "$outdir/$filename.recal_data.table";
	$info_pr->{outfile} = $recal_file;
	my $cmd_PrintReads = gatk_program($info_pr);
	$script_file = $scriptdir."/$filename.PrintReads.sh";
	$stdout_file = $scriptdir."/$filename.PrintReads.log";
	my $jobname_PrintReads = "PrintReads_$filename";
	my $config_PrintReads = {
		command => $cmd_PrintReads,
		name => $jobname_PrintReads,
		script => $script_file,
		stdout => $stdout_file,
		depend_name => $jobname_BaseRecal,
	};
	my $job_PrintReads = Queue->new($config_PrintReads,$debug);
	$job_PrintReads->make();
	$job_PrintReads->run();

	my $info_ug;
	$info_ug->{java_bin} = "java";
	$info_ug->{gatk} = $gatk;
	$info_ug->{java_mem_size} = "4g";
	$info_ug->{appName} = "UnifiedGenotyper";
	$info_ug->{reference_fasta} = $ref_fasta;
	$info_ug->{infile} = $recal_file;
	$info_ug->{outfile} = "$outdir/$filename.raw.vcf";
	$info_ug->{param} = "--genotype_likelihoods_model BOTH --output_mode EMIT_VARIANTS_ONLY --heterozygosity 0.0010 -dcov 200 -stand_call_conf 30.0 -stand_emit_conf 30.0 -nt 3 -nct 6";
	$info_ug->{dbsnp} = $DBSNP_VCF;
	my $cmd_UG = gatk_program($info_ug);
	$script_file = $scriptdir."/$filename.UnifiedGenotyper.sh";
	$stdout_file = $scriptdir."/$filename.UnifiedGenotyper.log";
	my $jobname_UG = "UG_$filename";
	my $config_UG = {
		command => $cmd_UG,
		name => $jobname_UG,
		script => $script_file,
		stdout => $stdout_file,
		depend_name => $jobname_PrintReads,
		slot_range => 6,
	};
	my $job_UG = Queue->new($config_UG,$debug);
	$job_UG->make();
	$job_UG->run();
}

sub gatk_program{
	my $self = shift;

	my $java = $self->{java_bin};
	my $java_tmpdir = $self->{java_tmp_path};
	my $gatk = $self->{gatk};
	my $mem_size = $self->{java_mem_size};
	my $appName = $self->{appName};
	my $reference = $self->{reference_fasta};
	my $known_file = $self->{known_file};
	my $infile = $self->{infile};
	my $targetIntervals = $self->{targetIntervals};
	my $outfile = $self->{outfile};
	my $gatk_param = $self->{param};
	my $bqsr_table = $self->{bqsr_table};
	my $dbsnp_vcf = $self->{dbsnp};

	my @cmd_1;
	push @cmd_1, $java;

	if (defined $mem_size){
		push @cmd_1, "-Xmx$mem_size";
	}

	if (defined $java_tmpdir){
		push @cmd_1, "-Djava.io.tmpdir=$java_tmpdir";
	} 

	push @cmd_1, "-jar";
	push @cmd_1, $gatk;
	push @cmd_1, "-T $appName";
	push @cmd_1, "-R $reference";
	push @cmd_1, "-I $infile";
	push @cmd_1, "-o $outfile";

	if (defined $targetIntervals){ # IndelRealigner
		push @cmd_1, "-targetIntervals $targetIntervals";
	}

	if (defined $known_file and $#{$known_file} >= 0){
		foreach (@{$known_file}){
			if ($appName eq "BaseRecalibrator"){
				push @cmd_1, "--knownSites $_";
			}else{
				push @cmd_1, "-known $_";
			}
		}
	}

	if (defined $dbsnp_vcf){
		push @cmd_1, "--dbsnp $dbsnp_vcf";
	}

	if (defined $bqsr_table){
		push @cmd_1, "-BQSR $bqsr_table";
	}

	if (defined $gatk_param){
		push @cmd_1, $gatk_param;
	}

	my $command = join " ", @cmd_1;

	return $command;
}

sub printUsage{
	print "Usage: perl $0 <\"in*.bam\"> <project directory>\n";
	exit;
}
