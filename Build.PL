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
        'FindBin'                   => 0,
        'File::Glob'                => 0,
        'File::Spec::Functions'     => 0,
    },
    build_requires => {
        'Test::More'                => 0.80,
        'Test::File'                => 1.29,
        'Test::Output'              => 0.16,
        'Test::Cmd'                 => 1.05,
        'File::Path'                => 0,
        'Test::NoWarnings'          => 0.084,
        'SUPER'                     => 0,
        'Sub::Identify'             => 0,   # to satisfy some CPAN-Tests
        'FindBin'                   => 0,
        'File::Glob'                => 0,
        'File::Spec::Functions'     => 0,
    },
    requires => {
        'perl'                      => '5.8.0',
        'base'                      => 2.13,
        'Carp'                      => 0,
        'Exporter'                  => 0,
        'File::Basename'            => 0,
        'Time::localtime'           => 1.02,
        'File::Copy'                => 2.13,
    },
    add_to_cleanup      => [ 'Backup-SingleFile-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
