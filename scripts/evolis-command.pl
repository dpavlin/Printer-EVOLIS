#!/usr/bin/perl

use warnings;
use strict;

use Data::Dump qw(dump);
use Time::HiRes;
use Getopt::Long;
use Term::ReadLine;
use lib 'lib';
use Printer::EVOLIS::Parallel;

my $port = '/dev/usb/lp0';
my $debug = 0;

GetOptions(
	'debug+' => \$debug,
	'port=s' => \$port,
) || die $!;

warn "# port $port debug $debug\n";

my $parallel = Printer::EVOLIS::Parallel->new( $port );
sub cmd { $parallel->command( @_ ) }

my $term = Term::ReadLine->new('EVOLIS');
my $OUT = $term->OUT || \*STDOUT;

#select($OUT); $|=1;



my @help;
{
	open(my $fh, '<', 'docs/commands.txt');
	@help = <$fh>;
	warn "# help for ", $#help + 1, " comands, grep with /search_string\n";
}

while ( defined ( $_ = $term->readline('command> ')) ) {
	chomp;

	if ( m{^/(.*)} ) {
		print $OUT $_ foreach grep { m{$1}i } @help;
		next;
	}

	my $send = "\e$_\r";

	my $response = $parallel->command( $send );

	$term->addhistory($_) if $response;

	print $OUT "<answer ",dump($response),"\n";

}

