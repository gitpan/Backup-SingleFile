#!/usr/bin/perl -T

use strict;
use warnings;

use Test::More tests => 23;
use Test::Output;
use Backup::SingleFile qw{ increment };
#use Smart::Comments;

# ================================
# = Tests for function increment =
# ================================ 

is(increment('Current_2009-02-13.gpx'), 'Current_2009-02-13_000.gpx', 'Increment counter-suffix' );
is(increment('Current_blabla.gpx'), 'Current_blabla_000.gpx', 'Increment counter-suffix' );
is(increment('Current_blabla_000.gpx'), 'Current_blabla_001.gpx', 'Increment counter-suffix' );
is(increment('Current_000_002.gpx'), 'Current_000_003.gpx', 'Increment counter-suffix' );
is(increment('Current_2009-02-13_000.gpx'), 'Current_2009-02-13_001.gpx', 'Increment counter-suffix' );
is(increment('Current_2009-02-13_001.gpx'), 'Current_2009-02-13_002.gpx', 'Increment counter-suffix' );
is(increment('Current_2009-02-13_009.gpx'), 'Current_2009-02-13_010.gpx', 'Increment counter-suffix' );
is(increment('Current_2009-02-13_010.gpx'), 'Current_2009-02-13_011.gpx', 'Increment counter-suffix' );
is(increment('Current_2009-02-13_099.gpx'), 'Current_2009-02-13_100.gpx', 'Increment counter-suffix' );
is(increment('Current_2009-02-13_100.gpx'), 'Current_2009-02-13_101.gpx', 'Increment counter-suffix' );


## counter over-run 
 
 # Returnvalue 

my $newfn = increment('Current_2009-02-13_999.gpx');
is($newfn, undef, 'New filename must be undef if counter-suffix overrun occurs' );

 # Errormessage
stderr_like {increment('Current_2009-02-13_999.gpx')} qr/^Counter-suffix overrun - only 1001 copies per day supported/;


## "unusal" characters in filename
is(increment('Current with Spaces.gpx'), 'Current with Spaces_000.gpx', 'Increment counter-suffix (Spaces)' );
is(increment('Current with Spaces_000.gpx'), 'Current with Spaces_001.gpx', 'Increment counter-suffix (Spaces)' );
is(increment('Current with Spaces_009.gpx'), 'Current with Spaces_010.gpx', 'Increment counter-suffix (Spaces)' );
is(increment('Current with.dots.gpx'), 'Current with.dots_000.gpx', 'Increment counter-suffix (Dots)' );
is(increment('Current with.dots_000.gpx'), 'Current with.dots_001.gpx', 'Increment counter-suffix (Dots)' );
is(increment('Current with.dots_010.gpx'), 'Current with.dots_011.gpx', 'Increment counter-suffix (Dots)' );
is(increment('Current with.dots_019.gpx'), 'Current with.dots_020.gpx', 'Increment counter-suffix (Dots)' );


## testing long suffixes 
is(increment('Current_1002'), 'Current_1002_000', 'Increment #1 of Current_1002' );
is(increment('Current_1000'), 'Current_1000_000', 'Increment of Current_1000' );
is(increment('Current_9999'), 'Current_9999_000', 'Increment of Current_9999' );
is(increment('Current_9999_999'), undef, 'Increment of Current_9999_999' );
