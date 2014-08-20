package Brandon::Bio::BioTools::GATK;

use strict;
use warnings;

use File::Basename;

use Data::Dumper;

my $java = "/BiOfs/hmkim87/Linux/jre1.7.0_51/bin/java";
my $javaopts = "-Xmx4g -jar";
my $gatk = "/BiOfs/hmkim87/BioTools/GATK/3.1-1/GenomeAnalysisTK.jar";

my %actions = (
	UnifiedGenotyper => \&UnifiedGenotyper,
	CombineVariants => \&CombineVariants,
	baz => sub { print 'baz!' }
);

sub new {
	my ($class, $config) = @_;
	
	my $self = {
		reference_sequence => $config->{reference},
		input_file => $config->{input},
		output => $config->{output},
		app => $config->{app},
		dbsnp => undef,
		param => undef,
		intervals => undef,
		java_opts => $javaopts,
		java => $java,
		gatk => $gatk,
	};
	
	foreach (keys %$config ) {
		$self->{$_} = $config->{$_};
	}
	
	my $appName = $self->{app};
	
	$actions{$appName}->($self);

	bless $self,$class;
}

sub get_input_files{
	my $in = shift;
	
	my @infiles;
	foreach my $hash_ref (@$in){
		push @infiles, $hash_ref->{content};
	}
	my $out = "-I ".(join " -I ", @infiles);

	return $out;
}

sub UnifiedGenotyper{
	my $self = shift;

	my $appName = "UnifiedGenotyper";
	
	my @arr;
	push @arr, $self->{java};
	push @arr, $self->{java_opts};
	push @arr, $self->{gatk};
	push @arr, "-R ".$self->{reference_sequence};
	push @arr, "-T ".$self->{app};
	
	my $input = get_input_files($self->{input_file});
	push @arr, $input;

	if ($self->{dbsnp}){
		push @arr, "--dbsnp ".$self->{dbsnp};
	}
	if ($self->{output}){
		push @arr, "-o ".$self->{output};
	}
	if ($self->{param}){
		push @arr, $self->{param};
	}
	if ($self->{intervals}){
		push @arr, "-L ".$self->{intervals};
	}
	
	$self->{command} = join " ", @arr;

	return $self;
}

sub CombineVariants{
	my $self = shift;

	my $appName = "CombineVariants";
	
	my @arr;
	push @arr, $self->{java};
	push @arr, $self->{java_opts};
	push @arr, $self->{gatk};
	push @arr, "-R ".$self->{reference_sequence};
	push @arr, "-T ".$self->{app};

	if ($self->{input_file}){
		foreach (@{$self->{input_file}}){
			push @arr, "--variant $_";
		}
	}
	
	if ($self->{output}){
		push @arr, "-o ".$self->{output};
	}
	if ($self->{param}){
		push @arr, $self->{param};
	}
	
	$self->{command} = join " ", @arr;

	return $self;
}
1;
