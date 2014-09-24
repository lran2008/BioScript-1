package FastQC;

use File::Basename;

use Data::Dumper;

my %actions = (
	qc => \&qc,
	baz => sub { print 'baz!' }
);

sub new {
	my ($class, $config) = @_;

	my $self = {
		file => $config->{file},
		out => $config->{out},
		app => $config->{app},
		program => $config->{program},
		threads => $config->{threads},
		java => $config->{java},
		extract => $config->{extract},
	};
	
	foreach (keys %$config ) {
		$self->{$_} = $config->{$_};
	}

	my $appName = $self->{app};
	$actions{$appName}->($self);

	bless $self,$class;
}

sub qc{
	my $self = shift;

	my $program = $self->{program};

	my $param = $self->{param};
	my $threads = $self->{threads};
	my $flag_extract = $self->{extract};

	my $infile = $self->{file};
	if (ref $infile eq "ARRAY"){
		$infile = join " ", @$infile;
	}
	
	my $out_prefix = $self->{out};
	if ($self->{out}){
		$out_prefix = $self->{out};
		$out_prefix = "-o $out_prefix";
	}else{
		my ($filename,$filepath,$fileext) = fileparse($infile, qr/\.[^.]*/);
		if (!-d "$filepath/$filename"){
			system("mkdir $filepath/$filename") and die "ERROR! couldn't create folder <$filepath/$filename>\n";
		}
		$out_prefix = "-o $filepath/$filename";
	}
	
	my $java = $self->{java};

	my @set_command;
	push @set_command, $program;
	push @set_command, $out_prefix;
	if ($java){
		push @set_command, "-j $java";
	}
	if ($threads){
		push @set_command, "-t $threads";
	}
	if ($flag_extract == 0){
		push @set_command, "--noextract";
	}else{
		push @set_command, "--extract";
	}
	if ($param){
		push @set_command, $param;
	}
	push @set_command, $infile;
	my $command = join " ", @set_command;

	$self->{command} = $command;

	return $self;
} 
1;

=pod
use FastQC;

my @arr=qw(
1.fq
2.fq
);
my $out_dir = "/BiO/fastqc_outdir";

my $tool_config={
        #file => \@arr,
        file => '3.fq',
        out => $out_dir,
        app => 'qc',
        program => "/BiOfs/BioTools/fastqc",
};
my $ref_FastQC = FastQC->new($tool_config);
my $cmd_FastQC = $ref_FastQC->{command};
=cut
