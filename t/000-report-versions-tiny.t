use strict;
use warnings;
use Test::More 0.88;
# This is a relatively nice way to avoid Test::NoWarnings breaking our
# expectations by adding extra tests, without using no_plan.  It also helps
# avoid any other test module that feels introducing random tests, or even
# test plans, is a nice idea.
our $success = 0;
END { $success && done_testing; }

my $v = "\n";

eval {                     # no excuses!
    # report our Perl details
    my $want = "any version";
    my $pv = ($^V || $]);
    $v .= "perl: $pv (wanted $want) on $^O from $^X\n\n";
};
defined($@) and diag("$@");

# Now, our module version dependencies:
sub pmver {
    my ($module, $wanted) = @_;
    $wanted = " (want $wanted)";
    my $pmver;
    eval "require $module;";
    if ($@) {
        if ($@ =~ m/Can't locate .* in \@INC/) {
            $pmver = 'module not found.';
        } else {
            diag("${module}: $@");
            $pmver = 'died during require.';
        }
    } else {
        my $version;
        eval { $version = $module->VERSION; };
        if ($@) {
            diag("${module}: $@");
            $pmver = 'died during VERSION check.';
        } elsif (defined $version) {
            $pmver = "$version";
        } else {
            $pmver = '<undef>';
        }
    }

    # So, we should be good, right?
    return sprintf('%-45s => %-10s%-15s%s', $module, $pmver, $wanted, "\n");
}

eval { $v .= pmver('AnyEvent','any version') };
eval { $v .= pmver('AnyEvent::IRC::Client','any version') };
eval { $v .= pmver('AnyEvent::Watchdog','any version') };
eval { $v .= pmver('AnyEvent::Watchdog::Util','any version') };
eval { $v .= pmver('AnyEvent::XMPP::Client','any version') };
eval { $v .= pmver('Astro::MoonPhase','any version') };
eval { $v .= pmver('Astro::Sunrise','any version') };
eval { $v .= pmver('Benchmark','any version') };
eval { $v .= pmver('Capture::Tiny','any version') };
eval { $v .= pmver('Carp','any version') };
eval { $v .= pmver('Class::Load','any version') };
eval { $v .= pmver('DBD::SQLite','any version') };
eval { $v .= pmver('DBI','any version') };
eval { $v .= pmver('Data::ICal','any version') };
eval { $v .= pmver('Data::ICal::Entry::Alarm::Audio','any version') };
eval { $v .= pmver('Data::ICal::Entry::Alarm::Display','any version') };
eval { $v .= pmver('Data::ICal::Entry::Event','any version') };
eval { $v .= pmver('Date::ICal','any version') };
eval { $v .= pmver('Date::Manip','any version') };
eval { $v .= pmver('DateTime','any version') };
eval { $v .= pmver('Devel::StackTrace','any version') };
eval { $v .= pmver('Device::SerialPort','any version') };
eval { $v .= pmver('Digest::MD5','any version') };
eval { $v .= pmver('Encode','any version') };
eval { $v .= pmver('English','any version') };
eval { $v .= pmver('ExtUtils::MakeMaker','6.30') };
eval { $v .= pmver('Fcntl','any version') };
eval { $v .= pmver('File::Basename','any version') };
eval { $v .= pmver('File::Path','any version') };
eval { $v .= pmver('File::Spec','any version') };
eval { $v .= pmver('File::Temp','any version') };
eval { $v .= pmver('File::chdir','any version') };
eval { $v .= pmver('FileHandle','any version') };
eval { $v .= pmver('FindBin','any version') };
eval { $v .= pmver('Getopt::Long','any version') };
eval { $v .= pmver('Growl::Tiny','any version') };
eval { $v .= pmver('HTML::Strip','any version') };
eval { $v .= pmver('HTML::TableExtract','any version') };
eval { $v .= pmver('HTML::TokeParser::Simple','any version') };
eval { $v .= pmver('HTTP::Message','any version') };
eval { $v .= pmver('LWP::Simple','any version') };
eval { $v .= pmver('LWP::UserAgent','any version') };
eval { $v .= pmver('Log::Log4perl','any version') };
eval { $v .= pmver('MIME::Base64','any version') };
eval { $v .= pmver('MIME::Entity','any version') };
eval { $v .= pmver('Mail::MboxParser','any version') };
eval { $v .= pmver('Maildir::Lite','any version') };
eval { $v .= pmver('Mojo::Base','any version') };
eval { $v .= pmver('Moose','any version') };
eval { $v .= pmver('Moose::Role','any version') };
eval { $v .= pmver('Net::TiVo','any version') };
eval { $v .= pmver('Net::Twitter::Lite','any version') };
eval { $v .= pmver('POSIX','any version') };
eval { $v .= pmver('RRD::Simple','any version') };
eval { $v .= pmver('RRDs','any version') };
eval { $v .= pmver('SQL::Abstract','any version') };
eval { $v .= pmver('Scalar::Util','any version') };
eval { $v .= pmver('Storable','any version') };
eval { $v .= pmver('Sys::Hostname','any version') };
eval { $v .= pmver('Term::ANSIColor','any version') };
eval { $v .= pmver('Test::Differences','any version') };
eval { $v .= pmver('Test::Exception','any version') };
eval { $v .= pmver('Test::Mojo','any version') };
eval { $v .= pmver('Test::More','any version') };
eval { $v .= pmver('Test::Routine','any version') };
eval { $v .= pmver('Text::Template','any version') };
eval { $v .= pmver('URI::Escape','any version') };
eval { $v .= pmver('URI::Find','any version') };
eval { $v .= pmver('WWW::LongURL','any version') };
eval { $v .= pmver('XML::Atom::SimpleFeed','any version') };
eval { $v .= pmver('XML::Feed','any version') };
eval { $v .= pmver('XML::RSS','any version') };
eval { $v .= pmver('XML::Simple','any version') };
eval { $v .= pmver('XML::Twig','any version') };
eval { $v .= pmver('YAML','any version') };
eval { $v .= pmver('YAML::XS','any version') };
eval { $v .= pmver('strict','any version') };
eval { $v .= pmver('utf8','any version') };
eval { $v .= pmver('warnings','any version') };



# All done.
$v .= <<'EOT';

Thanks for using my code.  I hope it works for you.
If not, please try and include this output in the bug report.
That will help me reproduce the issue and solve you problem.

EOT

diag($v);
ok(1, "we really didn't test anything, just reporting data");
$success = 1;

# Work around another nasty module on CPAN. :/
no warnings 'once';
$Template::Test::NO_FLUSH = 1;
exit 0;
