#!/usr/bin/perl -w

use strict;

use File::Basename;
use Cwd 'abs_path';

my $PWD = dirname(__FILE__);
my $root = abs_path($PWD); 

my $gatk = "/BiOfs/hmkim87/BioTools/GATK/2.8.1/GenomeAnalysisTK.jar";
my $java = "/BiOfs/hmkim87/Linux/jre1.7.0_51/bin/java";
my $samtools = "/BiOfs/hmkim87/BioTools/samtools/0.1.19/samtools";

my $bamfile_pattern = $ARGV[0];
my $out_UG_vcf = $ARGV[1];
my $target_region_file = $ARGV[2];

my $ref_fasta = "/BiOfs/hmkim87/BioResources/Reference/Human/hg19/chrAll.fa";

my @bam_files = glob($bamfile_pattern);
my $sample_bam_list = "";
foreach my $bam_file (@bam_files){
        #check bam index
        if (!-f $bam_file.".bai"){
                my $sc = "$samtools index $bam_file";
                $sc = "qsub -b y \"$sc\"";
                #print "$sc\n";
                #system($sc);
                die "no index bam <$bam_file>\n";
        }
        $sample_bam_list .= "-I $bam_file ";
}

my $gatk_memSize = "8g";
my $gatk_AppName = "UnifiedGenotyper";
my $gatk_param = "-glm BOTH -dcov 200 -nt 1 -nct 24";
my $command = "$java -jar -Xmx$gatk_memSize $gatk -T $gatk_AppName ".
        "-R $ref_fasta ".
        "$sample_bam_list ".
        "-o $out_UG_vcf ".
        "-L $target_region_file ".
	"$gatk_param";
print "$command\n";

sub printUsage{
	print "Usage: perl $0 <\"in*.bam\"> <reference fasta>\n";
	print "Example : perl $0 <\"in*.bam\"> /BiO/Reference/Human/hg19/chrAll.fa\n";
	exit;
}
