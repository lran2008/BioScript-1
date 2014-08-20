package PICARD;

use strict;
use warnings;

use File::Basename;

use Data::Dumper;

my $picard_path = "/BiOfs/hmkim87/BioTools/picard/1.115";
my $samtools = "/BiOfs/hmkim87/BioTools/samtools/0.1.19/samtools";
my $CalculateHsMetrics = $picard_path."/CalculateHsMetrics.jar";
my $java = "/BiOfs/hmkim87/Linux/jre1.7.0_51/bin/java";
my $java_mem_size = "4g";
my %actions = (
	CalculateHsMetrics => \&CalculateHsMetrics,
	CollectAlignmentSummaryMetrics => \&CollectAlignmentSummaryMetrics,
	ValidateSamFile => \&ValidateSamFile,
	baz => sub { print 'baz!' }
);

sub new {
	my ($class, $config) = @_;
	
	my $self = {
		INPUT => $config->{INPUT},
		OUTPUT => $config->{OUTPUT},
		REFERENCE_SEQUENCE => $config->{REFERENCE_SEQUENCE},
		PER_TARGET_COVERAGE => $config->{PER_TARGET_COVERAGE},
		BAIT_INTERVALS => $config->{BAIT_INTERVALS},
		TARGET_INTERVALS => $config->{TARGET_INTERVALS},
		VALIDATION_STRINGENCY => $config->{VALIDATION_STRINGENCY},
		PICARD_PATH => $picard_path,
		MEM_SIZE => $java_mem_size,
		app => $config->{app},
		JAVA => $java,
		TMP_DIR => $config->{TMP_DIR},
	};
	
	foreach (keys %$config ) {
		$self->{$_} = $config->{$_};
	}
	$self->{program} = $self->{PICARD_PATH}."/".$config->{app}.".jar";
	
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

sub ValidateSamFile{
	my $self = shift;

	my $program = $self->{program};

	my $infile = $self->{INPUT};
	my $outfile = $self->{OUTPUT};
	my $reference_fasta = $self->{REFERENCE_SEQUENCE};

	my $mem_size = $self->{MEM_SIZE};
	my $java_opts = "-Xmx".$mem_size." -jar";

	my $java_bin = $self->{JAVA};

	my $validation = $self->{VALIDATION_STRINGENCY};

	my @cmd_set;
	push @cmd_set, $java_bin;
	push @cmd_set, $java_opts;
	push @cmd_set, $program;
	push @cmd_set, "I=$infile";
	push @cmd_set, "O=$outfile";
	if ($reference_fasta){
		push @cmd_set, "R=$reference_fasta";
	}
	
	my $command = join " ", @cmd_set;

	$self->{command} = $command;

	return $self;
}


sub CollectAlignmentSummaryMetrics{
	my $self = shift;

	my $program = $self->{program};

	my $infile = $self->{INPUT};
	my $outfile = $self->{OUTPUT};
	my $reference_fasta = $self->{REFERENCE_SEQUENCE};

	my $mem_size = $self->{MEM_SIZE};
	my $java_opts = "-Xmx".$mem_size." -jar";

	my $java_bin = $self->{JAVA};

	my $validation = $self->{VALIDATION_STRINGENCY};

	my $command = "$java_bin $java_opts $program I=$infile O=$outfile R=$reference_fasta ASSUME_SORTED=false VALIDATION_STRINGENCY=$validation";

	$self->{command} = $command;

	return $self;
}

sub CalculateHsMetrics {
	my $self = shift;

	my $program = $self->{program};
	
	my $infile = $self->{INPUT};
	my $outfile = $self->{OUTPUT};

	my $per_target_coverage = $self->{PER_TARGET_COVERAGE};

	my $bait_intervals = $self->{BAIT_INTERVALS};
	my $target_intervals = $self->{TARGET_INTERVALS};
	my $reference_fasta = $self->{REFERENCE_SEQUENCE};

	my $validation = $self->{VALIDATION_STRINGENCY};
	
	my $mem_size = $self->{MEM_SIZE};	
	my $java_opts = "-Xmx".$mem_size." -jar";

	my $java_bin = $self->{JAVA};

	my $tmp_dir = $self->{TMP_DIR};

	my $header = $tmp_dir."/header";
	my $tmp_intervals = $tmp_dir."/intervals";
	my $intervals = $tmp_dir."/intervals.txt";
	my $command = "$samtools view -H $infile > $header\n".
		#"awk -F \$'\\t' 'BEGIN { OFS = FS } {print \$1,\$2,\$3,\$6,\$4;}' $target_intervals > $tmp_intervals\n".
		"awk -F \$'\\t' 'BEGIN { OFS = FS } {print \$1,\$2,\$3,\"+\",\$4;}' $target_intervals > $tmp_intervals\n".
		"cat $header $tmp_intervals > $intervals\n".
		#"$java_bin $java_opts $program I=$infile O=$outfile TI=$target_intervals BI=$bait_intervals R=$reference_fasta PER_TARGET_COVERAGE=$per_target_coverage VALIDATION_STRINGENCY=$validation";
		"$java_bin $java_opts $program I=$infile O=$outfile TI=$intervals BI=$intervals R=$reference_fasta PER_TARGET_COVERAGE=$per_target_coverage VALIDATION_STRINGENCY=$validation";

	$self->{command} = $command;

	return $self;
}
1;

=pod
	my $tool_config = {
			file => $vcf_file,
			out => $out_prefix,
			app => 'vcf2plink',
	};
	my $vcf2plink = Brandon::Bio::BioTools::VCFTOOLS->new($tool_config);

	my $vcf2plink_q = Brandon::Bio::BioPipeline::Queue->mini($vcf2plink->{command},1);
	$vcf2plink_q->run();
=cut
