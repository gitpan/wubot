package Wubot::Plugin::TiVo;
use Moose;

our $VERSION = '0.1_9'; # VERSION

use Net::TiVo;

with 'Wubot::Plugin::Roles::Cache';
with 'Wubot::Plugin::Roles::Plugin';

has 'reactor'  => ( is => 'ro',
                    isa => 'CodeRef',
                    required => 1,
                );

has 'logger'  => ( is => 'ro',
                   isa => 'Log::Log4perl::Logger',
                   lazy => 1,
                   default => sub {
                       return Log::Log4perl::get_logger( __PACKAGE__ );
                   },
               );


sub check {
    my ( $self, $inputs ) = @_;

    my $cache  = $inputs->{cache};
    my $config = $inputs->{config};

    # todo: forking plugin fu to prevent running more than one at once
    unless ( $config->{nofork} ) {
        my $pid = fork();
        if ( $pid ) {
            # parent process
            return { react => { subject => "launched tivo child process: $pid" } }
        }
    }

    eval {                          # try

        my $tivo = Net::TiVo->new(
            host  => $config->{host},
            mac   => $config->{key},
        );

      FOLDER:
        for my $folder ($tivo->folders()) {

            my $folder_string = $folder->as_string();
            $self->logger->debug( "TIVO FOLDER: $folder_string" );

            next if $folder_string =~ m|^HD Recordings|;

          SHOW:
            for my $show ($folder->shows()) {
                my $show_string = $show->as_string();

                next SHOW if $cache->{shows}->{$show_string};
                next SHOW if $show->in_progress();

                my $subject = join ": ", $show->name(), $show->episode();

                # duration in minutes
                my $duration = int( $show->duration() / 60000 );

                # size in MB
                my $size     = int( $show->size() / 1000000 );

                $self->reactor->( { subject     => $subject,
                                    name        => $show->name(),
                                    episode     => $show->episode(),
                                    episode_num => $show->episode_num(),
                                    recorded    => $show->capture_date(),
                                    format      => $show->format(),
                                    hd          => $show->high_definition(),
                                    size        => $size,
                                    channel     => $show->channel(),
                                    duration    => $duration,
                                    description => $show->description(),
                                    program_id  => $show->program_id(),
                                    series_id   => $show->series_id(),
                                    link        => $show->url(),
                                } );

                $cache->{shows}->{$show_string} = 1;

            }
        }

        # write out the updated cache
        $self->write_cache( $cache );

        1;
    } or do {                   # catch

        $self->logger->info( "ERROR: getting tivo info: $@" );
    };

    exit 0;
}

1;

