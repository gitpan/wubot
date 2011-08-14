package Wubot::Plugin::TestCase;
use Moose;

our $VERSION = '0.1_5'; # VERSION

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
