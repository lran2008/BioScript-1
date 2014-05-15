#/usr/bin/perl -w

if (@ARGV != 2){
	printUsage();
}
my $infile = $ARGV[0];
my $outfile = $ARGV[1];

use Bio::SeqIO;
$in  = Bio::SeqIO->new(-file => $infile,
                       -format => 'Fasta');
$out = Bio::SeqIO->new(-file => ">$outfile",
                       -format => 'Fasta');
while ( my $seq = $in->next_seq() ) {$out->write_seq($seq); }

sub printUsage{
	print "Usage: perl $0 <in.fasta> <out.fasta>\n";
	exit;
}
