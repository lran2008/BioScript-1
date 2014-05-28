#!/usr/bin/perl  -w

use strict;
use File::Basename;

if (@ARGV !=3){
	printUsage();
}
my $bin = "/gg/bio/tools/ea-utils/fastq-mcf";

my $min_len_match = "-s 2.2"; # Log scale for adapter minimum-length-match (2.2)
my $adapter_occur_threshold = "-t 0.25"; #% occurance threshold before adapter clipping (0.25)
my $min_clip_len = "-m 1";
my $max_adapter_diff = "-p 10";
my $min_remain_seq_len = "-l 19";
#my $max_remain_seq_len = undef;
my $sKew_per = "-k 2";
my $bad_read_per_threshold = "-x 20";
my $quality_threshold = "-q 20";
my $trim_win_size = "-w 1";
#my $illuminPF = undef;
#my $donot_trim_N = "-R";
my $subsampling = "-C 300000";
#my $save_skipped_reads = "-S";
my $r1 = $ARGV[0];
my $r2 = $ARGV[1];

my ($r1_name,$r1_dir,$r1_ext) = fileparse($r1, qr/\.[^.]*/);
my ($r2_name,$r2_dir,$r2_ext) = fileparse($r2, qr/\.[^.]*/);

my $seq;
if ($r1 =~ /\.gz$/ and $r2 =~ /\.gz$/){
	$r1 = "gunzip -c $r1;";
	$r2 = "gunzip -c $r2;";
	$seq = `zcat $r1_dir$r1_name | sed -n '2p'`;
	chomp($seq);
}else{
	$seq = `cat $r1 | sed -n '2p'`;
	chomp($seq);
}
my $seq_len = length($seq);
$min_remain_seq_len = "-l $seq_len";

my $adaptersFa = $ARGV[2];
#$adaptersFa = "/dev/null";

my $out_r1 = "$r1_dir/$r1_name.clean$r1_ext";
my $out_r2 = "$r2_dir/$r2_name.clean$r2_ext";

my $inputs = "<($r1) <($r2)";
my $statFile = "$r1_dir/$r1_name.fastq-mcf.stat";

# param
my @params;
push @params, $min_len_match;
push @params, $adapter_occur_threshold;
push @params, $min_clip_len;
push @params, $max_adapter_diff;
push @params, $min_remain_seq_len;
push @params, $sKew_per;
push @params, $bad_read_per_threshold;
push @params, $quality_threshold;
push @params, $trim_win_size;
push @params, $subsampling;

my $options = join " ", @params;

my $command;
$command = "$bin $options -o $out_r1 -o $out_r2 $adaptersFa $inputs > $statFile";
print $command."\n";

sub printUsage{
	print "Usage: perl $0 <read1.fq> <read2.fq> <adapter.fa>\n";
	exit;
}

=pod

https://code.google.com/p/ea-utils/wiki/FastqMcf

Usage: fastq-mcf [options] <adapters.fa> <reads.fq> [mates1.fq ...]
Version: 1.04.636

Detects levels of adapter presence, computes likelihoods and
locations (start, end) of the adapters.   Removes the adapter
sequences from the fastq file(s).

Stats go to stderr, unless -o is specified.

Specify -0 to turn off all default settings

If you specify multiple 'paired-end' inputs, then a -o option is
required for each.  IE: -o read1.clip.q -o read2.clip.fq

Options:
    -h       This help
    -o FIL   Output file (stats to stdout)
    -s N.N   Log scale for adapter minimum-length-match (2.2)
    -t N     % occurance threshold before adapter clipping (0.25)
    -m N     Minimum clip length, overrides scaled auto (1)
    -p N     Maximum adapter difference percentage (10)
    -l N     Minimum remaining sequence length (19)
    -L N     Maximum remaining sequence length (none)
    -D N     Remove duplicate reads : Read_1 has an identical N bases (0)
    -k N     sKew percentage-less-than causing cycle removal (2)
    -x N     'N' (Bad read) percentage causing cycle removal (20)
    -q N     quality threshold causing base removal (10)
    -w N     window-size for quality trimming (1)
    -H       remove >95% homopolymer reads (no)
    -0       Set all default parameters to zero/do nothing
    -U|u     Force disable/enable Illumina PF filtering (auto)
    -P N     Phred-scale (auto)
    -R       Dont remove Ns from the fronts/ends of reads
    -n       Dont clip, just output what would be done
    -C N     Number of reads to use for subsampling (300k)
    -S       Save all discarded reads to '.skip' files
    -d       Output lots of random debugging stuff

Quality adjustment options:
    --cycle-adjust    CYC,AMT     Adjust cycle CYC (negative = offset from end) by amount AMT
    --phred-adjust    SCORE,AMT   Adjust score SCORE by amount AMT

Filtering options*:
    --[mate-]qual-mean  NUM       Minimum mean quality score
    --[mate-]qual-gt    NUM,THR   At least NUM quals > THR
    --[mate-]max-ns     NUM       Maxmium N-calls in a read (can be a %)
    --[mate-]min-len    NUM       Minimum remaining length (same as -l)
    --hompolymer-pct    PCT       Homopolymer filter percent (95)

If mate- prefix is used, then applies to second non-barcode read only

Adapter files are 'fasta' formatted:

Specify n/a to turn off adapter clipping, and just use filters

Increasing the scale makes recognition-lengths longer, a scale
of 100 will force full-length recognition of adapters.

Adapter sequences with _5p in their label will match 'end's,
and sequences with _3p in their label will match 'start's,
otherwise the 'end' is auto-determined.

Skew is when one cycle is poor, 'skewed' toward a particular base.
If any nucleotide is less than the skew percentage, then the
whole cycle is removed.  Disable for methyl-seq, etc.

Set the skew (-k) or N-pct (-x) to 0 to turn it off (should be done
for miRNA, amplicon and other low-complexity situations!)

Duplicate read filtering is appropriate for assembly tasks, and
never when read length < expected coverage.  -D 50 will use
4.5GB RAM on 100m DNA reads - be careful. Great for RNA assembly.

*Quality filters are evaluated after clipping/trimming
=cut
