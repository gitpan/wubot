
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'personal distributed reactive automation',
  'AUTHOR' => 'Alex White <VVu@geekfarm.org>',
  'BUILD_REQUIRES' => {
    'English' => '0',
    'File::Temp' => '0',
    'Test::Differences' => '0',
    'Test::Exception' => '0',
    'Test::More' => '0.88',
    'utf8' => '0'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.30'
  },
  'DISTNAME' => 'wubot',
  'EXE_FILES' => [
    'bin/wubot-check',
    'bin/wubot-monitor',
    'bin/wubot-reactor',
    'bin/wubot-workhours'
  ],
  'LICENSE' => 'bsd',
  'NAME' => 'wubot',
  'PREREQ_PM' => {
    'AnyEvent' => '0',
    'AnyEvent::IRC::Client' => '0',
    'AnyEvent::Watchdog' => '0',
    'AnyEvent::Watchdog::Util' => '0',
    'AnyEvent::XMPP::Client' => '0',
    'Astro::MoonPhase' => '0',
    'Astro::Sunrise' => '0',
    'Benchmark' => '0',
    'Capture::Tiny' => '0',
    'Carp' => '0',
    'Class::Load' => '0',
    'DBD::SQLite' => '0',
    'DBI' => '0',
    'Date::Manip' => '0',
    'Devel::Size' => '0',
    'Devel::StackTrace' => '0',
    'Device::SerialPort' => '0',
    'Digest::MD5' => '0',
    'Encode' => '0',
    'Fcntl' => '0',
    'File::Path' => '0',
    'File::chdir' => '0',
    'FileHandle' => '0',
    'FindBin' => '0',
    'Getopt::Long' => '0',
    'HTML::Strip' => '0',
    'HTML::TableExtract' => '0',
    'HTTP::Message' => '0',
    'LWP::Simple' => '0',
    'LWP::UserAgent' => '0',
    'Log::Log4perl' => '0',
    'MIME::Base64' => '0',
    'MIME::Entity' => '0',
    'Mail::MboxParser' => '0',
    'Maildir::Lite' => '0',
    'Moose' => '0',
    'Moose::Role' => '0',
    'Net::TiVo' => '0',
    'Net::Twitter::Lite' => '0',
    'POSIX' => '0',
    'RRD::Simple' => '0',
    'RRDs' => '0',
    'SQL::Abstract' => '0',
    'Scalar::Util' => '0',
    'Storable' => '0',
    'Sys::Hostname' => '0',
    'Term::ANSIColor' => '0',
    'Text::Template' => '0',
    'XML::Feed' => '0',
    'XML::Twig' => '0',
    'YAML' => '0',
    'YAML::XS' => '0'
  },
  'VERSION' => '0.2_001',
  'test' => {
    'TESTS' => 't/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



