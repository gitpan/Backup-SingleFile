#!/usr/bin/perl -T

use strict;
use warnings;

use Test::More  tests => 20;
use Backup::SingleFile qw{ append_date };
use Smart::Comments;

# ====================================
# = Tests for function "append_date" =
# ====================================

my $now = 1234567890; # 14. 02. 2009 in CET
$ENV{"TZ"} = "CET";
is(append_date('CURRENT.GPX', $now), 'CURRENT_2009-02-14.GPX', 'Suffix date to CURRENT.GPX');
is(append_date('./CURRENT.GPX', $now), 'CURRENT_2009-02-14.GPX', 'Suffix date to ./CURRENT.GPX');
is(append_date('Some/dir/CURRENT.GPX', $now), 'Some/dir/CURRENT_2009-02-14.GPX', 'Suffix date to Some/dir/CURRENT.GPX');
is(append_date('/some/dir/CURRENT.GPX', $now), '/some/dir/CURRENT_2009-02-14.GPX', 'Suffix date to /some/dir/CURRENT.GPX');
is(append_date('CURRENT with Spaces.GPX', $now), 'CURRENT with Spaces_2009-02-14.GPX', 'Suffix date to CURRENT with Spaces.GPX');
is(append_date('CURRENT.with.dots.GPX', $now), 'CURRENT.with.dots_2009-02-14.GPX', 'Suffix date to CURRENT.with.dots.GPX');
is(append_date('CURRENT.with.double.extension.gpx.gpx', $now), 'CURRENT.with.double.extension.gpx_2009-02-14.gpx', 'Suffix date to CURRENT.with.double.extension.gpx.gpx');
is(append_date('CURRENT.with space.and.dots.gpx', $now), 'CURRENT.with space.and.dots_2009-02-14.gpx', 'Suffix date to CURRENT.with space.and.dots.gpx');

# uncommon values
is(append_date('CURRENT.GPX', 'Alle meine Entlein'), undef, 'Cant use string as date');
is(append_date('CURRENT.GPX', '0000000000000000000000000000'), 'CURRENT_1970-01-01.GPX', 'Many 000000000 as time');
is(append_date('CURRENT.GPX', -123456789), 'CURRENT_1966-02-02.GPX', 'Negative time');
is(append_date('CURRENT.GPX', '	Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'), undef, 'Long text as time');

# UTC
$now = 1234567890; # 13. 02. 2009 in UTC
$ENV{"TZ"} = "UTC";
is(append_date('CURRENT.GPX', $now), 'CURRENT_2009-02-13.GPX', 'Suffix date to CURRENT.GPX');
is(append_date('./CURRENT.GPX', $now), 'CURRENT_2009-02-13.GPX', 'Suffix date to ./CURRENT.GPX');
is(append_date('Some/dir/CURRENT.GPX', $now), 'Some/dir/CURRENT_2009-02-13.GPX', 'Suffix date to Some/dir/CURRENT.GPX');
is(append_date('/some/dir/CURRENT.GPX', $now), '/some/dir/CURRENT_2009-02-13.GPX', 'Suffix date to /some/dir/CURRENT.GPX');
is(append_date('CURRENT with Spaces.GPX', $now), 'CURRENT with Spaces_2009-02-13.GPX', 'Suffix date to CURRENT with Spaces.GPX');
is(append_date('CURRENT.with.dots.GPX', $now), 'CURRENT.with.dots_2009-02-13.GPX', 'Suffix date to CURRENT.with.dots.GPX');
is(append_date('CURRENT.with.double.extension.gpx.gpx', $now), 'CURRENT.with.double.extension.gpx_2009-02-13.gpx', 'Suffix date to CURRENT.with.double.extension.gpx.gpx');
is(append_date('CURRENT.with space.and.dots.gpx', $now), 'CURRENT.with space.and.dots_2009-02-13.gpx', 'Suffix date to CURRENT.with space.and.dots.gpx');
