#!/usr/bin/perl -w

use strict;
use File::Basename;
use Cwd 'abs_path'; 

my $PWD = dirname(__FILE__);
my $root = abs_path($PWD); 

my $gemini = "/usr/local/bin/gemini";

#my $snpeff = "$root/../../tools/snpEff/snpEff.jar";
#my $snpeff_config = "$root/../../tools/snpEff/snpEff.config";

my $invcf = "/BiO/hmkim87/gemini/3113_break.vcf";
my $genome_version = "hg19";
my $outvcf = "/BiO/hmkim87/gemini/3113_break.snpeff.vcf";
my $snpeff_log = "/BiO/hmkim87/gemini/3113_break.snpeff.log";

my $command;

#snpeff annotation
my $snpeff_script = "$root/../snpeff/run.pl";
$command = "$snpeff_script $invcf $genome_version $outvcf $snpeff_log";
#print STDERR $command."\n";
print STDERR "## snpeff vcf annotation START\n";
system($command);
print STDERR "## snpeff vcf annotation END\n";
#gemini load vcf to db
my $gemini_invcf = $outvcf;
my $gemini_load_type = "snpEff";
my $gemini_load_cpu = 8;
my $gemini_load_dbname = "/BiO/hmkim87/gemini/3113_break.snpeff.db";
print STDERR "## gemini load START\n";
$command = "$gemini load -v $gemini_invcf -t $gemini_load_type --cores $gemini_load_cpu $gemini_load_dbname";
#print $command."\n";
system($command);
print STDERR "## gemini load END\n";
