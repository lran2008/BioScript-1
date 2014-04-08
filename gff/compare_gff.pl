#!/usr/bin/perl -w

use strict;

if (@ARGV !=2){
	printUsage();
}
my $overlap = "/BiOfs/hmkim87/Linux/_script/overlap";

my $file1 = $ARGV[0];
my $file2 = $ARGV[1];
#my $file1 = "/BiO/hmkim87/Denovo/RepeatAnnotation/Tiger/Tiger_RepeatMasker_OUTPUT/Result/merged.gff";
#my $file2 = "/BiO/hmkim87/Denovo/FromBGI/Tiger/Repeat/Repeatmasker/repeatmasker.gff";

my $tmp_file1 = "$file1.tmp.gff";
my $tmp_file2 = "$file2.tmp.gff";

my $cmd_tmp_1 = "grep -v \"\^#\" $file1 | sed 's/[;=]/ /g' - > $tmp_file1";
runCommand($cmd_tmp_1);
my $cmd_tmp_2 = "grep -v \"\^#\" $file2 | sed 's/[;=]/ /g' - > $tmp_file2";
runCommand($cmd_tmp_2);


my $compare_out = "$file1.compare_with_file2.out";
my $cmd_overlap = "$overlap $tmp_file1 $tmp_file2 -o $compare_out";
runCommand($cmd_overlap);

my $cmd_tmp_rm = "rm $tmp_file1;rm $tmp_file2";
runCommand($cmd_tmp_rm);

my $cmd_count = "grep \"ov_feat2: 0\" $compare_out | wc -l";
my $only_file1_count = `$cmd_count`;
print "File1 Only:".$only_file1_count."\n";
$cmd_count = "grep \"ov_feat2: 1\" $compare_out | wc -l";
my $share_count = `$cmd_count`;
print "File1 & File2 Share:".$share_count."\n";
$cmd_count = "wc -l $compare_out";
my $all_count = `$cmd_count`;
print "All entry count: $all_count\n";

sub runCommand{
	my $command = shift;
	print STDERR "$command\n\n";
	system($command);
}

sub printUsage{
	print "Usage: perl $0 <file1.gff> <file2.gff>\n";
	exit;
}
