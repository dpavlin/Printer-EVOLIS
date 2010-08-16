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
$Printer::EVOLIS::Parallel::debug = $debug;
sub cmd { $parallel->command( "\e$_[0]\r" ) }

my $term = Term::ReadLine->new('EVOLIS');
my $OUT = $term->OUT || \*STDOUT;

#select($OUT); $|=1;



my @help;
{
	open(my $fh, '<', 'docs/commands.txt');
	@help = <$fh>;
	warn "# help for ", $#help + 1, " comands, grep with /search_string\n";
}

print $OUT "Printer model ", cmd('Rtp'),"\n";
print $OUT "Printer s/no  ", cmd('Rsn'),"\n";
print $OUT "Kit head no   ", cmd('Rkn'),"\n";
print $OUT "Firmware      ", cmd('Rfv'),"\n";
print $OUT "Mac address   ", cmd('Rmac'),"\n";
print $OUT "IP address    ", cmd('Rip'),"\n";

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

