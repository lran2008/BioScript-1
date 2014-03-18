#!/usr/bin/perl -w

use strict;
use File::Basename; 

if (@ARGV !=2){
	printUsage();
}

my $samtools = "/BiOfs/hmkim87/BioTools/samtools/0.1.19_CentOS/samtools";
my $picard_path = "/BiOfs/hmkim87/BioTools/picard/1.107";
my $CollectInsertSizeMetrics = "$picard_path/CollectInsertSizeMetrics.jar";
my $SortSam = "$picard_path/SortSam.jar";

my $IN_BAM = $ARGV[0];
my $REFERENCE_FASTA = $ARGV[1];
#my $REFERENCE_FASTA = "/BiOfs/BioResources/References/Human/hg19/BWA_0.7.7_Index/hg19.fa";

my ($filename,$filepath,$fileext) = fileparse($IN_BAM, qr/\.[^.]*/);
my $HISTOGRAM_FILE = "$filepath/$filename.pdf";
my $OUT_FILE = "$filepath/$filename.out";

my $SortOrder = "queryname"; # Possible values: {unsorted, queryname, coordinate}

my $command = "java -Xmx8g -Djava.io.tmpdir=`pwd`/tmp -jar $SortSam I=$IN_BAM OUTPUT=/dev/stdout VALIDATION_STRINGENCY=LENIENT COMPRESSION_LEVEL=0 SORT_ORDER=$SortOrder QUIET=true | ".
	"java -Xmx4g -Djava.io.tmpdir=`pwd`/tmp -jar $CollectInsertSizeMetrics H=$HISTOGRAM_FILE I=/dev/stdin O=$OUT_FILE R=$REFERENCE_FASTA";

print $command."\n";
system($command);

sub printUsage{
	print "Usage: perl $0 <in.bam> <reference_fasta>\n";
	exit;
}
