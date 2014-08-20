package Queue;
use strict;
use FindBin;
use Data::Dumper;
use Cwd 'abs_path';
use Carp qw(croak);
use File::Basename; 

sub new {
	my ($class, $config, $debug) = @_;
	
	my $self = {
		name => $config->{name},
		command => $config->{command},
		script => $config->{script},
		stdout => $config->{stdout},
		stderr => $config->{stderr}, 
		slot_range => $config->{slot_range},
		interdependencies => $config->{depend_name},
		DEBUG  => $debug,
	};

	return bless $self, $class;
}

sub is_array {
  my ($ref) = @_;
  # Firstly arrays need to be references, throw
  #  out non-references early.
  return 0 unless ref $ref;

  # Now try and eval a bit of code to treat the
  #  reference as an array.  If it complains
  #  in the 'Not an ARRAY reference' then we're
  #  sure it's not an array, otherwise it was.
  eval {
    my $a = @$ref;
  };
  if ($@=~/^Not an ARRAY reference/) {
    return 0;
  } elsif ($@) {
    die "Unexpected error in eval: $@\n";
  } else {
    return 1;
  }
}

sub getCommand{
	my $in = shift;
	
	my $command;
	if (is_array($in)){
		my $arr_cmd = $in;
		$command = join "\n", @{$arr_cmd};
	}else{
		$command = $in;
	}
	
	return $command;
}

sub make{
	my $self = shift;

	if ($self->{name} =~ /^\d/){
		die "ERROR! You can't use the numeric name in job name\n";
	}
	
	my $file = $self->{script};

	my $outfile = $self->{stdout};
	my $logfile = $self->{stderr};

	my $jobname = $self->{name};
	
	my $command = getCommand($self->{command});

	my $cpu = $self->{slot_range};

	my @cmd_set;
	push @cmd_set, "#!bin/sh";
	push @cmd_set, "#\$ -q all.q";
	#push @cmd_set, "#\$ -M bioannouncement\@gmail.com";
	#push @cmd_set, "#\$ -m be"; # b(egin), e(nd)
	push @cmd_set, "#\$ -N $jobname";
	if (defined $outfile and defined $logfile){
		push @cmd_set, "#\$ -o $outfile";
		push @cmd_set, "#\$ -e $logfile";
	}else{
		push @cmd_set, "#\$ -o $outfile";
		push @cmd_set, "#\$ -j y";
	}
	push @cmd_set, "#\$ -S /bin/bash";
	push @cmd_set, "#\$ -cwd";
	push @cmd_set, "#\$ -V";
	if (defined $cpu){ push @cmd_set, "#\$ -pe smp $cpu"; }
	push @cmd_set, "uname -a";
	push @cmd_set, "hostname -a";
	push @cmd_set, "date";
	push @cmd_set, $command;
	push @cmd_set, "date\n";

	my $content = join "\n", @cmd_set;
	open(my $fh, '>:encoding(UTF-8)', $file) or die;
	print {$fh} $content;
	close($fh);
=pod
	my (@arr_file, @arr_log);

	push @arr_file, $file;
	push @arr_log, $logfile;
	
	$self->{script_file} = \@arr_file;
	$self->{log_file} = \@arr_log;
=cut	
	return $self;
}

sub run{
	my $self = shift;
	my $job = shift;

	my $q_command;

	my $depend_job = $self->{interdependencies};
	my $script = $self->{script};
	
	if (defined $depend_job){
		$q_command = "qsub -hold_jid $depend_job $script";
	}else{
		$q_command = "qsub $script";
	}
	$self->command($q_command);
	return $self;
}

sub command {
        my ( $self, $command ) = @_;
	
	if ( $self->{'DEBUG'} ) {
                print "$command\n";
        }
        else {
                system("echo $command");
                system("$command");
        }
}
1;

=pod
	my $hsMetrics;
	my $debug = 1;
	$hsMetrics->{command} = "/BiOfs/hmkim87/BioTools/samtools/0.1.19/samtools view -H in.bam";
	$hsMetrics->{name} = "T1303D1394_Picard";
	$hasMetrics->{script} = "T1303D1394_Picard.sh";
	my $hsMetrics_q = Brandon::Bio::BioPipeline::Queue->mini($hsMetrics,$debug);
	$hsMetrics_q->run();
	#my $hsMetrics_q = Brandon::Bio::BioPipeline::Queue->mini($hsMetrics);
=cut
