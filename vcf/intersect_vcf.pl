#!/usr/bin/perl -w

use strict;

if (@ARGV != 2){
	printUsage();
}

my $INPUT_S = $ARGV[0];
my $VCF_OUT = $ARGV[1];

my $PATH_tabix = "/nG/Process/Tools/tabix/tabix-0.2.6";
my $bgzip = $PATH_tabix."/bgzip";
my $tabix = $PATH_tabix."/tabix";

my $vcftools = "/nG/Process/Tools/VCFtools/vcftools_0.1.10";
my $LIB_vcftools = $vcftools."/lib/perl5/site_perl";
my $PATH_vcftools = $vcftools."/bin";
my $concat = $PATH_vcftools."/vcf-isect";

print "export PATH=$PATH_tabix:\$PATH\n";

my @FILES = glob($INPUT_S);
for (my $i=0; $i<@FILES; $i++){
	my $command = "$bgzip -c $FILES[$i] > $FILES[$i].gz";
	if (!-f "$FILES[$i].gz"){
		print "$command\n";
		#system($command);
	}
	if (!-f "$FILES[$i].gz.tbi"){
		$command = "$tabix -p vcf $FILES[$i].gz";
		print "$command\n";
		#system($command);
	}
	$FILES[$i] = $FILES[$i].".gz";
}

my $infiles = "";
$infiles .= "$_ " foreach @FILES;

my $sc = "perl -I $LIB_vcftools $concat $infiles | $bgzip -c > $VCF_OUT";
print $sc."\n";
#system($sc);

sub printUsage{
	print "Usage: perl $0 <\"PATH/*.vcf\"> <out.vcf.gz>\n";
	print "Description: Concatenates VCF files (for example split by chromosome). Note that the input and output VCFs will have the same number of columns, the script does not merge VCFs by position\n";
	exit;
}
