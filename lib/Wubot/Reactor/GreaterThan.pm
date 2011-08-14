package Wubot::Reactor::GreaterThan;
use Moose;

our $VERSION = '0.1_7'; # VERSION

use YAML;

has 'logger'  => ( is => 'ro',
                   isa => 'Log::Log4perl::Logger',
                   lazy => 1,
                   default => sub {
                       return Log::Log4perl::get_logger( __PACKAGE__ );
                   },
               );

sub react {
    my ( $self, $message, $config ) = @_;

    my $field_data = $message->{ $config->{field} };

    if ( $field_data >= $config->{minimum} ) {

        $self->logger->debug( "matched => $config->{field} data $field_data greater than $config->{minimum}" );

        for my $key ( keys %{ $config->{set} } ) {

            $self->logger->info( "setting field $key to $config->{set}->{$key}" );
            $message->{ $key } = $config->{set}->{$key};

        }
    }

    return $message;
}

1;


__END__


=head1 NAME

Wubot::Reactor::GreaterThan - set keys and values if the value of a field exceeds a value


=head1 VERSION

version 0.1_7

=head1 DESCRIPTION

This plugin is deprecated!

Please use the '>' condition in combination with the 'SetField'
reactor plugin:

  - name: 'test' field is greater than 5
    condition: test > 5
    plugin: SetField
    config:
      set:
        key1: value1
        key2: value2

See the 'conditions' document for more information.
