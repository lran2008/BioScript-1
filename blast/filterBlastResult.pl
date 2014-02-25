#!/usr/bin/perl -w

use strict;
use warnings;

my $infile = $ARGV[0];

my %target=(
BACU=> 0,
ENSB=> 0,
ENSS=> 0,
ENST=> 0,
ENSF=> 0,
ENSD=> 0
);

#delete_myself();
select_target();

sub delete_myself{
    open(DATA, $infile);
    while(<DATA>){
        chomp;
        
        my @line = split /\t/, $_;
        my $query = $line[0];
        my $subject = $line[1];
        
        if ((split /\|/, $query)[0] eq (split /\|/, $subject)[0]){
            #print "$query\t$subject\n";
            next;
        }
        my $out = join "\t", @line;
        
        print "$out\n";
    }
    close(DATA);
}

sub select_target{
    open(DATA, $infile);
    while(<DATA>){
        chomp;
        my @line = split /\t/, $_;
        my $query = $line[0];
        my $subject = $line[1];
        
        if (!defined $target{(split /\|/, $subject)[0]}){
            #print "$query\t$subject\n";
            next;
        }
        
        print "$_\n";
    }
    close(DATA);
}
