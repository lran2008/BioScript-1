#!/usr/bin/perl -w

use strict;

if (@ARGV != 3){
	printUsage();
}

my $pph = "/BiOfs/BioTools/pph2/bin/run_pph.pl";
#my $pph_input = "/BiO3/hmkim87/Cow/10X_HM.vcf.bgt.pph2.input";
my $pph_input = $ARGV[0];
#my $pph_input_fasta = "/BiO3/hmkim87/Cow/cow.pep.fasta";
my $pph_input_fasta = $ARGV[1];
#my $dump_dir = "/BiO3/hmkim87/Cow/10X_HM";
my $dump_dir = $ARGV[2];
if (!-d $dump_dir){
	system("mkdir -p $dump_dir");
}

my $cmd = "$pph -s $pph_input_fasta -d $dump_dir $pph_input";
print "$cmd\n";

sub printUsage{
	print "Usage: perl $0 <pph input> <pph input fasta> <dump dir>\n";
	exit;
}
