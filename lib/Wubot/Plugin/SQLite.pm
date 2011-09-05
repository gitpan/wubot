package Wubot::Plugin::SQLite;
use Moose;

our $VERSION = '0.2.004'; # VERSION

use Wubot::Logger;

with 'Wubot::Plugin::Roles::Cache';
with 'Wubot::Plugin::Roles::Plugin';

sub check {
    my ( $self, $inputs ) = @_;

    my $cache  = $inputs->{cache};
    my $config = $inputs->{config};

    my @react;

    my ( $file ) = glob( $config->{dbfile} );

    my $sqlite =  Wubot::SQLite->new( { file => $file } );

    if ( $config->{statements} ) {
        my $return = { coalesce => $self->key };

        for my $statement ( @{ $config->{statements} } ) {
            for my $row ( $sqlite->query( $statement ) ) {

                for my $key ( keys %{ $row } ) {
                    $return->{$key} = $row->{$key};
                }
            }
        }

        push @react, $return;
    }
    elsif ( $config->{statement} ) {
        for my $row ( $sqlite->query( $config->{statement} ) ) {

            if ( $row->{id} ) {
                next if $self->cache_is_seen( $cache, $row->{id} );
                $self->cache_mark_seen( $cache, $row->{id} );
            }

            $row->{coalesce} = $self->key;

            push @react, $row;
        }
    }

    $self->cache_expire( $cache );

    return { cache => $cache, react => \@react };
}

1;

__END__

=head1 NAME

Wubot::Plugin::SQLite - monitor results of SQLite queries

=head1 VERSION

version 0.2.004

=head1 DESCRIPTION

TODO: More to come...


=head1 SUBROUTINES/METHODS

=over 8

=item check( $inputs )

The standard monitor check() method.

=back
