package Wubot::Plugin::Ping;
use Moose;

our $VERSION = '0.1_7'; # VERSION

with 'Wubot::Plugin::Roles::Cache';
with 'Wubot::Plugin::Roles::Plugin';

sub check {
    my ( $self, $inputs ) = @_;

    my $cache  = $inputs->{cache};
    my $config = $inputs->{config};

    my $host        = $config->{host};
    my $num_packets = $config->{num_packets} || 1;
    my $command     = $config->{command}     || "ping -c $num_packets";

    my $rt;

    for my $line ( split /\n/, `$command $host 2>&1` ) {
        chomp $line;
        next unless $line;

        if ( $line =~ m|icmp_seq\=(\d+)| ) {
            my $icmp_seq = $1;
            $line =~ m|time\=([\d\.]+)|;
            my $time = $1;
            $rt->{$icmp_seq} = $time;
        }
        else {
            next if $line =~ m/data bytes|statistics|packets transmitted|round-trip/;
            $self->logger->warn( "Can't parse output of ping command: $line" );
        }
    }

    my $count_received = scalar ( keys %{ $rt } );

    my $average = 0;
    for my $icmp_seq ( keys %{ $rt } ) {
        $average += $rt->{$icmp_seq};
    }
    if ( $average ) { $average = int ( $average / $count_received * 100 ) / 100 }

    my $loss = $num_packets - $count_received;

    my $reaction = { host    => $config->{host},
                     count   => $num_packets,
                     average => $average,
                     loss    => $loss,
                 };

    if ( $loss == $num_packets ) {
        $reaction->{subject} = "Unable to ping host: $config->{host}";
    }

    return { react => $reaction };
}

1;

