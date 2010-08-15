#!/usr/bin/perl

use warnings;
use strict;

use POSIX;
use Data::Dump qw(dump);
use Time::HiRes;
use Getopt::Long;

my $port = '/dev/usb/lp0';
my $debug = 0;

GetOptions(
	'debug+' => \$debug,
	'port=s' => \$port,
) || die $!;

warn "# port $port debug $debug\n";

my $parallel;

$|=1;
print "command> ";
while(<STDIN>) {
	chomp;

	my $send = "\e$_\r";

	# XXX we need to reopen parallel port for each command
	sysopen( $parallel, $port, O_RDWR | O_EXCL) || die "$port: $!";

	foreach my $byte ( split(//,$send) ) {
		warn "#>> ",dump($byte),$/ if $debug;
		syswrite $parallel, $byte, 1;
	}

	close($parallel);
	# XXX and between send and receive
	sysopen( $parallel, $port, O_RDWR | O_EXCL) || die "$port: $!";

	my $response;
	while ( ! sysread $parallel, $response, 1 ) { sleep 0.1 }; # XXX wait for 1st char
	my $byte;
	while( sysread $parallel, $byte, 1 ) {
		warn "#<< ",dump($byte),$/ if $debug;
		last if $byte eq "\x00";
		$response .= $byte;
	}
	close($parallel);

	print "<answer ",dump($response),"\ncommand> ";

}

