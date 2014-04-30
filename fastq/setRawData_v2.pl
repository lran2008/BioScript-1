#!/usr/bin/perl -w

use strict;
use File::Basename; 
use Config;

if (@ARGV !=3){
	printUsage();
}
my $splitWords = $ARGV[0];
my $inFastqPattern = $ARGV[1];
my $outDir = $ARGV[2];

my @splitList = split /\,/, $splitWords;
my @fastqList = glob($inFastqPattern);
@fastqList = sort @fastqList;
my $num_f = @fastqList;

my @R1_FASTQ_LIST;
my @R2_FASTQ_LIST;

setFastqPairing(\@fastqList,\@splitList);
if ($#R1_FASTQ_LIST ne $#R2_FASTQ_LIST){
	die "ERROR! no match R1,R2 file count. check your split words ($splitWords)\n";
}


# check perl threads
$Config{usethreads} or die "Recomplie Perl with threads to run this program.";
use threads;

my @thread;
for (my $i=0; $i<@R1_FASTQ_LIST; $i++){
	my $r1 = $R1_FASTQ_LIST[$i];
	my ($r1_name,$r1_dir,$r1_ext) = fileparse($r1, qr/\.[^.]*/);
	my $r2 = $R2_FASTQ_LIST[$i];
	my ($r2_name,$r2_dir,$r2_ext) = fileparse($r2, qr/\.[^.]*/);

	my ($cmd_R1_link,$cmd_R2_link);
	if ($r1_ext =~ /\.gz/ and $r2_ext =~ /\.gz/){
		$cmd_R1_link = "gzip -d -c $r1 > $r1_dir/$r1_name;".
			"ln -s $r1_dir/$r1_name $outDir/$i\_1.fq";
		$cmd_R2_link = "gzip -d -c $r2 > $r2_dir/$r2_name;".
			"ln -s $r2_dir/$r2_name $outDir/$i\_2.fq";
		#$cmd_R1_link = "gzip -d -c $r1 > $outDir/$i\_1.fq";
		#$cmd_R2_link = "gzip -d -c $r2 > $outDir/$i\_2.fq";
		#$cmd_R1_link = "ln -s ".$r1." ".$outDir."/".$i."_1.fq";
		#$cmd_R2_link = "ln -s ".$r2." ".$outDir."/".$i."_2.fq";
	}else{
		$cmd_R1_link = "ln -s ".$r1." ".$outDir."/".$i."_1".$r1_ext;
		$cmd_R2_link = "ln -s ".$r2." ".$outDir."/".$i."_2".$r2_ext;
	}
	$_ = threads->new(\&run_command,$cmd_R1_link);
	push @thread, $_;
	$_ = threads->new(\&run_command,$cmd_R2_link);
	push @thread, $_;
}


foreach (@thread){
        my $t_res = $_ -> join;
}

sub run_command{
	my $command = shift;
	#print $command."\n";
	system($command);
}

=pod
foreach my $i ( 0.. ($num_f/2)-1 ){
	my $r1 = $fastqList[2*$i]; # read1 fastq
	my ($r1_name,$r1_dir,$r1_ext) = fileparse($r1, qr/\.[^.]*/);
	my $r2 = $fastqList[2*$i+1]; # read2 fastq
	my ($r2_name,$r2_dir,$r2_ext) = fileparse($r2, qr/\.[^.]*/);
	
	my $cmd_R1_link = "ln -s ".$r1." ".$outDir.$i."_1".$r1_ext;
	print "$cmd_R1_link\n";
	my $cmd_R2_link = "ln -s ".$r2." ".$outDir.$i."_2".$r2_ext;
	print "$cmd_R2_link\n";
}
=cut

sub setFastqPairing{
	my ($fastqList_, $splitList_) = @_;

	foreach my $fastq (@$fastqList_){
		my ($filename,$filepath,$fileext) = fileparse($fastq, qr/\.[^.]*/);
		$filename = $filename.$fileext;
		if ($filename =~ /@$splitList_[0]/g){
			push @R1_FASTQ_LIST, $fastq;
		}elsif ($filename =~ /@$splitList_[1]/g){
			push @R2_FASTQ_LIST, $fastq;
		}else{
			die "ERROR ! not match string ($filename) with ($splitWords)\n";
		}
	}
}

sub printUsage{
	print "Usage: perl $0 <splitWords R1,R2> <inPattern.fastq> <out_directory>\n";
	print "Example: perl $0 _1,_2 \"/BiO/hmkim87/RawData/Test1/*.fq\" /BiO/hmkim87/RawData/\n";
	print "Example: perl $0 R1,R2 \"/BiO/BioProjects/PGI-PAPGI-Genome-2012-08/Resources/RawData/WGS_at_TBI_by_Illumina/T1303D1178/*/*.gz\" /BiO/hmkim87/RawData/TestLinkRawData\n";
	exit;
}
