#!/usr/bin/perl

use warnings;
use strict;

use POSIX;
use Data::Dump qw(dump);

my $dev = '/dev/usb/lp0';
my $debug = 0;

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

	my $response;
	my $byte;
	while( sysread $parallel, $byte, 1 ) {
		$response .= $byte;
		warn "#<< ",dump($byte),$/ if $debug;
	}
	close($parallel);

	print "<answer ",dump($response),"\ncommand> ";

}

