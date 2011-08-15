package Wubot::Reactor::Console;
use Moose;

our $VERSION = '0.2_001'; # VERSION

use Log::Log4perl;
use POSIX qw(strftime);
use Term::ANSIColor;

has 'logger'  => ( is       => 'ro',
                   isa      => 'Log::Log4perl::Logger',
                   lazy     => 1,
                   default  => sub {
                       return Log::Log4perl::get_logger( __PACKAGE__ );
                   },
               );

my $valid_colors = { blue    => 'blue',
                     cyan    => 'cyan',
                     red     => 'red',
                     white   => 'white',
                     black   => 'bold black',
                     green   => 'green',
                     orange  => 'yellow',
                     yellow  => 'bold yellow',
                     purple  => 'magenta',
                     magenta => 'magenta',
                 };

sub react {
    my ( $self, $message, $config ) = @_;

    return $message unless $message->{subject};
    return $message if $message->{quiet};
    return $message if $message->{quiet_console};

    my $subject = $message->{subject_text} || $message->{subject};

    if ( $message->{title} && $message->{title} ne $message->{subject} ) {
        my $title   = $message->{title};
        $subject = "$title => $subject";
    }

    if ( $message->{key} ) {
        $subject = "[$message->{key}] $subject";
    }

    my $date = strftime( "%Y/%m/%d %H:%M:%S", localtime( $message->{lastupdate} || time ) );
    $subject = "$date> $subject";

    my $color = 'white';
    if ( $message->{color} && $valid_colors->{ $message->{color} } ) {
        $color = $valid_colors->{ $message->{color} };
    }

    if ( $message->{urgent} && $color !~ m/bold/ ) {
        $color = "bold $color";
    }

    $self->logger->debug( "Console: $color: $subject" );

    $message->{console}->{color} = $color;
    print color $color;

    $message->{console}->{text}  = $subject;
    print $subject;

    print color 'reset';
    print "\n";

    return $message;
}

1;


__END__


=head1 NAME

Wubot::Reactor::Console - display a notification to stdout


=head1 VERSION

version 0.2_001

=head1 SYNOPSIS

      - name: console
        plugin: Console


=head1 DESCRIPTION

For more information, please see the 'notifications' document.
