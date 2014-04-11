#!/usr/bin/perl -w

use strict;

if (@ARGV !=2){
	printUsage();
}
my $infile = $ARGV[0];
my $EVal_limit = $ARGV[1];

my $source = "blastn";
my $type = "rRNA";
my $phase = ".";

open my $fh, '<:encoding(UTF-8)', $infile or die;
my $cnt = 1;
while (my $row = <$fh>) {
        chomp $row;
	if ($row=~ /^#/){ next; }
	my ($QryId, $SubId, $PID, $Len, $MisMatch, $GapOpen, $QStart,$QEnd, $SStart, $SEnd, $EVal, $BitScore) = split(/\t/, $row);

	my $strand;
	my $SPos;
	if ($SStart > $SEnd){
		$strand = "-";
		$SPos = "$SEnd $SStart";
	}else{
		$strand = "+";
		$SPos = "$SStart $SEnd";
	}
	my $num = sprintf("%04d", $cnt);
	my $id;
	if ($SubId =~ /^(\d+S)\_/){
		$id = "rRNA_$1_$num";
	}else{
		$id = (split /\|/, $SubId)[0];
	}
	my $flag_gap = $GapOpen + 1;
	my $attribute = "ID=$id;Target=$flag_gap $SPos;Annotation=\"[Homo sapiens] H.sapiens $SubId\";";
	if($EVal =~ m/^e-d+/) { $EVal = "1".$EVal; }
	if ($EVal > $EVal_limit){ # blast filter
	#if ($EVal > 1e-05){ # blast filter
		next; 
	}
	print "$QryId\t$source\t$type\t$QStart\t$QEnd\t$EVal\t$strand\t$phase\t$attribute\n";
	$cnt++;
}
close($fh);

sub printUsage{
	print "Usage: perl $0 <infile> <blast evalue filter>\n";
	print "Example: perl $0 in.blast.m8.out 1e-05\n";
	exit;
}
