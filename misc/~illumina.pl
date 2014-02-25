#!/usr/bin/perl
use lib "./";
################################################################
# NGS_Illumina Package                                         #
# Author:   Zhengdeng Lei                              #
# E-mail:   leizhengdeng@hotmail.com                           #
################################################################

# Example in caller NGS_Illumina.pl
# Assume the paths for fastx_tk, maq, bwa, samtools are in ENV{PATH}; check $PATH setting $HOME/.bash_profile
# Assume perl and python are installed
#my $NGS_obj = new NGS_Illumina ('sample_name' => 'Testis_T28',
#        'input_fq1'  => 'Run1_testicular-28T_lane2_read1_sequence.txt',
#        'input_fq2'  => 'Run1_testicular-28T_lane2_read2_sequence.txt',
#        'pe'   => 1,
#        'reference_fa' => '/data/public/reference_genomes/genome_hg18.fa',
#        'dbsnp_rod'  => '/data/nextgen1/pipeline/dbsnp_130_hg18.rod',
#        'picard_dir' => '/home/gmslz/tools/picard-tools-1.44',
#        'gatk_dir'  => '/data/public/tools/gatk-v4333/Sting',
#        'tmp_dir'  => '/home/tmp',
#        'java_mem'  => '-Xmx4g');
#
#$NGS_obj -> check_fastq_format();
#$NGS_obj -> illumina2sanger();
#$NGS_obj -> qcstats();
#$NGS_obj -> fastq_trimmer(1, 74);
#$NGS_obj -> aln_bwa();     #alignment step, which includes bwa, sort, rm_pcrdup, add_rg
#$NGS_obj -> snp_analysis_gatk();  #gatk step, which includes realignment, recalibration, genotyping (indel, snp)

package NGS_Illumina;
#use strict;
use warnings;
use Time::Local;
use Time::localtime;

# private members:
# sample_name <sample name>
# input_fq1 <input fastq1>
# input_fq2 <input fastq2>
# sanger_fq1 <input fastq1 in sanger format>
# sanger_fq2 <input fastq1 in sanger format>
# reference_fa <reference genome>
# fastq_format <fastq format>
 # "Sanger"      -- quality score from 0 to 93 using ASCII 33 to 126
 # "Solexa"  Illumina 1.0 -- quality score from -5 to 62 using ASCII 59 to 126
 # "Illumina" Illumina 1.3+ -- quality score from 0 to 62 using ASCII 64 to 126
# pe <paired end>
 # 1 paired end
 # 0 single end
#my @attributes = qw/reference_fa sample_name input_fq1 input_fq2 fastq_format sanger_fq1 sanger_fq2 pe/;

######################################################################################################
# The subroutines "new" and "initialize" for the constructor
sub new  
{
 my $class_name = shift;  # Gets class name from parmlist
 my $this = {};    # Creates reference to object
 bless($this, $class_name); # Associates reference with class
 $this->initialize(@_); # Call local initialize subroutine
        # passing rest of parmlist
 return $this;    # Explicit return of value of $this
}

sub initialize
{
 my $this = shift;    # Receive an object reference as 1st param
 my %parms = @_;         # Get passed parameters from the call to "new"

 # Change hash reference for key with supplied value, or assign default
 $this->{reference_fa}   = $parms{reference_fa} || 'hg18.fa';
 $this->{sample_name}   = $parms{sample_name} || 'undef_sample_name';
 $this->{input_fq1}    = $parms{input_fq1}  || 0;
 $this->{input_fq2}    = $parms{input_fq2}  || 0;
 $this->{pe}      = $parms{pe}   || 1;
 $this->{fastq_format}   = $parms{fastq_format} || 'Illumina';
 $this->{sanger_fq1}    = $parms{sample_name}.'_read1_sanger.fq';
 $this->{sanger_fq2}    = $parms{sample_name}.'_read2_sanger.fq';
 $this->{dbsnp_rod}    = $parms{dbsnp_rod}  || '/data/nextgen1/pipeline/dbsnp_130_hg18.rod';
 $this->{target_bed}    = $parms{target_bed} || '/data/nextgen1/pipeline/targets/SureSelect_All_Exon_G3362_with_names.v2.bed';

 $this->{java_mem}    = $parms{java_mem}  || '-Xmx4g';
 $this->{num_thread}    = $parms{num_thread} || 8;
 $this->{gatk_dir}    = $parms{gatk_dir}  || '/data/public/tools/gatk-v4333/Sting';
 $this->{picard_dir}    = $parms{picard_dir} || '/home/gmslz/tools/picard-tools-1.44';
 $this->{tools_dir}    = $parms{tools_dir}  || '/data/public/tools/gatk_pipeline/src-pipeline';
 $this->{tmp_dir}    = $parms{tmp_dir}  || '/home/tmp';

 $this->{picard_MarkDuplicates}   = "java $this->{java_mem} -jar $this->{picard_dir}/MarkDuplicates.jar";
 $this->{picard_AddOrReplaceReadGroups} = "java $this->{java_mem} -jar $this->{picard_dir}/AddOrReplaceReadGroups.jar";
 $this->{picard_SortSam}     = "java $this->{java_mem} -jar $this->{picard_dir}/SortSam.jar";
 $this->{picard_FixMateInformation}  = "java $this->{java_mem} -Djava.io.tmpdir=$this->{tmp_dir}/ -jar $this->{picard_dir}/FixMateInformation.jar";
 $this->{gatk_GenomeAnalysisTK}   = "java $this->{java_mem} -Djava.io.tmpdir=$this->{tmp_dir}/ -jar $this->{gatk_dir}/dist/GenomeAnalysisTK.jar";
 $this->{gatk_makeIndelMask_py}   = "$this->{gatk_dir}/python/makeIndelMask.py";

 $this->{aligned_bam_file} = "./bam/$this->{sample_name}.sorted.rmdup.rg.bam"; #This is the final bam file after bwa alignment, i.e. before gatk
 $this->{final_recalibrated_bam_file} = "./bam/$this->{sample_name}.final.recalibrated.bam"; #This is the final recalibrated bam file after after gatk

 if ($this->{fastq_format} eq "Sanger")
 {
  $this->{sanger_fq1} = $this->{input_fq1};
  $this->{sanger_fq2} = $this->{input_fq2};
 }


 #print $ENV{'PATH'}, "\n\n\n";

 my @subfolders = qw/qcstats bam snp_analysis_gatk/;
 foreach my $dir (@subfolders)
 {
  if (!(-e $dir))
  {
   mkdir($dir);
  }
 }
}

sub modify  #  modify the object
{
 my $this = shift;  # Figure out who I am
 my %parms = @_;       # Make hash out of rest of parm list
 for(keys %parms) 
 {
  $this->{$_} = $parms{$_}; # Replace with new value
 }
}

sub snp_analysis_gatk
{
# GATK Documents:
# http://www.broadinstitute.org/gatk/gatkdocs/
# e.g.:
# http://www.broadinstitute.org/gatk/gatkdocs/org_broadinstitute_sting_gatk_filters_DuplicateReadFilter.html
# http://www.broadinstitute.org/gatk/gatkdocs/org_broadinstitute_sting_gatk_walkers_filters_VariantFiltration.html

 my $this = shift; 
 #chdir("../snp_analysis_gtk");
 my $max_depth = 10000;

# goto EVAL1;
 run_cmd("$this->{gatk_GenomeAnalysisTK} -T DepthOfCoverage -l INFO ". #not support -nt $this->{num_thread}
   "-D $this->{dbsnp_rod} -R $this->{reference_fa} -L $this->{target_bed} ".
   "-I $this->{aligned_bam_file} ".
   "-o ./snp_analysis_gatk/$this->{sample_name}.depthofcoverage > ./log/$this->{sample_name}.depthofcoverage.log");







 #step 1 --- Local realignment around indels
 #step 1.1 --- gatk -T RealignerTargetCreator; Determining (small) suspicious intervals around indels
 run_cmd("$this->{gatk_GenomeAnalysisTK} -T RealignerTargetCreator -l INFO ". #not support -nt $this->{num_thread}
   "-D $this->{dbsnp_rod} -R $this->{reference_fa} ".
   "-I $this->{aligned_bam_file} ".
   "-o ./snp_analysis_gatk/$this->{sample_name}.intervals > ./log/$this->{sample_name}.intervals.log");
 #step 1.2 --- gatk -T IndelRealigner; Running the realigner over those intervals
 run_cmd("$this->{gatk_GenomeAnalysisTK} -T IndelRealigner -l INFO ". #not support -nt $this->{num_thread}
  "-D $this->{dbsnp_rod} -R $this->{reference_fa} ".
  "-I $this->{aligned_bam_file} -targetIntervals ./snp_analysis_gatk/$this->{sample_name}.intervals ".
  "-o ./bam/$this->{sample_name}.realigned.bam -stats ./bam/$this->{sample_name}.realign.stats.txt > ./log/$this->{sample_name}.realign.log");
 run_cmd("samtools index ./bam/$this->{sample_name}.realigned.bam");
 #step 1.3 --- picard SortSam
 run_cmd("$this->{picard_SortSam} SO=coordinate VALIDATION_STRINGENCY=SILENT ".
  "I=./bam/$this->{sample_name}.realigned.bam ".
  "O=./bam/$this->{sample_name}.realigned.sorted.bam");
 run_cmd("samtools index ./bam/$this->{sample_name}.realigned.sorted.bam");
 #step 1.4 --- picard FixMateInformation; Fixing the mate pairs of realigned reads
 run_cmd("$this->{picard_FixMateInformation} SO=coordinate VALIDATION_STRINGENCY=SILENT MAX_RECORDS_IN_RAM=2000000 ".
  "I=./bam/$this->{sample_name}.realigned.sorted.bam ".
  "O=./bam/$this->{sample_name}.realigned.sorted.fixed.bam");
 run_cmd("samtools index ./bam/$this->{sample_name}.realigned.sorted.fixed.bam");
 #step 1.5 --- skip picard MarkDuplicates


 #step 2 --- Recalibrate quality scores --> Final Recalibrated Bam
 #step 2.1 --- gatk -T CountCovariates;
 run_cmd("$this->{gatk_GenomeAnalysisTK} -T CountCovariates -l INFO -nt $this->{num_thread} ".
  "--downsample_to_coverage $max_depth --default_platform Illumina ".
  "-cov ReadGroupCovariate -cov QualityScoreCovariate -cov CycleCovariate -cov DinucCovariate ".
  "-D $this->{dbsnp_rod} -R $this->{reference_fa} ".
   "-I ./bam/$this->{sample_name}.realigned.sorted.fixed.bam ".
  "-recalFile ./snp_analysis_gatk/$this->{sample_name}.recal.csv > ./log/$this->{sample_name}.count.covariates.log");
 #step 2.2 --- gatk -T TableRecalibration  --> Final Recalibrated Bam
 run_cmd("$this->{gatk_GenomeAnalysisTK} -T TableRecalibration -l INFO --default_platform Illumina ". #not support -nt $this->{num_thread}
  "-R $this->{reference_fa} ".
   "-I ./bam/$this->{sample_name}.realigned.sorted.fixed.bam -recalFile ./snp_analysis_gatk/$this->{sample_name}.recal.csv ".
  "--out $this->{final_recalibrated_bam_file} > ./log/$this->{sample_name}.recalibration.log");
 run_cmd("samtools index $this->{final_recalibrated_bam_file}");
 # skip 2.3 -T CountCovariates
 # skip 2.4 AnalyzeCovariate

#############################################################################
# You may merge multiple final_recalibrated_bam files before Genotyping #
#############################################################################


 #step 3 --- Genotyping
 #step 3.1 --- gatk -T IndelGenotyperV2;
 #print STDERR "\nRunning the indel genotyper:\n";
    run_cmd("$this->{gatk_GenomeAnalysisTK} -T IndelGenotyperV2 -l INFO --window_size 450 ". #not suport -nt $this->{num_thread}
  "-D $this->{dbsnp_rod} -R $this->{reference_fa} ".
  "-I $this->{final_recalibrated_bam_file} ".
  "-o ./snp_analysis_gatk/$this->{sample_name}.indels.vcf -bed ./snp_analysis_gatk/$this->{sample_name}.indels.bed > ./log/$this->{sample_name}.indels.log");

 # skip filter indels: perl /tools/filterSingleSampleCalls.pl
 #step 3.2 python/makeIndelMask.py
 # create intervals to mask snvs close to indels
 # The output of the IndelGenotyper is used to mask out SNPs near indels.
 # The number 10 in this command stands for the number of bases that will be included on either side of the indel
 run_cmd("python $this->{gatk_dir}/python/makeIndelMask.py ./snp_analysis_gatk/$this->{sample_name}.indels.bed 10 ./snp_analysis_gatk/$this->{sample_name}.indels.mask.bed");
 #step 3.3 --- gatk -T Unifiedgenotyper;
 run_cmd("$this->{gatk_GenomeAnalysisTK} -T UnifiedGenotyper -l INFO ". #not suport -nt $this->{num_thread}
  "-stand_call_conf 30 -stand_emit_conf 10 -pl SOLEXA -mmq 30 -mm40 3 ".
  "-D $this->{dbsnp_rod} -R $this->{reference_fa} ".
  "-I $this->{final_recalibrated_bam_file} ".
  "-o ./snp_analysis_gatk/$this->{sample_name}.raw.snps.vcf > ./log/$this->{sample_name}.snp.log");

 #step 3.4 --- gatk -T VariantFiltration; VariantFiltration is used to annotate suspicious calls from VCF files based on their failing given filters.
 run_cmd("$this->{gatk_GenomeAnalysisTK} -T VariantFiltration -l INFO ". #not suport -nt $this->{num_thread}
  '--clusterSize 3 --clusterWindowSize 10 '.
  '--filterExpression "DP <= 8" --filterName "DP8" '.
  '--filterExpression "SB > -0.10" --filterName "StrandBias" '.
  '--filterExpression "HRun > 8" --filterName "HRun8" '.
  '--filterExpression "QD < 5.0" --filterName "QD5" '.
  '--filterExpression "MQ0 >= 4 && ((MQ0 / (1.0 * DP)) > 0.1)" --filterName "hard2validate" '.
  "-D $this->{dbsnp_rod} -R $this->{reference_fa} ".
  "-B:variant,VCF ./snp_analysis_gatk/$this->{sample_name}.raw.snps.vcf ".
  "-B:mask,Bed ./snp_analysis_gatk/$this->{sample_name}.indels.mask.bed --maskName InDel ".
  "-o ./snp_analysis_gatk/$this->{sample_name}.snp.filtered.vcf > ./log/$this->{sample_name}.snp.filter.log");

## grep -i 'indel'  Testis_T28.snp.filtered.vcf|more
## grep -i 'pass'  Testis_T28.snp.filtered.vcf|more

#EVAL1:
 run_cmd("$this->{gatk_GenomeAnalysisTK} -T VariantEval -l INFO ". #not suport -nt $this->{num_thread}
  "-D $this->{dbsnp_rod} -R $this->{reference_fa} -L $this->{target_bed} ".
  #-G Indicates that your VCF file has genotypes; -A Print extended evaluation information; -V Print a list of interesting sites (FPs, FNs, etc).
  "-B:eval,VCF ./snp_analysis_gatk/$this->{sample_name}.snp.filtered.vcf ".
  "-o ./snp_analysis_gatk/$this->{sample_name}.snp.filtered.eval > ./log/$this->{sample_name}.snp.filter.eval.log");



#annotate variants Annovar
#$cmd = "annotate_variation.pl -filter -batchsize 50m -dbtype snp$verdbsnp -buildver $buildver -outfile $outfile $queryfile $dbloc";


# Consensus Quality: Phred-scaled likelihood that the genotype is wrong
# SNP Quality: Phred-scaled likelihood that the genotype is identical to the reference,
# which is also called `SNP quality'. Suppose the reference base is A and in alignment
# we see 17 G and 3 A. We will get a low consensus quality because it is difficult to
# distinguish an A/G heterozygote from a G/G homozygote. We will get a high SNP
# quality, though, because the evidence of a SNP is very strong.
# RMS: root mean square (RMS) mapping quality, a measure of the variance of quality scores
# Coverage: reads covering the position
}


########################################################################################################
# 0. check fastq format
sub check_fastq_format
{
 my $this = shift;  # Figure out who I am
 open(FASTQ, $this->{input_fq1}) or die "can't open $this->{input_fq1}: $@\n";
 
 my $fastq_format;
    my $counter = 2000; # count 2000 lines of quality scores
 my $min_qualscore = 1e6;
 my $max_qualscore = -1e6;
    my $tmp;
    while ($counter > 0)
 {
  $tmp = <FASTQ>; # @read name
  $tmp = <FASTQ>; # base calls
  $tmp = <FASTQ>; # +read name
  my $scores = <FASTQ>; # quality scores
  if (!$scores) { last }
  #print $scores;
  chomp($scores);
  for my $chr (map(ord, split(//, $scores)))
  {
   if ($chr < $min_qualscore)
   {
    $min_qualscore = $chr;
   }
   if ($chr > $max_qualscore)
   {
    $max_qualscore = $chr;
   }

  }
  $counter--;
 }
 # Phred+33 means quality score + 33 = ASCII
 if ($min_qualscore >= 33 && $max_qualscore <= 126)
 {
  $fastq_format = "Sanger";
 }

 # Solexa+64 means quality score + 64 = ASCII
 if ($min_qualscore >= 59 && $max_qualscore <= 126)
 {
  $fastq_format = "Solexa";
 }

 # Phred+64 means quality score + 64 = ASCII
 if ($min_qualscore >= 64 && $max_qualscore <= 126)
 {
  $fastq_format = "Illumina 1.3+";
 }

 # Phred+64 in both both Illumina 1.3+ and Illumina 1.5+
 #if ($min_qualscore >= 66 && $max_qualscore <= 126)
 #{
 # $fastq_format = "Illumina 1.5+";
 #}

 # Illumina 1.8+ returned to the use of the Sanger format (Phred+33)
 print "$fastq_format fastq format: ASCII(min, max) = ($min_qualscore, $max_qualscore)\n";
 $this->{fastq_format} = $fastq_format;
 if ($this->{fastq_format} eq "Sanger")
 {
  $this->{sanger_fq1} = $this->{input_fq1};
  $this->{sanger_fq2} = $this->{input_fq2};
 }
 return $fastq_format;
}

########################################################################################################
# 1. QCGroomer step: illumina2sanger
# Alternative converter "fastq_quality_converter -i $this->{input_fq1} -o $this->{sanger_fq1}"
sub illumina2sanger
{
 my $this = shift;  # Figure out who I am
 my $fastq_converter;
 if ($this->{fastq_format} eq "Sanger")
 {
  print "The input fastq is already in Sanger format, no need for conversion!!\n";
  return;
 }
 elsif ($this->{fastq_format} eq "Solexa")
 {
  $fastq_converter = "maq sol2sanger";
 }
 elsif ($this->{fastq_format} eq "Illumina 1.3+")
 {
  $fastq_converter = "maq ill2sanger";
 }
 else
 {
  print "No Sanger or Illumina fastq format found, exit now!!\n";
  exit(0);
 }
 run_cmd("$fastq_converter $this->{input_fq1} $this->{sanger_fq1}");

 if($this->{pe})
 {
  run_cmd("$fastq_converter $this->{input_fq2} $this->{sanger_fq2}");
 }

}


########################################################################################################
# 2. QCStats step: qcstats
# use fastx tool kit to process
# http://hannonlab.cshl.edu/fastx_toolkit/commandline.html
# check linux version by "uname -a"
# To set PATH=$PATH:$HOME/bin:$HOME/tools/fastx_tk
# vi .bash_profile
# source .bash_profile
sub qcstats
{
 my $this = shift;
 run_cmd("fastx_quality_stats -Q 33 -i $this->{sanger_fq1} -o ./qcstats/$this->{sanger_fq1}"."_stats.txt"); #option -Q 33 is for Sanger format
 run_cmd("fastq_quality_boxplot_graph.sh -i ./qcstats/$this->{sanger_fq1}_stats.txt -o ./qcstats/$this->{sanger_fq1}_stats.png -t \"$this->{sanger_fq1}\"");
# my $qcnecleotide_cmd1 = "fastx_nucleotide_distribution_graph.sh -i $this->{sanger_fq1}"."_stats.txt -o ./qcstats/$this->{sanger_fq1}_nuc.png -t \"$this->{sanger_fq1} nucleotide distribution\"";
 if($this->{pe})
 {
  run_cmd("fastx_quality_stats -Q 33 -i $this->{sanger_fq2} -o ./qcstats/$this->{sanger_fq2}"."_stats.txt"); #option -Q 33 is for Sanger format
  run_cmd("fastq_quality_boxplot_graph.sh -i ./qcstats/$this->{sanger_fq2}_stats.txt -o ./qcstats/$this->{sanger_fq2}_stats.png -t \"$this->{sanger_fq2}\"");
#  my $qcnecleotide_cmd2 = "fastx_nucleotide_distribution_graph.sh -i $this->{sanger_fq2}"."_stats.txt -o ./qcstats/$this->{sanger_fq2}_nuc.png -t \"$this->{sanger_fq2} nucleotide distribution\"";
 }
}

sub fastq_trimmer
{
 my $this = shift;
 my ($first_base_pos, $last_base_pos) = @_;
 print "reads at positions($first_base_pos, $last_base_pos) selected\n";
 my $trimmed_fq1 = $this->{sanger_fq1};
 $trimmed_fq1 =~ s/fq$/trimmed.fq/;
 run_cmd("fastx_trimmer -Q 33 -f $first_base_pos -l $last_base_pos -i $this->{sanger_fq1} -o $trimmed_fq1");
 $this->{sanger_fq1} = $trimmed_fq1;

 if($this->{pe})
 {
  my $trimmed_fq2 = $this->{sanger_fq2};
  $trimmed_fq2 =~ s/fq$/trimmed.fq/;
  run_cmd("fastx_trimmer -Q 33 -f $first_base_pos -l $last_base_pos -i $this->{sanger_fq2} -o $trimmed_fq2");
  $this->{sanger_fq2} = $trimmed_fq2;
 }
}

sub aln_bwa
{
#    my (%sample_setting) = @_;
 my $this = shift;
 run_cmd("bwa aln -t $this->{num_thread} $this->{reference_fa} $this->{sanger_fq1} > ./bam/$this->{sample_name}.read1.sai");

 if($this->{pe})
 {
  run_cmd("bwa aln -t $this->{num_thread} $this->{reference_fa} $this->{sanger_fq2} > ./bam/$this->{sample_name}.read2.sai");
  #to add read group information -r '@RG\tID:foo\tSM:bar'
  run_cmd("bwa sampe $this->{reference_fa} ./bam/$this->{sample_name}.read1.sai ./bam/$this->{sample_name}.read2.sai ".
   "$this->{sanger_fq1} $this->{sanger_fq2} > ./bam/$this->{sample_name}.sam");
 }
 else
 {
  run_cmd("bwa samse $this->{reference_fa} ./bam/$this->{sample_name}.read1.sai $this->{sanger_fq1} > ./bam/$this->{sample_name}.sam");
 }
# #//sed 's/[ \t]*$//g' $sample_name.sam >$sample_name.sed.sam
 run_cmd("samtools import $this->{reference_fa}.fai ./bam/$this->{sample_name}.sam ./bam/$this->{sample_name}.bam");
 run_cmd("samtools sort ./bam/$this->{sample_name}.bam ./bam/$this->{sample_name}.sorted");
 run_cmd("samtools index ./bam/$this->{sample_name}.sorted.bam");

 #scp -r ./picard-tools-1.44/ NUSSTF\\gmslz@172.25.138.143:~/tools/
 #add $HOME/tools/picard-tools-1.44 to PATH in file .bash_profile
 #source .bash_profile
 ##### remove PCR duplicate using PICARD
 ##### remove PRC duplicates by picard, use AS=true so that picard knows the bam is sorted.
 run_cmd("$this->{picard_MarkDuplicates} VALIDATION_STRINGENCY=SILENT M=PCR_duplicates.M.txt REMOVE_DUPLICATES=true AS=true ".
  "I=./bam/$this->{sample_name}.sorted.bam ".
  "O=./bam/$this->{sample_name}.sorted.rmdup.bam");

 #add read group inforation
 run_cmd("$this->{picard_AddOrReplaceReadGroups} RGID=lane1 RGLB=$this->{sample_name}.fastq RGPL=Illumina RGPU=run RGSM=$this->{sample_name} CREATE_INDEX=TRUE VALIDATION_STRINGENCY=SILENT ".
  "I=./bam/$this->{sample_name}.sorted.rmdup.bam ".
  "O=./bam/$this->{sample_name}.sorted.rmdup.rg.bam");
 run_cmd("samtools index ./bam/$this->{sample_name}.sorted.rmdup.rg.bam");

 unlink("./bam/$this->{sample_name}.read1.sai", "./bam/$this->{sample_name}.read2.sai", "./bam/$this->{sample_name}.sam");
}

 

sub run_cmd
{
 my $cmd = shift;
 my $start_time = localtime();
 my ($year, $mon, $day, $hour, $min, $sec) = ($start_time->year + 1900, $start_time->mon+1, $start_time->mday, $start_time->hour, $start_time->min, $start_time->sec);
 my $start_time_sec = timelocal($sec, $min, $hour, $day, $mon, $year);
 printf("%04d/%02d/%02d %02d:%02d:%02d", $year, $mon, $day, $hour, $min, $sec);
 print "\tSTART $cmd\n";

 my $cmd_res = system($cmd);
 if ($cmd_res)
 {
  my $error_time = localtime;
  ($year, $mon, $day, $hour, $min, $sec) = ($error_time->year + 1900, $error_time->mon+1, $error_time->mday, $error_time->hour, $error_time->min, $error_time->sec);
  printf("%04d/%02d/%02d %02d:%02d:%02d", $year, $mon, $day, $hour, $min, $sec);
  print "\tERROR: $?\nEXIT!!\n\n";
  exit 1;

 }
 else
 {
  my $end_time = localtime;
  ($year, $mon, $day, $hour, $min, $sec) = ($end_time->year + 1900, $end_time->mon+1, $end_time->mday, $end_time->hour, $end_time->min, $end_time->sec);
  my $end_time_sec = timelocal($sec, $min, $hour, $day, $mon, $year);
  my $difference = $end_time_sec - $start_time_sec;
  my $seconds    =  $difference % 60;
  $difference = ($difference - $seconds) / 60;
  my $minutes    =  $difference % 60;
  $difference = ($difference - $minutes) / 60;
  my $hours      =  $difference % 24;
  printf("%04d/%02d/%02d %02d:%02d:%02d", $year, $mon, $day, $hour, $min, $sec);
  print "\tSUCCESS after running $hours hours $minutes minutes $seconds seconds\n\n";
 }
}

1;


#
# Reference:
# http://www.bbmriwiki.nl/wiki/PipelineCommands
# http://www.bbmriwiki.nl/wiki/SnpCallingPipeline/VariantCalling
# http://www.broadinstitute.org/gatk/gatkdocs/
