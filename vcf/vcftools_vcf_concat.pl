#!/usr/bin/perl -w

use strict;
use File::stat;

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
my $concat = $PATH_vcftools."/vcf-concat";
my $vcf_sort = $PATH_vcftools."/vcf-sort";

#print "export PATH=$PATH_tabix:\$PATH\n";

my @FILES = glob($INPUT_S);
my @FILES_;
for (my $i=0; $i<@FILES; $i++){
	my $filesize = stat($FILES[$i])->size;
	if ($filesize eq 0){
		next;
	}
	push @FILES_, $FILES[$i];
}

for (my $i=0; $i<@FILES_; $i++){
	my $command = "$bgzip -c $FILES_[$i] > $FILES_[$i].gz";
	if (!-f "$FILES_[$i].gz"){
		#print "$command\n";
		system($command);
	}
	if (!-f "$FILES_[$i].gz.tbi"){
		$command = "$tabix -p vcf $FILES_[$i].gz";
		#print "$command\n";
		system($command);
	}
	$FILES_[$i] = $FILES_[$i].".gz";
}

my $infiles = "";
$infiles .= "$_ " foreach @FILES_;

#my $sc = "perl -I $LIB_vcftools $concat $infiles | $bgzip -c > $VCF_OUT";
my $sc = "perl -I $LIB_vcftools $concat $infiles > $VCF_OUT.noSorted";
#print $sc."\n";
system($sc);
#system($sc);

my $command = "cat $VCF_OUT.noSorted | $vcf_sort > $VCF_OUT";
#print $command."\n";
system($command);

sub printUsage{
	print "Usage: perl $0 <\"PATH/*.vcf\"> <out.vcf>\n";
	print "Description: Concatenates VCF files (for example split by chromosome). Note that the input and output VCFs will have the same number of columns, the script does not merge VCFs by position\n";
	exit;
}
