package Brandon::Bio::BioTools;

use strict;
use warnings;
use Config;
use Exporter qw(import);

our @EXPORT_OK = qw(%TOOL $SAMTOOLS $GATK $PICARD_PATH $BWA $VCFTOOLS_PATH $VCFTOOLS_LIB_PATH $BEDTOOLS_PATH);

# SAMTOOLS
our $SAMTOOLS;
if ($Config{archname} eq "x86_64-linux-gnu-thread-multi"){ # Ubuntu
	$SAMTOOLS = "/BiOfs/hmkim87/BioTools/samtools/0.1.19/samtools";
}elsif ($Config{archname} eq "x86_64-linux-thread-multi"){ # CentOS
	$SAMTOOLS = "/BiOfs/hmkim87/BioTools/samtools/0.1.19_CentOS/samtools";
}else{
	die "ERROR! $Config{archname} is not consideration arch";
} 

# BWA
our $BWA = "/BiOfs/hmkim87/BioTools/bwa/0.7.8/bwa";

# GATK
our $GATK = "/BiOfs/hmkim87/BioTools/GATK/2.3.9/GenomeAnalysisTKLite-2.3-9.jar";

# PICARD
our $PICARD_PATH = "/BiOfs/hmkim87/BioTools/picard/1.114";

# VCFTOOLS
our $VCFTOOLS_PATH = "/BiOfs/hmkim87/BioTools/vcftools/0.1.12a/bin";
our $VCFTOOLS_LIB_PATH = "/BiOfs/hmkim87/BioTools/vcftools/0.1.12a/lib/perl5/site_perl";

# BEDTOOLS
our $BEDTOOLS_PATH = "/BiOfs/hmkim87/BioTools/bedtools/2.20.1/bin";


sub AUTOLOAD {
    my $self = shift;
    die "the subrountine doesn't exist\n";
}
1;
__END__

=pod
=head 1 NAME
Trying to Make Module
=head 1 DESCRIPTION
We have two subrountines: B<do_something>, B<do_more>
=head2 do_something()
    Simply print "done" on STDIN
=head2 do_more()
    Takes arguments and returns one string variable which has been all concatenated.
=head1 AUTHOR
Hyun Min Kim (istars87@gmail.com)
=cut

