#!/usr/bin/perl -w

use strict;

use File::Basename; 
if (@ARGV !=2){
	print "perl $0 <in.fasta> <in.gff>\n";
	exit;
}
#my $fasta = "/BiO/hmkim87/GBrowse/Fasta/Korean55.scafSeq.fill.gapclose.1";
#my $gff = "/BiO/hmkim87/GBrowse/GFF/Korean55.gene.gff";
my $fasta = $ARGV[0];
my $gff = $ARGV[1];

my ($filename_gff,$filepath_gff,$fileext_gff) = fileparse($gff, qr/\.[^.]*/); 

my $samtools = "/BiOfs/hmkim87/BioTools/samtools/0.1.19/samtools";

my $command;

my $fasta_fai = $fasta.".fai";
$command = "$samtools $fasta";
if (!-f $fasta_fai){
	#print $command."\n";
	system($command);
}

my %hash_seqid = read_fasta_fai($fasta_fai);
#print $seqid{"scaffold5492"}."\n";

my $out_gff = "$filepath_gff/$filename_gff.addSeq$fileext_gff";
gff_modify($gff,$out_gff);

sub gff_modify{
	my $file = shift;
	my $out = shift;
	
	open my $fh, '<:encoding(UTF-8)', $file or die;
	my %hash_gff;
	my @header;
	while (my $row = <$fh>){
		chomp $row;
		if ($row =~ /^#/){
			push @header, $row;
			next;
		}else{
			my @l = split /\t/, $row;
			my $seqid = $l[0];
			push @{$hash_gff{$seqid}}, $row;
		}
	}
	close ($fh);

	open my $fh_out, '>:encoding(UTF-8)', $out or die;
	foreach (@header){
		print $fh_out $_."\n";
	}
	foreach my $seqid (keys %hash_seqid){
		if (defined $hash_gff{$seqid}){
			my $source = "example";
			my $type = $seqid;
			$type =~ /^([a-zA-Z]+)\d+/; # scaffold or contig
			$type = $1;
			my $start = 1;
			my $end = $hash_seqid{$seqid};
			print $fh_out "$seqid\t$source\t$type\t$start\t$end\t.\t.\t.\tName=$seqid\n";
			foreach my $seqid_line (@{$hash_gff{$seqid}}){
				print $fh_out $seqid_line."\n";
			}
		}
	}
	close ($fh_out);
}

sub read_fasta_fai{
	my $file = shift;
	
	open my $fh, '<:encoding(UTF-8)', $file or die;
	my %hash;
	while (my $row = <$fh>) {
        	chomp $row;
		my @l = split /\t/, $row;
		my $seqid = $l[0];
		my $length = $l[1];
		$hash{$seqid} = $length;
	}
	close($fh);
	return %hash;
}
