package App::Wubot::Reactor::DeleteField;
use Moose;

our $VERSION = '0.3.4'; # VERSION

use App::Wubot::Logger;

sub react {
    my ( $self, $message, $config ) = @_;

    delete $message->{ $config->{field} };

    return $message;
}

__PACKAGE__->meta->make_immutable;

1;

__END__


=head1 NAME

App::Wubot::Reactor::DeleteField - remove a field from the message


=head1 VERSION

version 0.3.4

=head1 SYNOPSIS

      - name: delete field 'x' from the message
        plugin: DeleteField
        config:
          field: x


=head1 DESCRIPTION

Removes a field and its value from a message.

=head1 SUBROUTINES/METHODS

=over 8

=item react( $message, $config )

The standard reactor plugin react() method.

=back
