package Wubot::Reactor::Split;
use Moose;

our $VERSION = '0.1_10'; # VERSION

use YAML;

sub react {
    my ( $self, $message, $config ) = @_;

    return $message unless $config->{source_field};

    my @data = split /\s*,\s*/, $message->{ $config->{source_field} };

    for my $field ( reverse @{ $config->{target_fields} } ) {
        $message->{ $field } = pop @data;
    }

    return $message;
}

1;
