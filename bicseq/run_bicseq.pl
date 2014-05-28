#!/usr/bin/perl -w

use strict;

#my $caseDir = "/BiO/BioProjects/SNU-WGRS-Dog-Genome-2012-12/result/BICseq/T1211D1108";
my $caseDir = "/BiO/BioProjects/SNU-WGRS-Dog-Genome-2012-12/result/BICseq/TGP2010D0022"; ##############
#my $controlDir = "/BiO/BioProjects/SNU-WGRS-Dog-Genome-2012-12/result/BICseq/T1211D1109";
my $controlDir = "/BiO/BioProjects/SNU-WGRS-Dog-Genome-2012-12/result/BICseq/TGP2010D0023"; #############

my @caseChr = glob("$caseDir/chr*"); ####
my @controlChr = glob("$controlDir/chr*"); ####

my $configFile = "/BiO/BioProjects/SNU-WGRS-Dog-Genome-2012-12/script/BICseq/bicseq.twin.config"; ##########
make_config(\@caseChr, \@controlChr);

my $bicseq = "/BiOfs/hmkim87/Pipeline/BioTools/BICseq/BIC-seq/BIC-seq.pl";

my $outputDir = "/BiO/BioProjects/SNU-WGRS-Dog-Genome-2012-12/result/BICseq"; #############

my $description = "BIC-seq for Clone Dog"; ########### Title on result image

my $cmd = "$bicseq --lambda 2 --bin_size=100 --multiplicity=2 --window=200 --paired --I=265,20 $configFile $outputDir \"$description\""; #############
print "perl $cmd\n";


sub make_config{
    my ($array0, $array1) = @_;
    my @chr_case = @$array0;
    my @chr_control = @$array1;
    
    open(DATA, ">$configFile");
    print DATA "chrom\tcase\tcontrol\n";
    for (my $i=0; $i<@chr_case; $i++){
        my $chrName = (split /\//, $chr_case[$i])[-1];
        
        my $content = "$chrName\t$chr_case[$i]/$chrName.seq\t$chr_control[$i]/$chrName.seq\n";
        print DATA $content;
    }
    close(DATA);

}
