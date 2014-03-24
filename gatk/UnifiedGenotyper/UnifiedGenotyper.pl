#!/usr/bin/perl -w

use strict;

if (@ARGV !=2){
	printUsage();
}

my $in_bam = $ARGV[0];
my $out_vcf = $ARGV[1];

my $gatk = "/BiOfs/hmkim87/BioTools/GATK/2.3.9/GenomeAnalysisTKLite-2.3-9.jar";
my $mem = "8g";

#-T UnifiedGenotyper  --genotype_likelihoods_model BOTH --output_mode EMIT_VARIANTS_ONLY --heterozygosity 0.0010 -dcov 10000 -stand_call_conf 30.0 -stand_emit_conf 30.0  -nt 30 -R /nG/Reference/hgdownload.cse.ucsc.edu/goldenPath/hg19/FASTA/chrAll.fa --dbsnp /nG/Reference/CommonName/hg19/DBSNP/dbsnp_138.hg19.vcf

my $reference_fasta = "/BiOfs/hmkim87/BioResources/Reference/Human/hg19/chrAll.fa";
my $dbsnp_vcf = "/BiOfs/hmkim87/BioResources/Reference/Human/Resources/dbsnp/dbsnp_138.hg19.vcf";

my $gatk_AppName = "UnifiedGenotyper";
my $gatk_Command = "--genotype_likelihoods_model BOTH --output_mode EMIT_ALL_SITES --heterozygosity 0.0010 -dcov 200 -stand_call_conf 30.0 -stand_emit_conf 30.0 -nct 3 -nt 2 -R $reference_fasta --dbsnp $dbsnp_vcf -I $in_bam -o $out_vcf";

my $command = "java -jar -Xmx$mem -T $gatk_AppName $gatk_Command";
print $command."\n";

sub printUsage{
	print "Usage: perl $0 <in.bam> <out.vcf>\n";
	exit;
}
