package Wubot::Reactor::SQLiteDelete;
use Moose;

our $VERSION = '0.2.5'; # VERSION

use YAML;

use Wubot::Logger;
use Wubot::SQLite;

has 'logger'  => ( is => 'ro',
                   isa => 'Log::Log4perl::Logger',
                   lazy => 1,
                   default => sub {
                       return Log::Log4perl::get_logger( __PACKAGE__ );
                   },
               );

has 'sqlite'  => ( is => 'ro',
                   isa => 'HashRef',
                   default => sub { {} },
               );

sub react {
    my ( $self, $message, $config ) = @_;

    my $sqlite;

    # if we don't have a sqlite object for this file, create one now
    unless ( $self->sqlite->{ $config->{file} } ) {
        $self->sqlite->{ $config->{file} } = Wubot::SQLite->new( { file => $config->{file} } );
    }

    my $field = $config->{where_field};

    $self->sqlite->{ $config->{file} }->delete( $config->{tablename}, { $field => $message->{$field} } );

    return $message;
}

1;

__END__

=head1 NAME

Wubot::Reactor::SQLiteDelete - delete a row from a SQLite table

=head1 VERSION

version 0.2.5

=head1 DESCRIPTION

TODO: More to come...


=head1 SUBROUTINES/METHODS

=over 8

=item react( $message, $config )

The standard reactor plugin react() method.

=back
