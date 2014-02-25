#!/usr/bin/perl -w

use strict;

use File::Basename;
use Cwd 'abs_path';

if (@ARGV != 2){
	printUsage();
}

my $in_vcf = $ARGV[0];
my $out_vcf = $ARGV[1];
my ($filename,$path,$ext) = fileparse($out_vcf,qr/\.[^.]*/);

my $PWD = dirname(__FILE__);
my $root = abs_path($PWD);

# define tool path
my $convert2annovar = "$root/../../tools/annovar/convert2annovar.pl";

# prepare database

# prepare input file
my $convert_input = $in_vcf;
my $convert_output = "$path/$filename.av.input";
my $convert_log = "$path/$filename.av.log";
prepare_av_input($convert_input,$convert_output,$convert_log);

sub prepare_av_input{
	my $in = shift;
	my $out = shift;
	my $log = shift;
	my $format = "vcf4";
	#my $param = "-format $format $in -outfile $path/$filename -allsample -withzyg";
	my $param = "-format $format $in -outfile $path/$filename$ext";
	# -allsample : extract out file per each sample
	# -include : vcf information
	# -withzyg : het/hom, quality, read coverage
	# -comment : vcf comment
	my $command = "perl $convert2annovar $param 2> $log";
	print $command."\n";
	system($command);
}



sub printUsage{
	print "Usage: perl $0 <in.vcf> <out.vcf>\n";
	exit;
}
