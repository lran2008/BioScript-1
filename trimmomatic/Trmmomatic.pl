#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;


my $step = "LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:100";

if (@ARGV == 0){
	printUsage();
}

my ($TOOL, $MODE, $THREAD, $PHRED);
my $OPTION = "";
GetOptions(
	'h' => \&help,
	'v' => \&version,
	'bin=s' => \$TOOL,
	'mode=s' => \$MODE,
	'threads=s' => \$THREAD,
	'phred=s' => \$PHRED
);

if (!defined $TOOL){ $TOOL = "/BiOfs/hmkim87/Pipeline/BioTools/Trimmomatic-0.22/trimmomatic-0.22.jar"; }

if (!defined $MODE){ $MODE = "PE"; }

if (defined $THREAD){
	$OPTION .= " -threads $THREAD";
}

my $command;
if ($MODE eq "SE" or $MODE eq "se"){
	$command = "java -classpath $TOOL org.usadellab.trimmomatic.TrimmomaticSE $OPTION";
	
}elsif ($MODE eq "PE" or $MODE eq "pe"){
	$command = "java -classpath $TOOL org.usadellab.trimmomatic.TrimmomaticPE $OPTION";

	my $READ_1 = $ARGV[0];
	my $READ_2 = $ARGV[1];
	my $PAIRED_OUT_1 = $READ_1.".forward_paired.fq.gz";
	my $PAIRED_OUT_2 = $READ_2.".reverse_paired.fq.gz";
	my $UN_PAIRED_OUT_1 = $READ_1.".foward_unpaired.fq.gz";
	my $UN_PAIRED_OUT_2 = $READ_2.".reverse_unpaired.fq.gz";


	$command = $command." $READ_1 $READ_2 $PAIRED_OUT_1 $UN_PAIRED_OUT_1 $PAIRED_OUT_2 $UN_PAIRED_OUT_2 $step";
	print "$command\n";

}else{
	die "ERROR!\n";
}


sub printUsage{
	print "Usage: perl $0 <read1> <read2>\n";
	print "Now, this step <$step>\n";
	exit;
}

sub help{
	print "Help Function\n";
	exit;
}

sub version{
	print "Version 1.0\n";
	exit;
}
