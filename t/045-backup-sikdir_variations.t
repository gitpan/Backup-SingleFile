#!/usr/bin/perl -w

# $Id: cea86a3bba88d7bde591b384160655de1ba85a47 $

use strict;
use warnings;
our $DEBUG = 0;

use Test::More  tests => 6;
use Test::Cmd;
use Test::File;

use Backup::SingleFile qw{backup};

my $test = Test::Cmd->new(workdir => "temporary_test_root", verbose => $DEBUG);
ok($test, "creating Test::Cmd object");
print $test->workpath() . "\n" if $DEBUG > 1;
#$test->preserve;

$test->subdir('SIK1');
$test->subdir('SIK2');

# create small.txt
(my $small = << "END_HERE") =~ s/^\s+//gm;;
	Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
END_HERE
my $small_ok = $test->write("small.txt", $small);
ok($small_ok, "writing small.txt");
my $now = 1234567890; # UNIX-time

my $bak_dir = $test->workpath("SIK1");
my $bak_dir_slash = $test->workpath("SIK2") . q{/};
print STDERR "\$bak_dir:" . $bak_dir . "\n" if $DEBUG > 1;
print STDERR "\$bak_dir_slash:" . $bak_dir_slash . "\n" if $DEBUG > 1;
my $bak1_file = $test->workpath("SIK1", "small_2009-02-14.txt");
my $bak2_file = $test->workpath("SIK2", "small_2009-02-14.txt");
print STDERR "\$bak_file1: $bak1_file \n" if $DEBUG > 1;
print STDERR "\$bak_file2: $bak2_file \n" if $DEBUG > 1;
my $src_file = $test->workpath("small.txt");

my ($res) = backup($src_file, $bak_dir, $now);
is($res, 1, 'Returnvalue after backup of small.txt; backupdir NOT terminated with slash');
file_exists_ok($bak1_file, "Backup of small.txt exists; backupdir NOT terminated with slash");

my ($res_slash) = backup($src_file, $bak_dir_slash, $now);
is($res_slash, 1, 'Returnvalue after backup of small.txt; backupdir terminated with slash');
file_exists_ok($bak2_file, "Backup of small.txt exists; backupdir terminated with slash");
