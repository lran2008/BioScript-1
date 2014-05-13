#!/usr/bin/perl -w

use strict;

if (@ARGV !=3){
	printUsage();
}
my $infile_prefix = $ARGV[0];
my $outfile_prefix = $ARGV[1];
my $indiv_list_file = $ARGV[2];

my $plink = "/BiOfs/hmkim87/BioTools/plink/1.07/plink";

my $ped_file = "$infile_prefix.ped";
my $temp_list_file = $outfile_prefix.".tmp";
open my $fh_write, '>:encoding(UTF-8)', $temp_list_file or die "<$temp_list_file> $!\n";
open my $fh, '<:encoding(UTF-8)', $indiv_list_file or die;
while (my $row = <$fh>) {
        chomp $row;
	
	my $indiv_id = (split /\s+/, $row)[0];
	
	my $get_family_id = "awk -F\" \" '{if (\$2 == \"$indiv_id\") print \$1}' $ped_file";
	
	my $family_id = `$get_family_id`;
	chomp($family_id);
	print $fh_write "$family_id\t$indiv_id\n";
	
}
close($fh);
close($fh_write);

#my $command = "$plink --noweb --file $infile_prefix --keep $temp_list_file --recode --out $outfile_prefix";
my $command = "$plink --noweb --file $infile_prefix --keep $temp_list_file --recode --missing-genotype N --out $outfile_prefix";
print $command."\n";
system($command);

$command = "rm $temp_list_file";
print $command."\n";
system($command);

sub printUsage{
	print "Usage: perl $0 <infile_prefix> <outfile_prefix> <sample_id_list>\n";
	exit;
}
