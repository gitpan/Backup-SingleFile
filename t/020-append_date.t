#!/usr/bin/perl -T

use strict;
use warnings;

use Test::More  tests => 12 + 1;
use Test::NoWarnings;
use Backup::SingleFile qw{ append_date };

# ====================================
# = Tests for function "append_date" =
# ====================================

my $now = 1234567890; # 14. 02. 2009 in CET, 13. 02. 2009 in UTC
like(append_date('CURRENT.GPX', $now),              qr'CURRENT_2009-02-1[3|4].GPX', 'Suffix date to CURRENT.GPX');
like(append_date('./CURRENT.GPX', $now),            qr'CURRENT_2009-02-1[3|4].GPX', 'Suffix date to ./CURRENT.GPX');
like(append_date('Some/dir/CURRENT.GPX', $now),     qr'Some/dir/CURRENT_2009-02-1[3|4].GPX', 'Suffix date to Some/dir/CURRENT.GPX');
like(append_date('/some/dir/CURRENT.GPX', $now),    qr'/some/dir/CURRENT_2009-02-1[3|4].GPX', 'Suffix date to /some/dir/CURRENT.GPX');
like(append_date('CURRENT with Spaces.GPX', $now),  qr'CURRENT with Spaces_2009-02-1[3|4].GPX', 'Suffix date to CURRENT with Spaces.GPX');
like(append_date('CURRENT.with.dots.GPX', $now),    qr'CURRENT.with.dots_2009-02-1[3|4].GPX', 'Suffix date to CURRENT.with.dots.GPX');
like(append_date('CURRENT.with.double.extension.gpx.gpx', $now),    qr'CURRENT.with.double.extension.gpx_2009-02-1[3|4].gpx', 'Suffix date to CURRENT.with.double.extension.gpx.gpx');
like(append_date('CURRENT.with space.and.dots.gpx', $now),          qr'CURRENT.with space.and.dots_2009-02-1[3|4].gpx', 'Suffix date to CURRENT.with space.and.dots.gpx');

# uncommon values
is(append_date('CURRENT.GPX', 'Alle meine Entlein'), undef, 'Cant use string as date');
is(append_date('CURRENT.GPX', '0000000000000000000000000000'), 'CURRENT_1970-01-01.GPX', 'Many 000000000 as time');
is(append_date('CURRENT.GPX', -123456789), 'CURRENT_1966-02-02.GPX', 'Negative time');
is(append_date('CURRENT.GPX', '	Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'), undef, 'Long text as time');

