#!/usr/bin/perl -T

use Test::More tests => 7;

BEGIN {
	use lib 'lib';
	use_ok( 'Printer::EVOLIS' );
}

diag( "Testing Printer::EVOLIS $Printer::EVOLIS::VERSION, Perl $], $^X" );
