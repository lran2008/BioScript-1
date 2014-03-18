#!/usr/bin/perl -w

use strict;

my $download_vcf = "/BiOfs/hmkim87/BioResources/Reference/Human/Resources/1000genome/ALL.2of4intersection.20100804.genotypes.vcf.gz";

if (@ARGV !=2){
	printUsage();
}
my $vcf_file = $ARGV[0];
my $out_vcf = $ARGV[1];

my $tabix = "/BiO/hmkim87/BioTools/tabix/0.2.6/tabix";
my $command = "$tabix -H $download_vcf > $out_vcf";
#print $command."\n";
system($command);

my $cnt = 0;
my $retval = time();
my $start_time = gmtime( $retval);
open my $fh, '<:encoding(UTF-8)', $vcf_file or die;
while (my $row = <$fh>) {
	if ($row =~ /^#/){
		next;
	}
        chomp $row;
	my @l = split /\t/, $row;

	my $chr = $l[0];
	my $pos = $l[1];
	$command = "$tabix $download_vcf $chr:$pos-$pos >> $out_vcf";
	#print $command."\n";
	system($command);
	$cnt++;
	if ($cnt % 100 == 0){
		my $now_time = time();
		my $diff_time = $now_time - $retval;
		#print "cnt:$cnt\nnow time:$now_time\n";
		my $rate = $cnt / $diff_time;
		print "processed $cnt lines at an average rate of $rate lines per second\n";
	}
}
close($fh);

sub printUsage{
	print "Usage: perl $0 <in.vcf> <out.vcf>\n";
	print "Description: db vcf <$download_vcf>\n";
	exit;
}
