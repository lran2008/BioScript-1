#!/usr/bin/perl -w

use strict;
use File::Basename;

if (@ARGV != 3){
	printUsage();
}
my $splitList = $ARGV[0];
my $file_pattern = $ARGV[1];
my $outListFile = $ARGV[2];
my ($outListFile_name,$outListFile_dir,$outListFile_ext) = fileparse($outListFile, qr/\.[^.]*/);
checkDir($outListFile_dir);

my @_splitList = split /\,/, $splitList;
my $fastqList = $file_pattern;

my @FIRST_FASTQ_LIST;
my @SECOND_FASTQ_LIST;

my @fastq_files = glob($file_pattern);
foreach my $fastq_file (sort @fastq_files){
	my ($fastq_name,$fastq_dir,$fastq_ext) = fileparse($fastq_file, qr/\.[^.]*/);
	my $filename = $fastq_name.$fastq_ext;
	if ($filename =~ /$_splitList[0]/g == 1){
		#print $fastq_dir.$filename."\tR1\n";
		push @FIRST_FASTQ_LIST, $fastq_file;
	}elsif ($filename =~ /$_splitList[1]/g == 1){
		#print $fastq_dir.$filename."\tR2\n";
		push @SECOND_FASTQ_LIST, $fastq_file;
	}else{
		die "ERROR ! Couldn't recognize the file <$filename>\n";
	}
}
#
# Build the hash...
#
#my %hash;
for my $index (0 .. $#FIRST_FASTQ_LIST){
	my $r1 = $FIRST_FASTQ_LIST[$index];
	my $r2 = $SECOND_FASTQ_LIST[$index];
	my ($r1_name,$r1_dir,$r1_ext) = fileparse($r1, qr/\.[^.]*/);
	my ($r2_name,$r2_dir,$r2_ext) = fileparse($r2, qr/\.[^.]*/);
	#$hash{$FIRST_FASTQ_LIST[$index]} = $SECOND_FASTQ_LIST[$index];

	if ($r1_ext eq ".gz" and $r2_ext eq ".gz"){
		$r1_ext = "_1.fq.gz";
		$r2_ext = "_2.fq.gz";
	}else{
		$r1_ext = "_1.fq";
		$r2_ext = "_2.fq";
	}
	my $command = "ln -s ".$r1." ".$outListFile_dir."/".$index.$r1_ext;
	print $command."\n";
	$command = "ln -s ".$r2." ".$outListFile_dir."/".$index.$r2_ext;
	print $command."\n";
}
#
# Print it (Write it)
#
#open my $fh, '>:encoding(UTF-8)', $outListFile or die;
#foreach (sort(keys(%hash)))
#	print $fh ("$_\t$hash{$_}\n");
#}
#close($fh);

sub checkDir{
        my $dir = shift;
        if (!-d $dir){
                system("mkdir -p $dir");
        }
}

sub printUsage{
	print "Usage: perl $0 <splitWord R1,R2> <\"input_file_pattern\"> <OutListFile>\n";
	print "Example: perl $0 R1,R2 \"/BiO/BioProjects/PGI-PAPGI-Genome-2012-08/Resources/RawData/WGS_at_TBI_by_Illumina/T1302D0525/*/*.gz listFile\"\n";
	exit;
}

=pod
my $num_f = @fastq_files;
my %hash;
foreach my $i ( 0 .. ($num_f/2)-1 ) {
	my $r1 = $fastq_files[2*$i]; # read1 fastq
	my ($r1_name,$r1_dir,$r1_ext) = fileparse($r1, qr/\.[^.]*/);
	my $r2 = $fastq_files[2*$i+1]; # read2 fastq
	my ($r2_name,$r2_dir,$r2_ext) = fileparse($r2, qr/\.[^.]*/);
	print "$r1_name\t$r2_name\n";
	push @{$hash{$r1_name}}, $r1;
	push @{$hash{$r1_name}}, $r2;
}
foreach my $key (keys %hash){
	my $arr_count = @{$hash{$key}};

	if ($arr_count eq 2 ){
		my $count = 1;
		foreach my $val (@{$hash{$key}}){
			print "$key\t$count\t$val\n";
			$count++;
		}
	}
}
=cut
