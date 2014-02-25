#!/usr/bin/perl -w

use strict;

# The subroutines "new" and "initialize" for the constructor
sub new{
	my $class_name = shift;  # Gets class name from parmlist
	my $this = {};    # Creates reference to object
	bless($this, $class_name); # Associates reference with class
	$this->initialize(@_); # Call local initialize subroutine
	# passing rest of parmlist
	return $this;    # Explicit return of value of $this
}

sub initialize
{
 my $this = shift;    # Receive an object reference as 1st param
 my %parms = @_;         # Get passed parameters from the call to "new"

 # Change hash reference for key with supplied value, or assign default
 $this->{reference_fa}   = $parms{reference_fa} || 'hg18.fa';
 $this->{sample_name}   = $parms{sample_name} || 'undef_sample_name';
 $this->{input_fq1}    = $parms{input_fq1}  || 0;
 $this->{input_fq2}    = $parms{input_fq2}  || 0;
 $this->{pe}      = $parms{pe}   || 1;
 $this->{fastq_format}   = $parms{fastq_format} || 'Illumina';
 $this->{sanger_fq1}    = $parms{sample_name}.'_read1_sanger.fq';
 $this->{sanger_fq2}    = $parms{sample_name}.'_read2_sanger.fq';
 $this->{dbsnp_rod}    = $parms{dbsnp_rod}  || '/data/nextgen1/pipeline/dbsnp_130_hg18.rod';
 $this->{target_bed}    = $parms{target_bed} || '/data/nextgen1/pipeline/targets/SureSelect_All_Exon_G3362_with_names.v2.bed';


sub check_fastq_format
{
	my $this = shift;  # Figure out who I am
	open(FASTQ, $this->{input_fq1}) or die "can't open $this->{input_fq1}: $@\n";

	my $fastq_format;
	my $counter = 2000; # count 2000 lines of quality scores
	my $min_qualscore = 1e6;
	my $max_qualscore = -1e6;
	my $tmp;
	while ($counter > 0){
		$tmp = <FASTQ>; # @read name
		$tmp = <FASTQ>; # base calls
		$tmp = <FASTQ>; # +read name
		my $scores = <FASTQ>; # quality scores
		if (!$scores) { last }
		#print $scores;
		chomp($scores);
		for my $chr (map(ord, split(//, $scores))){
			if ($chr < $min_qualscore){
				$min_qualscore = $chr;
			}
			if ($chr > $max_qualscore){
				$max_qualscore = $chr;
			}

		}
		$counter--;
	}

	# Phred+33 means quality score + 33 = ASCII
	if ($min_qualscore >= 33 && $max_qualscore <= 126){
		$fastq_format = "Sanger";
	}

	# Solexa+64 means quality score + 64 = ASCII
	if ($min_qualscore >= 59 && $max_qualscore <= 126){
		$fastq_format = "Solexa";
	}

	# Phred+64 means quality score + 64 = ASCII
	if ($min_qualscore >= 64 && $max_qualscore <= 126){
		$fastq_format = "Illumina 1.3+";
	}

	# Phred+64 in both both Illumina 1.3+ and Illumina 1.5+
	#if ($min_qualscore >= 66 && $max_qualscore <= 126)
	#{
	# $fastq_format = "Illumina 1.5+";
	#}

	# Illumina 1.8+ returned to the use of the Sanger format (Phred+33)
	print "$fastq_format fastq format: ASCII(min, max) = ($min_qualscore, $max_qualscore)\n";
	$this->{fastq_format} = $fastq_format;
	if ($this->{fastq_format} eq "Sanger"){
		$this->{sanger_fq1} = $this->{input_fq1};
		$this->{sanger_fq2} = $this->{input_fq2};
	}
	return $fastq_format;
}
