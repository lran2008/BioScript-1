#!/usr/bin/perl -w
## VERSION updated April 25, 2012  MJA
$version = "0.3";

=head1 LICENSE

trim_illumina_sRNA_fastq.pl

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

Trim the 3' ends from a DNA-spaced FASTQ-Illumina file based on user-supplied adapter sequence.

In nearly all small RNA sequencing experiments, the read-length is longer than the biological RNAs of interest.  Typically the 1st nt of the sequencing read is the 5', sense nt of the biological RNA, and the end of the biological small RNA occurs somewhere in the middle of read.  This program identifies the 3' adapter using fuzzy matching, and trims it from the input read and from the corresponding quality values, and outputs the properly trimmed data in FASTQ-Illumina format.

=head1 INSTALL

ensure the script is executable

    chmod +x trim_illumina_sRNA_fastq.pl

ensure the script is in your PATH (examples):

    sudo cp trim_illumina_sRNA_fastq.pl /usr/bin/

OR just for one session assuming script is in your working directory:
    
    PATH=$PATH:.
    
ensure 'perl' is located in /usr/bin/ .. if not, edit line 1 of script accordingly

ensure String::Approx is installed to your PERL .. http://search.cpan.org/~jhi/String-Approx-3.26/Approx.pm

=head1 USAGE

usage for fastq.gz compressed files:

    gzip -d -c [input.fastq.gz] | trim_illumina_sRNA_fastq.pl -o [ok.fastq] -p [pseudo-trimmed.fastq] -a [adapter_sequence] -e [max_edit_distance] -q [Y/N]

usage for uncompressed .fastq files:

    trim_illumina_sRNA_fastq.pl -o [ok.fastq] -p [pseudo-trimmed.fastq] -a [adapter_sequence] -e [max_edit_distance] -q [Y/N] < [input.fastq]

=head1 OPTIONS

All options are required to be supplied by the user

-o : name of the output .fastq file containing properly trimmed reads.  If file already exists, program will quit and complain

-p : name of the output .fastq file containing 'psuedo-trimmed' reads (see below).  If file already exists, program will quit and complain.

-a : Adapter sequence to search for.  Must be at least 8 character in length, and contain only ACTUGactug characters.  Only the first 15nts of the supplied adapter will be used if you provide a longer sequence

-e : Maximum allowed edit distance to match the adapter.  Must be either 0, 1, or 2.  Only substitutions are allowed, no insertions or deletions.

-q : Output quality values? (Y/N).  e.g. report in fastq format (Y) or fasta format (N).  Default is Y  

=head1 NOTES

=head2 Pseudotrimmed reads

Reads for which no adapter was matched fall into one of two categories:  Machine noise/total garbage, and biological RNAs longer than (read_length - adapter_length).  In many experiments these are not useful, but there may be some cases where examining these reads is desired.  A conservative approach is taken, where the read is 'pseudo-trimmed' by removing x nts off of the 3' end, where x = (read_length - adapter_length + 1).  This fully removes any non-recognized bits of adapter off of the 3' end.  For example, for 50nt reads and a 15nt adapter, the maximum RNA size that can be correctly recognized is 35nts; any non-adapter matched reads wiould be pseudo-trimmed to 36nts in length.  HOWEVER, it is important to remember that for these reads the 'pseudo-trimmed' size does NOT represent the true size of the original RNA, and that is why they are put into a separate file.  In addition, a lot of them are probably garbage.

=head2 Non-reported reads

There are three categories of reads that don't get reported:  Rejected, Adapter-dimers, and too-short.  Rejected reads have one or more non ATCG characters after trimming.  Adapter-dimers have an adapter-match right at the first nt.  Too short RNAs are those that are between 1 and 14nts after adapter trimming.  The output tracks these but they are not reported in the fastq output files

=head2 What if I don't know my adapter sequence?

You can use a script called 'find_3p_adapter.pl' to infer your 3p adapter sequence.  This requires that you know (or at least are pretty sure) of the sequence of an abundant microRNA in your sample.  See documentation for 'find_3p_adapter.pl' for more details.

=head2 No Paired-End support

This program is built for single-end fragments.  In general, we don't expect to encounter paired-end experiments for small RNA experiments, as the small RNAs of interest are shorter than the typical nex-gen read lengths.

=head1 ACKNOWLEDGEMENTS

The usage of String::Approx was suggested by Istvan Albert.  The specific implementation of String::Approx 'amatch' was closely modeled after that found in http://www.bcgsc.ca/platform/bioinfo/software/adapter-trimming-for-small-rna-sequencing, Authored by Andy Chu at the BC Cancer Agency, Canada's Michael Smith Genome Sciences Center

=head1 VERSIONS

0.1 : Initial release  March 9, 2012

0.2 : March 27, 2012 : Added option to output just .fasta of trimmed and pseudo-trimmed reads, omitting quality values

0.3 : April 25, 2012 : Fixed bug that caused mis-parsing of fastq files where the "plus sign" line includes the header information, instead of just being a + sign

=head1 AUTHOR

Michael J. Axtell, Penn State University, mja18@psu.edu

=cut

## Begin main program

use Getopt::Std;  ## Standard in most (all?) perl installations
use String::Approx 'amatch';  ## http://search.cpan.org/~jhi/String-Approx-3.26/Approx.pm

# get options, validate them

$usage = "USAGE:\n" . 
    
    "gzip -d -c \[input.fastq.gz\] \| trim_illumina_sRNA_fastq.pl -o \[ok.fastq\] -p \[pseudo-trimmed.fastq\] -a \[adapter_sequence\] -e \[max_edit_distance\] -q [Y\/N]
OR
trim_illumina_sRNA_fastq.pl -o \[ok.fastq\] -p \[pseudo-trimmed.fastq\] -a \[adapter_sequence\] -e \[max_edit_distance\] -q [Y\/N] < \[input.fastq\]\n\n" . 

    
    
    "-o : name of trimmed output fastq file\n" . 
    "-p : name of \'pseudo-trimmed\' fastq file, which will contain reads that weren't adapter-matched, but chopped to remove \(adapter length - 1\) nts from the 3prime\n" . 
    "-a : adapter sequence to be used \(NOTE: must be >=8 in length\; if longer than 15, only the first 15 nts will be used\)\n" . 
    "-e : edit distance allowed \(NOTE: no indels allowed, 0,1,2 are the only valid choices\)\n" . 
    "-q : output quality values\? \(Y\/N\) \(DEFAULT: Y all non\'N\' entries are treated as \'Y\'\)\n" .
    "\nType perldoc $0 for detailed documentation\n";

getopt('opaeq');

$first_time = 0;

unless($opt_a) {
    die "FATAL: No adapter sequence provided\n$usage\n";
}
# convert adapter to upper-case, Ts not Us, and check
$adapter = uc $opt_a;
$adapter =~ s/U/T/g;
if($adapter =~ /[^ATGC]/) {
    die "FATAL: Your adapter sequence $opt_a is not valid because in contains one or more non-nt characters\n$usage\n";
} elsif ((length $adapter) < 8) {
    die "FATAL: Your adapter sequence $opt_a is too short, should be 8nts or longer\n$usage\n";
} elsif ((length $adapter) > 15) {
    $adapter = substr($adapter,0,15);
    print STDERR "Your adapter sequence is being trimmed to 15nts long for matching purposes\; sequence used: $adapter\n";
}

# open outfile -- quit if it already exists
if (-e $opt_o) {
    die "FATAL:  outfile -o $opt_o already exists\n$usage\n";
} else {
    open(OKOUT, ">$opt_o");
}
# open pseudo-trimmed outfile -- quit if it already exists
if (-e $opt_p) {
    die "FATAL: psuedo-trimmed outfile -p $opt_p already exists\n$usage\n";
} else {
    open(POUT, ">$opt_p");
}

unless($opt_q eq "N") {
    $opt_q = "Y";
}

## check on edit distance
unless(($opt_e >= 0) and
       ($opt_e <= 2)) {
    die "FATAL: edit distance must be 0, 1, or 2\n$usage\n";
}

# report on the settings of the run

print STDERR "$0 version $version\n";
print STDERR `date`;
print STDERR "directory: ";
print STDERR `pwd`;
print STDERR "trimmed output file \(-o\): $opt_o\n";
print STDERR "pseudo-trimmed output file \(-p\): $opt_p\n";
print STDERR "Adapter sequence used: $adapter\n";
print STDERR "Maximum edit distance allowed: $opt_e\n";
print STDERR "Output quality values\? : $opt_q\n\n";

# Tracking variables ....
$total = 0;  ## all reads in the input fastq file
%offsets = ();  ## hash tracking found offsets inlcuding error codes
$too_short = 0;
$adapter_dimers = 0;
$rejected_reads = 0;  ## after trimming, the read had one or more ambiguous characters
$no_adapters = 0;  ## no adapters found.  trimmed maximally and output to a separate fastq file
$ok = 0;  ## number of trimmed small RNAs >=15nts in length

# a progress monitor.. dots for every 50,000 reads analyzed, line return and note for each million
$small_count = 0;
$dot_count = 0;
$millions = 0;

# open fastq file and read line by line
# strict requirement for fastq format, with qual string of same length as read string

while (<STDIN>) {
    chomp;
    $read_name = $_;  ## always, assuming no header lines
    unless($read_name =~ /^@/) {  ## this is how fastq headers look but could conceivably also be a qual string, one weakness there
	die "Error in fastq format  line $_ should have been a header\n";
    }
    $sequence = <STDIN>;
    $sequence =~ s/\n//g;
    $plus_sign = <STDIN>;
    $plus_sign =~ s/\n//g;
    $quals = <STDIN>;
    $quals =~ s/\n//g;
    
    ++$total;   ## tallies the total reads in the original file
    
    ## progress tracking
    ++$small_count;
    if($small_count == 50000) {
	print STDERR ".";
	++$dot_count;
	$small_count = 0;
	if($dot_count == 20) {
	    ++$millions;
	    $dot_count = 0;
	    print STDERR " $millions million analyzed and counting\n";
	}
    }
    
    
    ## ensure compliance with expected fastq format .. qual string same size as sequence string, and plus sign really is a line that begins with a plus sign
    unless((length $quals) == (length $sequence) and
	   ($plus_sign =~ /^\+/)) {
	die "FASTAL: FASTQ parsing error at :\n$read_name\n$sequence\n$plus_sign\n$quals\n\n$usage\n";
    }
    
    $offset = find_adapter ($sequence, $adapter, $opt_e);
    
    # if the offset is >= 1 and <= 14, the read is too short and is suppressed from fastq output
    # track as too short
    if(($offset >= 1) and ($offset <= 14)) {
	++$too_short;
	++$offsets{$offset};
    } elsif ($offset == 0) {
	++$adapter_dimers;
	++$offsets{$offset};
    } else {
	## in this loop, the offset is either -1 (no adapter found), or some allowable value
	## first examine the adapter not found case .. -1
	if($offset == -1) {
	    ## trim off adapter_size -1 from the read
	    $trimmed_sequence = substr($sequence,0,((length $sequence) - (length $adapter) + 1));
	    $trimmed_quals = substr($quals,0,((length $quals) - (length $adapter) + 1));
	    
	    ## check that the trimmed sequence has only A,C,G, or T.  If there are ambiguous characters, reject the read, and give it offset of -2
	    if($trimmed_sequence =~ /[^ACTG]/) {
		$offset = -2;
		++$rejected_reads;
	    } else {
		++$no_adapters;
		## output to the 'pseudo-trimmed' fastq file
		# check for qual values
		if($opt_q eq "Y") {
		    print POUT "$read_name\n$trimmed_sequence\n$plus_sign\n$trimmed_quals\n";
		} else {
		    $fa_read_name = $read_name;
		    $fa_read_name =~ s/^@/>/;
		    print POUT "$fa_read_name\n$trimmed_sequence\n";
		}
	    }
	    ++$offsets{$offset};
	} else {
	    ## here are the found adapters that were not too short or adapter dimers
	    ## trim them
	    $trimmed_sequence = substr($sequence,0,$offset);
	    $trimmed_quals = substr($quals,0,$offset);
	    ## check that the trimmed sequence has only A,C,G, or T.  If there are ambiguous characters, reject the read, and give it offset of -2
	    if($trimmed_sequence =~ /[^ACTG]/) {
		$offset = -2;
		++$rejected_reads;
	    } else {
		++$ok;
		## output to the properly trimmed file
		if($opt_q eq "Y") {
		    print OKOUT "$read_name\n$trimmed_sequence\n$plus_sign\n$trimmed_quals\n";
		} else {
		    $fa_read_name = $read_name;
		    $fa_read_name =~ s/^@/>/;
		    print OKOUT "$fa_read_name\n$trimmed_sequence\n";
		}
		## show the details of an example trim .. the first one completed.
		unless($first_time) {
		    print STDERR "Trim Example\n";
		    print STDERR "$read_name\n$sequence\n";
		    for($i = 1; $i <= (length $trimmed_sequence); ++$i) {
			print STDERR " ";
		    }
		    print STDERR "$adapter  ADAPTER\n";
		    print STDERR "$plus_sign\n$quals\n\n";
		    if($opt_q eq "Y") {
			print STDERR "RESULT:\n$read_name\n$trimmed_sequence\n+\n$trimmed_quals\n\n";
		    } else {
			print STDERR "RESULT:\n$fa_read_name\n$trimmed_sequence\n\n";
		    }
		}
		$first_time = 1;
	    }
	    ++$offsets{$offset};
	}
    }
}
close OKOUT;
close POUT;


## report

$reject_perc = sprintf("%.3f",(($rejected_reads / $total) * 100));
$adapter_dimer_perc = sprintf("%.3f",(($adapter_dimers / $total) * 100));
$too_short_perc = sprintf("%.3f",(($too_short / $total) * 100));
$ok_perc = sprintf("%.3f",(($ok / $total) * 100));
$no_ad_perc = sprintf("%.3f",(($no_adapters / $total) * 100));

print STDERR "\n\nAnalysis complete at ";
print STDERR `date`;
print STDERR "Total reads analyzed from input file: $total
Rejected after trimming because of ambiguous nt\(s\): $rejected_reads \($reject_perc \%\)
Apparent adapter dimers: $adapter_dimers \($adapter_dimer_perc \%\)
Too short \(less than 15nts\): $too_short \($too_short_perc \%\)
Properly trimmed: $ok \($ok_perc \%\) -- in file $opt_o
No adapters found, pseudo-trimmed: $no_adapters \($no_ad_perc \%\) -- in file $opt_p

Small_RNA_size\tReads\n";

@off_keys = sort {$a <=> $b} (keys %offsets);
# fill in missing internal values
$min = $off_keys[0];
$max = $off_keys[-1];
for($i=$min;$i<=$max;++$i) {
    unless(exists($offsets{$i})) {
	$offsets{$i} = 0;
    }
}
@off_keys = sort {$a <=> $b} (keys %offsets);
foreach $key (@off_keys) {
    print STDERR "$key\t$offsets{$key}";
    if($key == -2) {
	print STDERR "\tRejected Reads\n";
    } elsif ($key == -1) {
	print STDERR "\tPsuedo-trimmed Reads -- file $opt_p\n";
    } elsif ($key == 0) {
	print STDERR "\tAdapter dimers\n";
    } elsif ($key < 15) {
	print STDERR "\tToo short, output suppressed\n";
    } else {
	print STDERR "\tOK, in file $opt_o\n";
    }
}
	

############################################################################
### SUB-ROUTINES

sub find_adapter {
    ## modeled after http://www.bcgsc.ca/platform/bioinfo/software/adapter-trimming-for-small-rna-sequencing, Authored by Andy Chu
    ## String::Approx initially suggested by Istvan Albert
    
    my $read = shift;
    my $adapter = shift;
    my $edits = shift;
    my $read_length = length $read;
    my $adap_length;
    
    ## first, check and see if the adapter, or a 1-3 nt truncated version of the adapter, matches the 'head' of the read
    ## if it does, this is an adapter dimer, and we will return zero
    for (my $i = 0; $i < 4; ++$i) {
	$adap_length = (length $adapter) - $i;
	return 0 if amatch(substr($adapter,$i,$adap_length), ["$edits", "S$edits", "I0", "D0", "initial_position=0", "final_position=$adap_length"], $read);
    }
    
    ## Now check for an exact match first, to save time
    my $index_pos = index($read, $adapter);
    return $index_pos if $index_pos > 0;
    
    ## check for a fuzzy match
    for ( my $i = $read_length - $adap_length; $i > 0; --$i) {
	return $i if amatch($adapter, ["$edits", "S$edits", "I0", "D0", "initial_position=$i"], $read);
    }
    
    ## if no matches were found (or some other failure), reutrn -1
    return -1;
}
