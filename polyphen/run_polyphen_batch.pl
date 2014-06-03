#!/usr/bin/perl -w

use strict;

if (@ARGV != 2){
	printUsage();
}

my $target = $ARGV[0];
#my @input = glob("/home/hmkim87/pph_input/*.input");
my @input = glob($target);
my $fasta = $ARGV[1];

for (my $i=0; $i<@input; $i++){
	my $filename = (split /\//, $input[$i])[-1];
	$filename =~ s/\.input//;

	my $command = "qsub -cwd -b y -N $filename /BiOfs/BioTools/pph2/bin/run_pph.pl -s $fasta $input[$i]";
	print "$command\n";
}

sub printUsage{
	print "Usage: perl $0 <\"pph input directory\/\*.pph.input\"> <in.fasta>\n";
	exit;
}
