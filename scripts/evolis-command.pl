#!/usr/bin/perl

use warnings;
use strict;

use POSIX;
use Data::Dump qw(dump);

my $dev = '/dev/usb/lp0';

sysopen(my $parallel, $dev, O_RDWR | O_EXCL) || die "$dev: $!";

$|=1;
print "command> ";
while(<STDIN>) {
	chomp;
	
	my $send = "\e$_\r";
	foreach my $byte ( split(//,$send) ) {
		warn "#>> ",dump($byte),$/;
		syswrite $parallel, $byte, 1;
	}
	my $response;
	my $byte;
	while( sysread $parallel, $byte, 1 ) {
		$response .= $byte;
		warn "#<< ",dump($byte),$/;
	}
	print "<answer ",dump($response),"\ncommand> ";
}

close($parallel);
