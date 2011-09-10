package Wubot;
use Moose;

our $VERSION = '0.3.1'; # VERSION

#_* Libraries

use Carp;

#_* POD

=head1 NAME

Wubot - personal distributed reactive automation


=head1 VERSION

version 0.3.1

=head1 DESCRIPTION

For an overview of wubot, please see L<App::Wubot::Guide::Overview>.

For more information, see the L<App::Wubot::Guide>.

=cut

#_* End

__PACKAGE__->meta->make_immutable;

1;

__END__
