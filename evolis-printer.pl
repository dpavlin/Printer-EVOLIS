#!/usr/bin/perl

# Simulate EVOLIS Dualys printer

use warnings;
use strict;

use Data::Dump qw(dump);

my $feeder = {qw(
F Feeder
M Manual
B Auto
)};

local $/ = "\r";

my $page = 1;

sub save_pbm;

while(<>) {
	die "no escape at beginning",dump($_) unless s/^\x1B//;
	chomp;
	my @a = split(/;/,$_);
	my $c = shift @a;
	if ( $c eq 'Pmi' ) {
		my $f = $a[0] || die 'missing feeder';
		print "feeder $f | $feeder->{$f}\n";
		$a[1] eq 's' or die;
	} elsif ( $c eq 'Pc' ) {
		my $color = $a[0];
		$a[1] eq '=' or die;
		my $temperature = $a[2];
		print "temperature $color = $temperature\n";
	} elsif ( $c eq 'Pr' ) {
		print "improve $a[0]\n";
		# FIXME windows sends it, cups doesn't
	} elsif ( $c eq 'Db' ) { # XXX not in cups
		my ( $color, $two, $data ) = @a;
		$two eq '2' or die '2';
		my $path = "page-Db-$color-$page.pbm";
		$page++;
		save_pbm $path, 648, 1015, $data;	# FIXME 1016?
	} elsif ( $c eq 'Dbc' ) { # XXX not in cups
		my ( $color, $line, $len, $data ) = @a;
		while ( $len > length($data) ) {
			warn "# slurp more ",length($data), " < $len\n";
			$data .= <>;
		}
		$len == length $data or warn "wrong length $len != ", length $data;

		my $path = "page-Dbc-$color-$page.pbm";
		$page++;

		my ( $w, $h ) = ( 646, 1081 );	# from driver
#		( $w, $h ) = ( 636, 994 );		# from test card
		$h = int( length($data) * 8 / $w );
		save_pbm $path, $w, $h, $data;

	} else {
		warn "UNKNOWN: $c ", dump(@a);
	}
}

sub save_pbm {
	my ( $path, $w, $h, $data ) = @_;
	open(my $pbm, '>', $path);
	print $pbm "P4\n$w $h\n", $data;
	close($pbm);
	print "saved $path $w * $h size ", -s $path, "\n";
}
