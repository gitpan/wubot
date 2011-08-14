package Wubot::Reactor::WriteFile;
use Moose;

our $VERSION = '0.1_8'; # VERSION

use Log::Log4perl;
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

    my $contents;

    if ( $config->{source_field} ) {
        return $message unless $message->{ $config->{source_field} };
        $contents = $message->{ $config->{source_field} };
    }
    else {
        $contents = YAML::Dump $message;
    }

    my $path;
    if ( $config->{file} ) {
        $path = $config->{file};
    }
    elsif ( $config->{path_field} ) {
        $path = $message->{ $config->{path_field} };
    }
    return $message unless $path;

    if ( -r $path ) {
        unless ( $config->{overwrite} ) {
            $self->logger->debug( "will not overwrite existing file: $path" );
            return $message;
        }
    }

    open(my $fh, ">", $path)
        or die "Couldn't open $path for writing: $!\n";
    print $fh $contents;
    close $fh or die "Error closing file: $!\n";

    return $message;
}

1;
