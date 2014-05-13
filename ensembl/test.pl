#!/usr/bin/perl

use strict;
use warnings;

use lib "/BiO/hmkim87/BioTools/Ensembl/src/ensembl/modules";
use Bio::EnsEMBL::Registry;

my $reg = 'Bio::EnsEMBL::Registry';

$reg->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous'
);

my $slice_adaptor = $reg->get_adaptor( 'human', 'core', 'slice');

my $chromosome = '7';
my $position = 24966446;
my $offset = 60;

my $slice = $slice_adaptor->fetch_by_region('chromosome', $chromosome, $position-$offset, $position+$offset);

print $slice->seq;
