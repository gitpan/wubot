package App::Wubot::Check;
use Moose;

our $VERSION = '0.3.4'; # VERSION

use Benchmark;
use YAML;

use App::Wubot::Logger;
use App::Wubot::LocalMessageStore;
use App::Wubot::Reactor;
use App::Wubot::SQLite;

=head1 NAME

App::Wubot::Check - perform checks for an instance of a monitor


=head1 VERSION

version 0.3.4

=head1 SYNOPSIS

    use App::Wubot::Check


=head1 DESCRIPTION

This class managed a single instance of a monitor.  It initializes the
instance of the monitor and performs the check() method.  It handles
any configuration for the monitor, messages sent by the monitor, and
monitor cache data.  It also sends any messages produces by the
instance through the reactor.

=cut

has 'key'      => ( is => 'ro',
                    isa => 'Str',
                    required => 1,
                );

has 'class'      => ( is => 'ro',
                      isa => 'Str',
                      required => 1,
                  );

has 'instance'   => ( is      => 'ro',
                      lazy    => 1,
                      default => sub {
                          my $self = shift;
                          my $class = $self->class;
                          eval "require $class";  ## no critic
                          if ( $@ ) {
                              die "ERROR: loading class: $class => $@";
                          }
                          return $class->new( key        => $self->key,
                                              class      => $self->class,
                                              cache_file => $self->cache_file,
                                              reactor    => $self->reactor,
                                          );
                      },
                  );

has 'cache_file' => ( is => 'ro',
                      isa => 'Str',
                      required => 1,
                  );

has 'logger'  => ( is => 'ro',
                   isa => 'Log::Log4perl::Logger',
                   lazy => 1,
                   default => sub {
                       return Log::Log4perl::get_logger( __PACKAGE__ );
                   },
               );

has 'reactor_queue' => ( is => 'ro',
                         isa => 'App::Wubot::LocalMessageStore',
                         lazy => 1,
                         default => sub {
                             return App::Wubot::LocalMessageStore->new();
                         }
                     );

has 'reactor_queue_dir' => ( is => 'ro',
                             isa => 'Str',
                             default => sub {
                                 return join( "/", $ENV{HOME}, "wubot", "reactor" );
                             },
                         );

has 'reactor'   => ( is => 'ro',
                     isa => 'CodeRef',
                     lazy => 1,
                     default => sub {
                         my ( $self ) = @_;

                         return sub {
                             my ( $message, $config ) = @_;

                             $self->_react_results( $message, $config );

                         };
                     },
                 );

has 'wubot_reactor' => ( is => 'ro',
                         isa => 'App::Wubot::Reactor',
                         lazy => 1,
                         default => sub {
                             App::Wubot::Reactor->new();
                         },
                     );


=head1 SUBROUTINES/METHODS

=over 8

=item $obj->init( $config );

Initialize an instance of a monitor.  This is only done once, when the
monitoring engine starts up.

Any persisted cache data for the monitor will be read in.

If the monitor plugin defines the 'init' method, that method will be
called for the instance.

If the init method produces any messages, they will be sent through
the reactor.

The cache data will be written back out after the init() method is
called.

=cut

sub init {
    my ( $self, $config ) = @_;

    if ( $self->instance->can( 'validate_config' ) ) {
        $self->instance->validate_config( $config );
    }

    return unless $self->instance->can( 'init' );

    my $cache = $self->instance->get_cache();

    my $results = $self->instance->init( { config => $config, cache => $cache } );

    if ( $results->{react} ) {
        $self->reactor->( $results->{react}, $config );
    }

    if ( $results->{cache} ) {
        $self->instance->write_cache( $results->{cache} );
    }

    return $results;
}

=item $obj->check( $config )

Performs a single check of the monitor instance.

Any updated cache data will first be read in.

The check() method will then be called on the monitor instance.  Both
the instance configuration and cache data will be passed to the
check() method.

An alarm will be set before the check() method is called to cancel the
check if it runs longer than the expected time limit.  The default
timeout is 30 seconds, although this may be configured by setting the
'timeout' parameter in the check config.

If any messages are generated by the check() method, they will be
passed through the reactor.

The cache will only be written back out after the check() method
completes and the reactor has processed any messages.

=cut

sub check {
    my ( $self, $config ) = @_;

    my $cache = $self->instance->get_cache() || {};

    $self->logger->debug( "calling check for instance: ", $self->key );

    my $start = new Benchmark;

    my $timeout = 30;
    if ( $config->{timeout} ) {
        $timeout = $config->{timeout};
    }

    my $results;
    my $status = 3;

    eval {
        # set the alarm
        local $SIG{ALRM} = sub { die "alarm\n" };
        alarm $timeout;

        $results = $self->instance->check( { config => $config, cache => $cache } );

        $status = 0;

        # cancel the alarm
        alarm 0;
    };

    my $error = $@;

    if ( $error ) { $status = 2 }

    my $end = new Benchmark;
    my $diff = timediff( $end, $start );
    $self->logger->debug( $self->key, ":", timestr( $diff, 'all' ) );

    if ( $error ) {
        if ( $error eq "alarm\n" ) {
            $self->logger->error( "Timed out after $timeout seconds for check: ", $self->key );
        }
        else {
            $self->logger->error( "Check died: $error" );
        }
        return;
    }

    if ( $results->{react} ) {
        $self->logger->debug( " - running rules defined in react" );
        $self->reactor->( $results->{react}, $config );
    }

    if ( $results->{cache} ) {
        $self->instance->write_cache( $results->{cache} );
    }

    # todo: always touch 'cache' file with latest date

    return $results;
}

sub _react_results {
    my ( $self, $react, $config ) = @_;

    if ( ref $react eq "ARRAY" ) {
        for my $results_h ( @{ $react } ) {
            $self->_react_results( $results_h, $config );
        }
        return;
    }

    # set the monitor config in the message
    my $skip = { react => 1 };
    for my $key ( keys %{ $config } ) {
        next if $skip->{ $key };
        $react->{"config.$key"} = $config->{$key};
    }

    unless ( ref $react eq "HASH" ) {
        $self->logger->error( "React results called without a hash ref: ", YAML::Dump $react );
        return;
    }

    # push any configured 'tags' along with the message
    if ( $config && $config->{tags} ) {
        $react->{tags} = $config->{tags};
    }

    # use our class name for the 'plugin' field
    unless ( $react->{plugin} ) {
        $react->{plugin}     = $self->{class};
    }

    # use our instance key name for the 'key' field
    unless ( $react->{key} ) {
        $react->{key}        = $self->key;
    }

    unless ( $react->{lastupdate} ) {
        $react->{lastupdate} = time;
    }

    if ( $config && $config->{react} ) {
        $self->logger->debug( "Running reaction configured directly on check instance" );
        $self->wubot_reactor->react( $react, $config->{react} );
    }

    if ( $react->{last_rule} ) {
        $self->logger->debug( " - check instance reaction set last_rule" );
        $self->logger->trace( YAML::Dump $react );
    }
    else {
        $self->logger->debug( " - sending check results to queue" );
        $self->enqueue_results( $react );
    }

    return $react;
}

=item $obj->enqueue_results( $results )

Add any messages generated by monitor instances to the reactor queue.

The reactor queue is for use by the separate reactor process.  Note
that this happens after any reactor rules defined directly on the
monitor instance have been run.

The instance plugin class and key field will be added to any messages
before adding them to the queue.  Each unique monitor instance is
defined by the combination of the 'plugin' plus 'key' field.  If
either 'plugin' or 'key' is already defined, they will not be
overwritten.  This ensures that results that are produced by one
plugin and then collected by another plugin (e.g. on a remote host).

=cut

sub enqueue_results {
    my ( $self, $results ) = @_;

    return unless $results;

    unless ( ref $results eq "HASH" ) {
        my ($package, $file, $line) = caller();
        warn "ERROR: enqueue_results called without a hash: $package:$line: ", YAML::Dump $results;
        return;
    }

    # use our class name for the 'plugin' field
    unless ( $results->{plugin} ) {
        $results->{plugin}     = $self->{class};
    }

    # use our instance key name for the 'key' field
    unless ( $results->{key} ) {
        $results->{key}        = $self->key;
    }

    $self->reactor_queue->store( $results, $self->reactor_queue_dir );

}

__PACKAGE__->meta->make_immutable;

1;

__END__

=back
