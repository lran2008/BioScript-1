#!/usr/bin/perl -w
$version = "0.2";
## updated March 9, 2012  MJA


=head1 LICENSE

find_3p_adapter.pl

Copyright (C) 2012 Michael J. Axtell

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=head1 SYNOPSIS

Given an untrimmed .fastq-illumina file of small RNA sequencing data, and the sequence of a known, highly abundant microRNA, identify all reads containing that microRNA, and track the apparent 3' adapters.  Report the top four adapter sequences found.  Usually the most abundant one is the 'true' sequence of the 3' adapter used to create the library.

=head1 INSTALL

ensure the script is executable

    chmod +x find_3p_adapter.pl

ensure the script is in your PATH (examples):

    sudo cp find_3p_adapter.pl /usr/bin/

OR just for one session assuming script is in your working directory:
    
    PATH=$PATH:.
    
ensure 'perl' is located in /usr/bin/ .. if not, edit line 1 of script accordingly

=head1 USAGE

usage for fastq.gz compressed files:

    gzip -d -c [input.fastq.gz] | find_3p_adapter.pl -m [miRNA_sequence]

usage for uncompressed .fastq files:

    find_3p_adapter.pl -m [miRNA_sequence] < [input.fastq]

Output goes to STDERR

=head1 OPTIONS

All options are required to be supplied by the user

-m : sequence of a known microRNA that is abundant in your dataset, 5'-3', only ACTGUactgu characters allowed

=head1 NOTES

=head2 Choice of microRNA

Hopefully you know the sequence of a few microRNAs that should be highly abundant in your sample. In plants, I routinely use ath-miR156a, ath-miR166a, and ath-miR390a, as they are all highly conserved and often highly expressed in most samples.

=head1 VERSIONS

0.1 : Unreleased internal version

0.2 : This version .. fastq input as stream to enable use with compressed files, documentation added.  March 9, 2012

=head1 AUTHOR

Michael J. Axtell, Penn State University, mja18@psu.edu

=cut

use Getopt::Std;
$usage = "USAGE:

gzip -d -c \[.fastq.gz\] \| find_3p_adapter\.pl -m \[miRNA_sequence\]

OR

find_3p_adapter\.pl -m \[miRNA_sequence\] < \[.fastq\]

-m : known abundant microRNA sequence, 5prime to 3prime, case-insensitive, U or T OK
type perldoc $0 for detailed documentation
";

getopt('m');

unless($opt_m) {
    die "FATAL: no microRNA sequence provided\n$usage\n";
}

%adapters = ();
$n = 0; ## number of matches to the input microRNA
$x = 0; ## total number of reads analyzed

# force query to be upper-case, Ts not Us
$query = uc $opt_m;
$query =~ s/U/T/g;
if($query =~ /[^ATGC]/) {
    die "FATAL: Query microRNA $opt_m does not appear to be a nucleic acid\.  Ensure ACTUGactug characters only\n$usage\n";
}

# session report
print STDERR "$0 version $version\n";
print STDERR `date`;
print STDERR "directory: ";
print STDERR `pwd`;
print STDERR "Query sequence: $query\n";
print STDERR "\n\tSearching\.\.\.";

# search

while (<STDIN>) {
    $trash = $_; ## header
    $seq = <STDIN>;
    if($seq =~ /^$query/) {
	$seq =~ s/$&//g;
	$seq =~ s/\n//g;
	++$n;
	++$adapters{$seq};
    }
    $trash = <STDIN>; ## the + sign
    $trash = <STDIN>; ## the quality values
    ++$x;
}

# report
print STDERR "Done\n\n";
if($n) {
    # calculate reads per million
    $rpm = int(($n / $x) * 1000000);
    print STDERR "$n out of $x reads matched query $query \($rpm reads per million\)\n";
    print STDERR "\nHere are the top four adapters found:\n";
    print STDERR "Sequence\tFrequency\n";
    # sort hash by values
    @sorted = sort { $adapters{$b} <=> $adapters{$a} } keys %adapters;
    print STDERR "$sorted[0]\t$adapters{$sorted[0]}\t";
    $perc = sprintf("%.3f",(($adapters{$sorted[0]}/$n) * 100));
    print STDERR "$perc \%\n";
    print STDERR "$sorted[1]\t$adapters{$sorted[1]}\t";
    $perc = sprintf("%.3f",(($adapters{$sorted[1]}/$n) * 100));
    print STDERR "$perc \%\n";
    print STDERR "$sorted[2]\t$adapters{$sorted[2]}\t";
    $perc = sprintf("%.3f",(($adapters{$sorted[2]}/$n) * 100));
    print STDERR "$perc \%\n";
    print STDERR "$sorted[3]\t$adapters{$sorted[3]}\t";
    $perc = sprintf("%.3f",(($adapters{$sorted[3]}/$n) * 100));

    print STDERR "$perc \%\n";
} else {
    print STDERR "Query $query was NOT found at the 5' end of any reads in this stream";
}

