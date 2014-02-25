#!/usr/bin/perl -w

use strict;

# tool
my $fastx_toolkit_path = "/gg/tool/fastx_toolkit_0.0.13/bin";
my $fastq_quality_filter = $fastx_toolkit_path."/fastq_quality_filter";
my $fastx_clipper = $fastx_toolkit_path."/fastx_clipper";
my $prinseq = "/gg/tool/prinseq-lite-0.20.4/prinseq-lite.pl";
my $prinseq_graphs = "/gg/tool/prinseq-lite-0.20.4/prinseq-graphs.pl";

# prinseq params
my @params = qw(
-ns_max_p 5
-trim_tail_left 6
-trim_tail_right 6
-min_qual_mean 5
-derep 1
-derep_min 2
-trim_left 1 
-trim_right 1
);
#trim_tail http://ccb.jhu.edu/software/fqtrim/index.shtml

my $param = join " ", @params;
my $r1 = "/gg/data/fastq/testdata_R1.fq";
my $r2 = "/gg/data/fastq/testdata_R2.fq";
my $out_good = "null";
my $out_bad = "null";
my $logfile = "/gg/tmp/prinseq/log.txt";
my $graph_data = "/gg/tmp/prinseq/graph.data";
my $prinseq_option = "-verbose -graph_data $graph_data $param";
prinseq($r1,$r2,$out_good,$out_bad,$prinseq_option,$logfile);

$out_good = "/gg/tmp/prinseq/testdata_clean";
$out_bad = "/gg/tmp/prinseq/testdata_bad";
$prinseq_option = "-verbose $param";
prinseq($r1,$r2,$out_good,$out_bad,$prinseq_option,$logfile);

my $graph_out_prefix = "/gg/tmp/prinseq/graph";
my $graph_option = "-png_all";
prinseq_graph($graph_data,$graph_out_prefix,$graph_option);

sub prinseq{
	my $r1 = shift;
	my $r2 = shift;
	my $out_good = shift;
	my $out_bad = shift;
	my $param = shift;
	my $logfile = shift;
	
	my $command = "perl $prinseq -fastq $r1 -fastq2 $r2 $param -out_good $out_good -out_bad $out_bad -log $logfile";
	print $command."\n";
}

sub prinseq_graph{
	my $in = shift;
	my $out_prefix = shift;
	my $param = shift;
	
	my $command = "perl $prinseq_graphs -i $in $param -o $out_prefix";
	print $command."\n";
	# output is ($out_prefix)_****
}

=pod
#-ns_max_p Filter sequence with more than ns_max_p percentage of Ns
-trim_tail_left
Trim poly-A/T tail with a minimum length of trim_tail_left at the 5'-end
INT 5
-trim_tail_right
Trim poly-A/T tail with a minimum length of trim_tail_right at the 3'-end
INT 5
-trim_ns_left
Trim poly-N tail with a minimum length of trim_ns_left at the 5'-end
INT
-trim_ns_right
Trim poly-N tail with a minimum length of trim_ns_right at the 3'-end
INT
-min_qual_score
Filter sequence with at least one quality score below min_qual_score
-min_gc
Filter sequence with GC content below min_gc
INT [0..100]
-max_gc
Filter sequence with GC content above max_gc
INT [0..100]
-derep
Type of duplicates to filter. Allowed values are 1, 2, 3, 4 and 5. Use integers for multiple selections (e.g. 124 to use type 1, 2 and 4). The order does not matter. Option 2 and 3 will set 1 and option 5 will set 4 as these are subsets of the other option.
1 (exact duplicate), 2 (5' duplicate), 3 (3' duplicate), 4 (reverse complement exact duplicate), 5 (reverse complement 5'/3' duplicate)
INT
-derep_min
This option specifies the number of allowed duplicates. If you want to remove sequence duplicates that occur more than x times, then you would specify x+1 as the -derep_min values. For examples, to remove sequences that occur more than 5 times, you would specify -derep_min 6. This option can only be used in combination with -derep 1 and/or 4 (forward and/or reverse exact duplicates).
=cut
