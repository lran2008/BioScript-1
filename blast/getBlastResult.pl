#!/usr/bin/perl -w

use strict;

#my $target = "BACU";
my $target = $ARGV[0];
my $path = "/BiO3/hmkim87/orthoMCL/69_fasta/split/*.out";
my @infile = glob($path);

foreach my $file (@infile){
    open(DATA, $file);
    while(<DATA>){
        chomp;
        my $query = (split /\t/, $_)[0];
        my $subject = (split /\t/, $_)[0];

        $query =~ /(\D+)\d+/;
        my $species_name = $1;
        if ($species_name ne $target){
            #print "$file\t$species_name\t$target\n";
            next;
        }
        print $_."\n";
    }
    close(DATA);
}
