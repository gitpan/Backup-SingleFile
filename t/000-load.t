#!/usr/bin/perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Backup::SingleFile' );
}

diag( "Testing Backup::SingleFile $Backup::SingleFile::VERSION, Perl $], $^X" );
