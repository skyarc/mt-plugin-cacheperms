package MT::Plugin::CachePerms;
use strict;
use warnings;
use base 'MT::Plugin';

our $VERSION = '1.01';
our $NAME    = ( split /::/, __PACKAGE__ )[-1];

my $plugin = __PACKAGE__->new({
    name        => $NAME,
    id          => lc $NAME,
    key         => lc $NAME,
    l10n_class  => 'MTCMS::L10N',
    version     => $VERSION,
    author_name => 'SKYARC System Co., Ltd.',
    author_link => 'https://www.skyarc.co.jp/',
    description => '<__trans phrase="Cache permissions for speed-up when using MT 5.1 or later.">',
});
MT->add_plugin( $plugin );

my %cache_perms;
sub init_registry {
    my ( $p ) = @_;
    return unless $MT::VERSION >= 5.1 && $MT::VERSION < 5.2;
    $p->registry({
        callbacks => {
            init_app     => \&_init_app,
            init_request => {
                code     => sub { %cache_perms = (); },
                priority => 6,
            },
        },
    });
}

my $orig_perms_from_registry;
sub _init_app {
    unless ( $orig_perms_from_registry ) {
        {
            no warnings 'redefine';

            require MT::Permission;
            $orig_perms_from_registry = \&MT::Permission::perms_from_registry;
            *MT::Permission::perms_from_registry = sub {
                return \%cache_perms if %cache_perms;

                %cache_perms = %{ $orig_perms_from_registry->() };
                return \%cache_perms;
            };

        }
    }
}

1;
__END__
