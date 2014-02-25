#!/usr/bin/perl -w

use strict;
use Cwd 'abs_path'; 

if (@ARGV !=2){
	printUsage();
}

my $input_file_name = $ARGV[0];
my $output_file_name = $ARGV[1];

$input_file_name = abs_path($input_file_name);

my $dbNSFP_class_path = "/gg/reference/dbNSFP"; # must contain the dbNSFP database file
my $dbNSFP_bin = "search_dbNSFP21";

my $command;

my $human_genome_version = "hg19";
my $list_of_chromosomes_to_search = "1";
$command = "cd $dbNSFP_class_path";
print $command."\n";
chdir $dbNSFP_class_path or die;
#$command = "java -classpath $dbNSFP_class_path $dbNSFP_bin -v $human_genome_version -c $list_of_chromosomes_to_search -i $input_file_name -o $output_file_name";
$command = "java $dbNSFP_bin -v $human_genome_version -c $list_of_chromosomes_to_search -i $input_file_name -o $output_file_name";
print $command."\n";
system($command);

sub printUsage{
	print "Usage: perl $0 <input_file_name> <output_file_name>\n";
	print "Descipriotn : must set the dbNSFP database in local. and output_file name is absoulte path! or your result file will save in dbNSFP database path\n";
	exit;
}
