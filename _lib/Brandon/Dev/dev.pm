package Brandon;

our $VERSION = 'r1';

# Authors: brandon.kim.hyunmin@gmail.com
use strict;
use warnings;
use Data::Dumper;
use Exporter qw(import);
use File::Basename;

use vars qw( @ISA @EXPORT ); # or Write <use strict> next to <$VERSION = '0.1'>
@ISA = qw/Exporter File::Basename SAMTOOLS/;
@EXPORT_OK = qw(add multiply);

sub add {
  my ($x, $y) = @_;
  return $x + $y;
}

sub multiply {
  my ($x, $y) = @_;
  return $x * $y;
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

