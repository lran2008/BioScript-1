#!/usr/bin/perl -w

use strict;
use File::Basename;
use Cwd 'abs_path';

if (@ARGV !=1){
	printUsage();
}
my $invcf = $ARGV[0];

my $PWD = dirname(__FILE__);
my $root = abs_path($PWD);

my $vcfEffOnePerLine = "$root/../../tools/snpEff/scripts/vcfEffOnePerLine.pl";
my $vcfbreakmulti = "$root/../../tools/vcflib/bin/vcfbreakmulti";
my $vcf2tsv = "$root/../../tools/vcflib/bin/vcf2tsv";

my $command;
$command = "cat $invcf | ".
	"$vcfEffOnePerLine | ".
	"$vcfbreakmulti | ".
	"$vcf2tsv -n . -g";
print $command."\n";

sub printUsage{
	print "Usage: perl $0 <in.vcf>\n";
	exit;
}
