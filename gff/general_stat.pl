#!/usr/bin/perl -w

use strict;
if(@ARGV!=1){ printUsage(); }
my $input=$ARGV[0];

my %hash_seqid;
my %hash_source;
my %hash_type;
my %hash_len;
open my $fh, '<:encoding(UTF-8)', $input or die;
while (my $row = <$fh>) {
	if ($row =~ /^##/){ next; }
        chomp $row;

	my @l = split /\t/, $row;
	my $seqid = $l[0];
	my $source = $l[1];
	my $type = $l[2];
	my $start = $l[3];
	my $end = $l[4];
	my $len = $end-$start+1;

	$hash_seqid{$seqid}++;
	$hash_source{$source}++;
	$hash_type{$type}++;
	$hash_len{$len}++;
}
close($fh);

my $cnt_seqid = keys %hash_seqid;
my $cnt_source = keys %hash_source;
my $cnt_type = keys %hash_type;
my @arr_len;
foreach my $key (keys %hash_len){
	my $value = $hash_len{$key};
	if ($value <2){
		push @arr_len, $key;
	}else{
		for (my $i=0; $i<$value; $i++){
			push @arr_len, $key;
		}
	}
}
my $average_len = average(\@arr_len);

print "seqid:$cnt_seqid\n";
print "source:$cnt_source\n";
print "type:$cnt_type\n";
print "average_length_feature:$average_len\n";

sub average{
    @_ == 1 or die ('Sub usage: $average = average(\@array);');
    my ($array_ref) = @_;
    my $sum;
    my $count = scalar @$array_ref;
    foreach (@$array_ref) { $sum += $_; };
    return $sum / $count;
}

sub printUsage{
	print "Usage: perl $0 <in.gff>\n";
	exit;
} 
