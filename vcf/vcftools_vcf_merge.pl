#!/usr/bin/perl -w

use strict;

use File::Basename;
use Cwd 'abs_path';

my $PWD = dirname(__FILE__);
my $root = abs_path($PWD);  

#vcftools_0.1.11
if (@ARGV != 2){
	printUsage();
}

my $INPUT_S = $ARGV[0];
my $VCF_OUT = $ARGV[1];

my $PATH_tabix = "/BiOfs/hmkim87/BioTools/tabix/0.2.6";
my $bgzip = $PATH_tabix."/bgzip";
my $tabix = $PATH_tabix."/tabix";

my $vcftools = "/BiOfs/hmkim87/BioTools/vcftools/0.1.12";
my $LIB_vcftools = $vcftools."/lib/perl5/site_perl";
my $PATH_vcftools = $vcftools."/bin";
my $merge = $PATH_vcftools."/vcf-merge";

$ENV{'PATH'}.= ":".$PATH_tabix;
#print "export PATH=$PATH_tabix:\$PATH\n";

my @FILES = glob($INPUT_S);
for (my $i=0; $i<@FILES; $i++){
	if ($FILES[$i] =~ /\.gz$/){
		next;	
	}
	my $command = "$bgzip -c $FILES[$i] > $FILES[$i].gz";
	if (!-f "$FILES[$i].gz"){
		print STDERR "$command\n";
		system($command);
	}
	if (!-f "$FILES[$i].gz.tbi"){
		$command = "$tabix -p vcf $FILES[$i].gz";
		print STDERR "$command\n";
		system($command);
	}
	$FILES[$i] = $FILES[$i].".gz";
}

my $infiles = "";
$infiles .= "$_ " foreach @FILES;

my $sc = "perl -I $LIB_vcftools $merge $infiles | $bgzip -c > $VCF_OUT";
print STDERR "$sc\n";
system($sc);

sub printUsage{
	print "Usage: perl $0 <\"PATH/*.vcf\"> <out.vcf.gz>\n";
	exit;
}

