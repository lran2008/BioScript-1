#!/usr/bin/perl
use warnings;
use strict;

## Program Info:
#
# Name:
#
# Function:
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
#   Version 1.0 (June 25, 2014): develop... no finish
##

use File::Basename;
use Cwd qw(abs_path);
use lib '/BiOfs/BioPeople/brandon/language/perl/lib/';

use Brandon::Bio::BioTools::PLINK;
use Brandon::Bio::BioPipeline::Queue;

use Data::Dumper;

my $merge_list_file = "merge.list"; 

my @files;
push @files, "/BiO/brandon/PAPGI/Data/PAPGI_WGS_filtered_plink/T1303D1173/chr22";
push @files, "/BiO/brandon/PAPGI/Data/PAPGI_WGS_filtered_plink/PUB-AUS0001-U01-G/chr22";
push @files, "/BiO/brandon/PAPGI/Data/PAPGI_WGS_filtered_plink/TN1311D4696/chr22";

my $infile = shift @files;

open my $fh, '>:encoding(UTF-8)', $merge_list_file or die;
foreach my $file_prefix (@files){
	print $fh "$file_prefix.ped $file_prefix.map\n";
}
close($fh);

my $mynewdata = "merge.out"; # out

my $tool_config = {
	file => $infile,
	merge_list => $merge_list_file,
	app => 'merge',
	out => $mynewdata,
};
my $plink_merge = Brandon::Bio::BioTools::PLINK->new($tool_config);
my $plink_merge_q = Brandon::Bio::BioPipeline::Queue->mini($plink_merge->{command},1);
$plink_merge_q->run();

