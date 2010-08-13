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

while(<>) {
	die "no escape at beginning" unless s/^\x1B//;
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
	} elsif ( $c eq 'Dbc' ) {
		my ( $color, $line, $len, $data ) = @a;
		while ( $len > length($data) ) {
			warn "# slurp more ",length($data), " < $len\n";
			$data .= <>;
		}
		$len == length $data or die "wrong length $len != ", length $data;

		my $path = "page-$page-$color.pbm";
		open(my $pbm, '>', $path);

		my $w = 1016;
		my $h = 648;

		$h = int( $len * 8 / $w );

		print $pbm "P4\n$w $h\n", $data;
		close($pbm);
		print "printed $path $w * $h size ", -s $path, "\n";
	} else {
		warn "UNKNOWN: $c ", dump(@a);
	}
}
