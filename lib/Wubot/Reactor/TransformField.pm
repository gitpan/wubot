package Wubot::Reactor::TransformField;
use Moose;

our $VERSION = '0.1_6'; # VERSION

use YAML;

sub react {
    my ( $self, $message, $config ) = @_;

    my $text = $message->{ $config->{source_field } };

    my $regexp_search = $config->{regexp_search};
    return $message unless $regexp_search;

    my $regexp_replace = exists $config->{regexp_replace} ? $config->{regexp_replace} : "";

    my @items = ( $text =~ /$regexp_search/g );

    $text =~ s|$regexp_search|$regexp_replace|eg;

    for( reverse 0 .. $#items ){ 
        my $n = $_ + 1; 
        $text =~ s/\\$n/${items[$_]}/g ;
        $text =~ s/\$$n/${items[$_]}/g ;
    }

    $message->{ $config->{target_field}||$config->{source_field} } = $text;

    return $message;
}

1;
