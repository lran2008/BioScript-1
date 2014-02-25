#!/usr/bin/perl -w

use strict;
use File::Basename;
use Cwd 'abs_path';
use FindBin;  # locate this script
use lib "$FindBin::Bin/";
use Vcf;

if (@ARGV !=2){
	printUsage();
}
my $invcf = $ARGV[0];
my $outvcf = $ARGV[1];

my $PWD = dirname(__FILE__);
my $root = abs_path($PWD);

my ($filename,$path,$ext) = fileparse($outvcf, qr/\.[^.]*/);

my $vcfEffOnePerLine = "$root/../../tools/snpEff/scripts/vcfEffOnePerLine.pl";
my $snpsift = "$root/../../tools/snpEff/SnpSift.jar";
#my $vcfbreakmulti = "$root/../../tools/vcflib/bin/vcfbreakmulti";
#my $vcf2tsv = "$root/../../tools/vcflib/bin/vcf2tsv";

# get samples information
my $vcf = Vcf->new(file=>$invcf);
$vcf->parse_header();
my (@samples) = $vcf->get_samples();
vcfEffOnePerLine_vcf2tsv($invcf,$outvcf);

sub vcfEffOnePerLine_vcf2tsv{
        my $vcf = shift;
        my $out = shift;

        #extract basic column in vcf (e.g CHROM, POS, REF, ALT, EFF[*].EFFECT, PhastCons)
        my $query = get_column_name("$root/general.txt");
        my $command = "cat $vcf | perl $vcfEffOnePerLine | java -jar $snpsift extractFields - $query > $vcf.general.tmp";
        print $command."\n";
        #system($command);
        #extract only related to sample column (e.g AD,DP,GQ,GT and PL)
        my $sample_query = get_column_name("$root/sample.txt");
        $command = "cat $vcf | perl $vcfEffOnePerLine | java -jar $snpsift extractFields - $sample_query > $vcf.sample.tmp";
        print $command."\n";
        #system($command);
        # delete raw header
        $command = "awk 'FNR>1{print}' $vcf.sample.tmp > $vcf.sample.noHeader.tmp";
        print $command."\n";
        #system($command);
        # add new header
        my @arr_header;
        my @ids = split / /, $sample_query;
        foreach my $id (@ids){
                $id = (split /\./, $id)[1];
                foreach my $sample (@samples){
                        push @arr_header, $sample.".".$id;
                }
        }
        my $head_content = join "\\t", @arr_header;
        $command = "echo \"$head_content\" > $vcf.sample.Header.tmp";
        print $command."\n";
        #system($command);
        $command = "cat $vcf.sample.Header.tmp $vcf.sample.noHeader.tmp > $vcf.sample.final.tmp";
        print $command."\n";
        #system($command);

        # paste general + sample
        $command = "paste $vcf.general.tmp $vcf.sample.final.tmp > $path/sample.final.raw.tmp";
        print $command."\n";
        #system($command);
        # changeHeaderKey
        $command = "sed -e \"".
        "s/^#CHROM/CHROM/;".
        "s/EFF\\[\\*\\]\\.EFFECT/EFFECT/;".
        "s/EFF\\[\\*\\]\\.IMPACT/IMPACT/;".
        "s/EFF\\[\\*\\]\\.FUNCLASS/FUNCLASS/;".
        "s/EFF\\[\\*\\]\\.CODON/CODON_CHANGE/;".
        "s/EFF\\[\\*\\]\\.AA_LEN/AA_LENGTH/;".
        "s/EFF\\[\\*\\]\\.AA/AA_CHANGE/;".
        "s/EFF\\[\\*\\]\\.GENE/GENE/;".
        "s/EFF\\[\\*\\]\\.BIOTYPE/BIOTYPE/;".
        "s/EFF\\[\\*\\]\\.CODING/CODING/;".
        "s/EFF\\[\\*\\]\\.TRID/TRANSCRIPT/;".
        "\" $path/sample.final.raw.tmp > $path/all.annotated.tsv";
        print $command."\n";
        #system($command);
}

sub printUsage{
	print "Usage: perl $0 <in.vcf> <out.vcf>\n";
	exit;
}
