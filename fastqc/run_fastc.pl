#!/usr/bin/perl -w

use strict;

use File::Basename qw(dirname);
use Cwd  qw(abs_path);

use lib (dirname abs_path $0);

use FastQC;

if (@ARGV != 1){
	printUsage();
}

my $in_fq_pattern = $ARGV[0];
my @arr_fq = glob($in_fq_pattern);

foreach my $fq (@arr_fq){
	my $tool_config={
		file => $fq,
		app => 'qc',
		threads => 4,
		program => "/BiOfs/hmkim87/BioTools/FastQC/0.11.2/fastqc",
		java => "/BiOfs/hmkim87/Linux/jre1.7.0_51/bin/java",
		extract => 3,
	};
	my $ref_FastQC = FastQC->new($tool_config);
	my $cmd_FastQC = $ref_FastQC->{command};
	print "qsub -pe smp 4 -b y $cmd_FastQC\n";
}

sub printUsage{
	print "UsagE: perl $0 <\"in*.fastq\">\n";
	exit;
}
