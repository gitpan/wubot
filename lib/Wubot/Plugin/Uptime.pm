package Wubot::Plugin::Uptime;
use Moose;

our $VERSION = '0.1_6'; # VERSION

use Log::Log4perl;

with 'Wubot::Plugin::Roles::Cache';
with 'Wubot::Plugin::Roles::Plugin';

has 'logger'  => ( is => 'ro',
                   isa => 'Log::Log4perl::Logger',
                   lazy => 1,
                   default => sub {
                       return Log::Log4perl::get_logger( __PACKAGE__ );
                   },
               );

sub validate_config {
    my ( $self, $config ) = @_;

    my @required_params = qw( command warning_load critical_load );

    for my $param ( @required_params ) {
        unless ( $config->{$param} ) {
            die "ERROR: required config param $param not defined for: ", $self->key, "\n";
        }
    }

    return 1;
}


sub check {
    my ( $self, $inputs ) = @_;

    $self->logger->debug( "Check command: $inputs->{config}->{command}" );

    my $uptime_output = `$inputs->{config}->{command}`;
    chomp $uptime_output;

    my ( $load01, $load05, $load15 ) = $self->parse_uptime( $uptime_output );

    unless ( defined $load01 && defined $load05 && defined $load15 ) {
        my $subject = $self->key . ": ERROR: unable to parse uptime output: $uptime_output";
        $self->logger->warn( $subject );
        return { react => { subject => $subject } };
    }

    $self->logger->debug( "load: $load01 => $load05 => $load15" );

    my $subject;
    my $status = "ok";
    if ( $inputs->{config}->{critical_load} && $load01 > $inputs->{config}->{critical_load} ) {
        $subject = "critical: load over last 1 minute is $load01 ";
        $status = 'critical';
    } elsif ( $inputs->{config}->{warning_load} && $load01 > $inputs->{config}->{warning_load} ) {
        $subject = "warning: load over last 1 minute is $load01 ";
        $status = 'warning';
    }

    my $results = { load01  => $load01,
                    load05  => $load05,
                    load15  => $load15,
                    status  => $status,
                };

    if ( $subject ) {
        $results->{subject} = $subject;
    }

    return { react => $results };
}

sub parse_uptime {
    my ( $self, $string ) = @_;

    unless ( $string =~ m/load averages?\: ([\d\.]+)\,?\s+([\d\.]+),?\s+([\d\.]+)/ ) {
        return;
    }

    my ( $load01, $load05, $load15 ) = ( $1, $2, $3 );

    return ( $load01, $load05, $load15 );
}

1;
