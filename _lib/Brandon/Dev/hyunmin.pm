package hyunmin;

use Exporter;
use strict;
use File::Basename;
use vars qw( @ISA @EXPORT_OK $VERSION ); # or Write <use strict> next to <$VERSION = '0.1'>
@ISA = qw( Exporter File::Basename);
@EXPORT_OK = qw( DIR average median without_ext ext_only getFileExtension do_something do_more write_qscript fileparse);
$VERSION = '0.02';

sub write_qscript{
        my @in_array = @_;

        my $script_fn = $in_array[0];

        my @script_txt = @{$in_array[1]};

        open(DATA, ">$script_fn") or die "<$script_fn> $!\n";
        foreach my $line (@script_txt){
                if ($line =~ /\n$/){
                        print DATA $line;
                }else{
                        print DATA $line."\n";
                }
        }
        close(DATA);
}

sub getFileExtension {
    my $pos = rindex $_[0], ".";
    return "" if $pos < 1;
    substr $_[0], $pos + 1;
}

sub without_ext {
    my ($file) = @_;
    return substr($file, 0, rindex($file, '.'));
}

sub ext_only {
    my ($file) = @_;
    return substr($file, rindex($file, '.') + 1);
}

sub do_more{
    my ($result, @params, $param);
    @params = @_;
    foreach $param(@params){
        $result = $result.$param;
    }
    return $result;
}

sub average{
    @_ == 1 or die ('Sub usage: $average = average(\@array);');
    my ($array_ref) = @_;
    my $sum;
    my $count = scalar @$array_ref;
    foreach (@$array_ref) { $sum += $_; };
    return $sum / $count;
}

sub median{
    @_ == 1 or die ('Sub usage: $median = median(\@array);');
    my ($array_ref) = @_;
    my $count = scalar @$array_ref;
    # Sort a COPY of the array, leaving the original untouched
    my @array = sort { $a <=> $b } @$array_ref;
    if ($count % 2){
        return $array[int($count/2)];
    }else{
        return ($array[$count/2] + $array[$count/2 -1]) / 2;
    }
}

sub DIR{
    my $indir = shift;
    if (-d $indir){
        return;
    }
    my $sc = "mkdir -p $indir";
    system($sc) and die "Error system command : <$sc>\n";
}

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

