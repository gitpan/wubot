package Wubot::Plugin::TestCase;
use Moose;

our $VERSION = '0.2.5'; # VERSION

use Wubot::Logger;

with 'Wubot::Plugin::Roles::Cache';
with 'Wubot::Plugin::Roles::Plugin';

sub check {
    my ( $self, $inputs ) = @_;

    my $cache  = $inputs->{cache};
    my $config = $inputs->{config};

    my $react;

    # just setting the cache params in the config
    for my $key ( keys %{ $config } ) {

        # don't handle the 'tags' config, that is done in the check() layer
        next if $key eq "tags";

        $cache->{$key}   = $config->{$key};
        $react->{ $key } = $config->{$key};
    }

    return { cache => $cache, react => [ $react ] };
}

1;

__END__

=head1 NAME

Wubot::Plugin::TestCase - a plugin for testing purposes

=head1 VERSION

version 0.2.5

=head1 DESCRIPTION

Not much to see here.  This plugin is only useful for testing.


=head1 SUBROUTINES/METHODS

=over 8

=item check( $inputs )

The standard monitor check() method.

=back
