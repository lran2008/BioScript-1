#!/usr/bin/perl -w

use strict;

if (@ARGV != 1){
	printUsage();
}
my $abb_name = $ARGV[0];

# script
my $faSomeRecords = "/BiO/hmkim87/BioScript/fasta/split/faSomeRecords_CentOS";
my $identifier_trim_script = "fasta_identifier_trim.pl";

my $mirbase_path = "/BiO/hmkim87/BioResources/mirbase.org/pub/mirbase/21";
my $fa_hairpin = "/BiO/hmkim87/BioResources/mirbase.org/pub/mirbase/21/hairpin.fa";
my $fa_mature = "/BiO/hmkim87/BioResources/mirbase.org/pub/mirbase/21/mature.fa";

# hairpin
my $out_hairpin_list = "$mirbase_path/hairpin.$abb_name.list";
my $cmd_1 = "grep \">$abb_name\" $fa_hairpin | sed 's/^>//' | tr \" \" \"\\t\" | cut -f 1 > $out_hairpin_list";
run_cmd($cmd_1);

my $tmp_hairpin_fa = "$mirbase_path/hairpin.$abb_name.fa.tmp";
my $out_hairpin_fa = "$mirbase_path/hairpin.$abb_name.fa";
my $cmd_1_a = "$faSomeRecords $fa_hairpin $out_hairpin_list $tmp_hairpin_fa";
run_cmd($cmd_1_a);
my $cmd_1_b = "perl $identifier_trim_script $tmp_hairpin_fa > $out_hairpin_fa";
run_cmd($cmd_1_b);
my $cmd_1_c = "rm $tmp_hairpin_fa";
run_cmd($cmd_1_c);

# mature
my $out_mature_list = "$mirbase_path/mature.$abb_name.list";
my $cmd_2 = "grep \">$abb_name\" $fa_mature | sed 's/^>//' | tr \" \" \"\\t\" | cut -f 1 > $out_mature_list";
run_cmd($cmd_2);

my $tmp_mature_fa = "$mirbase_path/mature.$abb_name.fa.tmp";
my $out_mature_fa = "$mirbase_path/mature.$abb_name.fa";
my $cmd_2_a = "$faSomeRecords $fa_mature $out_mature_list $tmp_mature_fa";
run_cmd($cmd_2_a);
my $cmd_2_b = "perl $identifier_trim_script $tmp_mature_fa > $out_mature_fa";
run_cmd($cmd_2_b);
my $cmd_2_c = "rm $tmp_mature_fa";
run_cmd($cmd_2_c);

print STDERR "\n<out_hairpin_fa:$out_hairpin_fa>\n";
print STDERR "<out_mature_fa:$out_mature_fa>\n";

sub run_cmd{
	my $command = shift;
	print $command."\n";
	system($command);
}

sub printUsage{
	print "usage: perl $0 <in.species.abbreviation>\n";
	print "example: perl $0 hsa\n";
	exit;
}
