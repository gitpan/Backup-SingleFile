use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/build_lib";
use Module::Build::FilterTests;

my $builder = Module::Build::FilterTests->new(
    module_name         => 'Backup::SingleFile',
    license             => 'perl',
    dist_author         => 'Ingo LANTSCHNER <ingo@boxbe.com>',
    dist_version_from   => 'lib/Backup/SingleFile.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Backup-SingleFile-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
