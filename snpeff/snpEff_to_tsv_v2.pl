#!/usr/bin/perl -w

use strict;

if (@ARGV != 1){
	printUsage();
}

my $infile = $ARGV[0];

my $command = "cat $infile | /BiOfs/hmkim87/BioTools/snpEff/current/scripts/vcfEffOnePerLine.pl".
            " | java -jar /BiOfs/hmkim87/BioTools/snpEff/current/SnpSift.jar extractFields -".
            " CHROM POS REF ALT DP".
            " \"GEN[*].GT\"". # Tumor Sample (2nd) Geno type
            " \"GEN[*].AD\"".
            " \"EFF[*].EFFECT\"".
            " \"EFF[*].IMPACT\"".
            " \"EFF[*].FUNCLASS\"".
            " \"EFF[*].CODON\"".
            " \"EFF[*].AA\"".
            " \"EFF[*].AA_LEN\"".
            " \"EFF[*].GENE\"".
            " \"EFF[*].BIOTYPE\"".
            " \"EFF[*].CODING\"".
            " \"EFF[*].TRID\"".
            " \"EFF[*].RANK\"";
print $command."\n";

sub printUsage{
	print "perl $0 <in.snpEff.vcf>\n";
	exit;
}
