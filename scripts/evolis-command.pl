#!/usr/bin/perl

use warnings;
use strict;

use POSIX;
use Data::Dump qw(dump);
use Time::HiRes;

my $dev = '/dev/usb/lp0';
my $debug = 1;

my $parallel;

$|=1;
print "command> ";
while(<STDIN>) {
	chomp;

	my $send = "\e$_\r";

	# XXX we need to reopen parallel port for each command
	sysopen( my $parallel, $dev, O_RDWR | O_EXCL) || die "$dev: $!";

	foreach my $byte ( split(//,$send) ) {
		warn "#>> ",dump($byte),$/ if $debug;
		syswrite $parallel, $byte, 1;
	}

	close($parallel);
	sysopen( $parallel, $dev, O_RDWR | O_EXCL) || die "$dev: $!";

	my $response;
	while ( ! sysread $parallel, $response, 1 ) { sleep 0.1 }; # read first char
	my $byte;
	while( sysread $parallel, $byte, 1 ) {
		warn "#<< ",dump($byte),$/ if $debug;
		last if $byte eq "\x00";
		$response .= $byte;
	}
	close($parallel);

	print "<answer ",dump($response),"\ncommand> ";

}

