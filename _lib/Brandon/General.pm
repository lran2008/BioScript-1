package Brandon::General;

use strict;
use warnings;

use Exporter qw(import);

our @EXPORT_OK = qw(say RoundXL);

sub say { print @_, "\n" } # Lower than 5.010

sub RoundXL {
  sprintf("%.$_[1]f", $_[0]);
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

