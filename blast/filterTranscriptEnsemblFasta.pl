#!/usr/bin/perl -w

use strict;

if (@ARGV != 1){
    printUsage();
}

my $infile = $ARGV[0];

my %hash;
my $geneID;
open(DATA, $infile);
while(<DATA>){
    chomp;
    if ($_ =~ /^>/){
        $geneID = (split /\s+/, $_)[3];
        if($geneID !~ /gene\:/){
            die;
        }
        
        $geneID =~ s/gene\://;
        if (defined $hash{$geneID}){
            next;
        }

        my $transcript_id = (split /\s+/, $_)[4];
        $transcript_id =~ s/\>//;
        
        my @array;
        $array[0] = $_;
        $array[1] = "";
        @{$hash{$geneID}} = @array;
        next;
    }
    @{$hash{$geneID}}[1] .= $_;
}
close(DATA);

foreach my $protein (keys %hash){
    print $hash{$protein}[0]."\n";
    print $hash{$protein}[1]."\n";
}

sub printUsage{
    print "Usage: perl $0 <ENSEMBL pep.all.fa>\n";
    exit;
}
