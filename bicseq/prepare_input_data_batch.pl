#!/usr/bin/perl

use strict;
use warnings;

if (@ARGV != 1){
    printUsage();
}
my $samtools = "/BiOfs/hmkim87/Pipeline/BioTools/BICseq/SAMgetUnique/samtools-0.1.7a_getUnique-0.1.1/samtools"; # samtools fix version for BICseq

my $outPrefix = $ARGV[0];
#my $outPrefix = "/BiO/BioProjects/SNU-WGRS-Dog-Genome-2012-12/result/BICseq";

#my @samples = ("T1211D1108", "T1211D1109");
my @samples = ("TGP2010D0022", "TGP2010D0023"); ###########

for (my $i=0; $i<@samples; $i++){
    my $sample = $samples[$i];
    
    my $targetDir = "/BiO/BioProjects/SNU-WGRS-Dog-Genome-2012-12/$sample/Result/RealignedBam"; #####################
    my @chr = glob("$targetDir/*.bam");
    
    for (my $j=0; $j<@chr; $j++){
        my $inbam = $chr[$j];
        my $chrDir = (split /\//, $inbam)[-1];
        #$chrDir =~ s/.realigned.bam.fix.bam//g;
        $chrDir =~ s/.realigned.bam//g;
        
        #my $outDir = "$outPrefix/$sample/chr$chrDir";
        my $outDir = "$outPrefix/$sample/$chrDir";
        system("mkdir -p $outDir");

        my $command = "qsub -b y -wd $outDir $samtools view -U BWA,$outDir/,N,N $inbam";
        print "$command\n";
    }
}

sub printUsage{
    print "Usage: perl $0 <out directory full path>\n";
    exit;
}
