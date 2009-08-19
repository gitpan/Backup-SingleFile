use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/build_lib";
use Module::Build::FilterTests;

my $builder = Module::Build::FilterTests->new(
    module_name         => 'Backup::SingleFile',
    license             => 'perl',
    dist_author         => 'Ingo LANTSCHNER <perl@lantschner.name>',
    dist_version_from   => 'lib/Backup/SingleFile.pm',
    configure_requires => {
        'SUPER'                     => 0,
    },
    build_requires => {
        'Test::More'                => 0,
        'Test::File'                => 0,
        'Test::Output'              => 0,
        'Test::Cmd'                 => 0,
        'FindBin'                   => 0,
        'File::Path'                => 0,
        'File::Glob'                => 0,
        'File::Spec::Functions'     => 0,
        'SUPER'                     => 0,
    },
    requires => {
        'perl'                      => '5.8.0',
        'Carp'                      => 0,
        'File::Basename'            => 0,
        'Time::localtime'           => 0,
        'File::Copy'                => 0,
    },
    add_to_cleanup      => [ 'Backup-SingleFile-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
