#!/usr/bin/perl -w

use strict;

if (@ARGV !=2){
	printUsage();
}
my $sshpass = "sshpass";
checkScript($sshpass,"Usage");

my $input_file = $ARGV[0];
my $pw = $ARGV[1];

my %info;
my @file_set;
read_input_file($input_file);

my $id = $info{"ID"};
my $port = $info{"PORT"};
my $ip = $info{"IP"};

foreach my $file_list (@file_set){
	my @l = split /\t/, $file_list;
	my $local_file = $l[0];
	my $remote_file = $l[1];
	#print "$local_file\t$remote_file\n";
	my $scp_command = "scp -P$port $local_file $id\@$ip:$remote_file";
	my $cmd_sshpass = "sshpass -p $pw $scp_command";
	print "$cmd_sshpass\n";
	system($cmd_sshpass);	
}

sub read_input_file{
	my $file = shift;
	
	open my $fh, '<:encoding(UTF-8)', $file or die;
	while (my $row = <$fh>) {
		chomp $row;
		if ($row =~ /^#/){
			my @l = split /\t/, $row;
			if ($row =~ /ID/){
				$info{"ID"} = $l[1];
			}elsif ($row =~ /PORT/){
				$info{"PORT"} = $l[1];
			}elsif ($row =~ /IP/){
				$info{"IP"} = $l[1];
			}
			next;
		}
		push @file_set, $row;
	}
	close($fh);
}

sub checkScript{
	my $script = shift;
	my $keyword = shift;
	my $result = `$script`;
	if ($result =~ /$keyword/g){
		return;
	}else{
		die "No found <$script>\n";
	}
}

sub printUsage{
	print "Usage: perl $0 <listFile> <password>\n";
	print "Version: 0.1 (only file copy)\n";
	print "Warning!! First you must connect the remote server with hands\n";
	exit;
}
