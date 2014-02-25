#!/usr/bin/perl -w

use strict;
use Vcf;

my $invcf = $ARGV[0];
my $info_field_num = 8;

my $vcf = Vcf->new(file=>$invcf);

$vcf->parse_header();

my (@samples) = $vcf->get_samples();

foreach (@samples){
	print "$_\n";
}
