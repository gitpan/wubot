package App::Wubot::Web;
use strict;
use warnings;

our $VERSION = '0.3.4'; # VERSION

use Mojo::Base 'Mojolicious';

use YAML;

my $config_file = join( "/", $ENV{HOME}, "wubot", "config", "webui.yaml" );

my $config = YAML::LoadFile( $config_file );

# This method will run once at server start
sub startup {
    my $self = shift;

    # Documentation browser under "/perldoc" (this plugin requires Perl 5.10)
    #$self->plugin('PODRenderer');

    # Routes
    my $r = $self->routes;

    for my $plugin ( keys %{ $config->{plugins} } ) {

        for my $route ( keys %{ $config->{plugins}->{$plugin} } ) {

            my $method = $config->{plugins}->{$plugin}->{$route};

            $r->route( $route )->to( "$plugin#$method" );

        }
    }
}

1;

__END__

=head1 NAME

App::Wubot::Web - Mojolicious web interface for wubot

=head1 VERSION

version 0.3.4

=head1 DESCRIPTION

For more information on the wubot web user interface, please see the
document L<App::Wubot::Guide::WebUI>.

The wubot web interface is still under construction.  There will be
more information here in the future.

TODO: finish docs
