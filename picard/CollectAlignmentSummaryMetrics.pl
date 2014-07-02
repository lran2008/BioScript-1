#!/usr/bin/perl
use warnings;
use strict;

## Program Info:
#
# Name: Picard CollectAlignmentMetrics wrapper
#
# Function: run CollectAlignmentMetrics app in PICARD.
#
# Author: Hyunmin Kim
#  Copyright (c) Genome Research Foundation, 2014,
#  all rights reserved.
#
# Licence: This script may be used freely as long as no fee is charged
#    for use, and as long as the author/copyright attributions
#    are not removed.
#
# History:
#   Version 1.0 (July, 2 2014): first non-beta release.
##

use File::Basename;
use Cwd qw(abs_path);
use lib '/BiOfs/BioPeople/brandon/language/perl/lib/';

use Brandon::Bio::BioTools::PICARD;
use Brandon::Bio::BioPipeline::Queue;

use Getopt::Long;
use XML::Simple;

use Data::Dumper;

use File::Basename; 


my ( $debug, $helpFlag );
my ($input_file, $out_file, $ref_file);
Getopt::Long::Configure("pass_through"); #If pass_through is also enabled, options processing will terminate at the first unrecognized option, or non-option, whichever comes first.
GetOptions(
	'debug' => \$debug,
        "h|?|help" => \$helpFlag,
        "i|input=s" => \$input_file,
        "o|output=s" => \$out_file,
	"r|reference=s" => \$ref_file,
);

my $msg = "Arguments: [-i input bam file] [-o output report file] [-r reference fasta file] (-d debug mode)\t\n";
checkOptions();

run($input_file,$ref_file,$out_file);

sub checkOptions{
	if ($helpFlag || !$input_file || !$out_file || !$ref_file){
		die ($msg);
	}
}

sub run{
	my ($input, $ref, $output) = @_;

	my ($inputname,$inputpath,$inputext) = fileparse($input, qr/\.[^.]*/); 
	
	my $tool_config={
		INPUT => $input,
		OUTPUT => $output,
		REFERENCE_SEQUENCE => $ref,
		VALIDATION_STRINGENCY => 'LENIENT',
		app => 'CollectAlignmentSummaryMetrics',
	};
	my $proc = Brandon::Bio::BioTools::PICARD->new($tool_config);
	my $job = Brandon::Bio::BioPipeline::Queue->mini($proc,$debug);
	$job->run();
}

sub printUsage{
	exit;
}
