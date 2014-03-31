#!/usr/bin/perl -w

use strict;

use File::Basename; 

my $kgvcfpath = "/BiOfs/hmkim87/BioResources/Reference/Human/Resources/1000genome/ALL.2of4intersection.20100804.genotypes.vcf.gz";

if (@ARGV !=2){
	printUsage();
}
my $infile = $ARGV[0];
my $outfilepath = $ARGV[1];

my $bgzip = "/BiOfs/hmkim87/BioTools/tabix/0.2.6/bgzip";
my $tabix = "/BiOfs/hmkim87/BioTools/tabix/0.2.6/tabix";

=pod
if ($vcf_file !~ /\.gz$/){
	print "$bgzip $vcf_file\n";
	#system("$bgzip $vcf_file");
	$vcf_file = $vcf_file.".gz";
}

if (!-f $vcf_file.".tbi"){
	print "$tabix $vcf_file\n";
	#system("$tabix $vcf_file");
}
=cut

my ($filename,$filepath,$fileext) = fileparse($infile, qr/\.[^.]*/); 

my $command = "$tabix -H $kgvcfpath > $outfilepath";
#print $command."\n";
system($command);

my $cnt = 0;
my $retval = time();
my $start_time = gmtime( $retval);
open my $fh, '<:encoding(UTF-8)', $infile or die;
while (my $row = <$fh>) {
	if ($row =~ /^#/){
		next;
	}
        chomp $row;
	my @l = split /\t/, $row;

	my $chr = $l[0];
	my $pos = $l[1];
	if ($chr =~ /^chr/){
		$chr =~ s/^chr//;
	}
	$command = "$tabix $kgvcfpath $chr:$pos-$pos >> $outfilepath";
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
	exit;
}
