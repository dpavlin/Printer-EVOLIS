#!/usr/bin/perl

# Simulate EVOLIS Dualys printer

use warnings;
use strict;

use Data::Dump qw(dump);

local $/ = "\r";

my $page = 1;

my $name = $ARGV[0] || 'page';

sub save_pbm;

while(<>) {
	die "no escape at beginning",dump($_) unless s/^(\x00*)\x1B//;
	warn "WARNING: ", length($1), " extra nulls before ESC\n" if $1;
	chomp;
	my @a = split(/;/,$_);
	my $c = shift @a;
	if ( $c eq 'Pmi' ) {
		print "$_ mode insertion @a\n";
	} elsif ( $c eq 'Pc' ) {
		print "$_ contrast @a\n";
	} elsif ( $c eq 'Pl' ) {
		print "$_ luminosity @a\n";
	} elsif ( $c eq 'Ps' ) {
		print "$_ speed @a\n";
	} elsif ( $c eq 'Pr' ) {
		print "$_ ribbon $a[0]\n";
	} elsif ( $c eq 'Ss' ) {
		print "$_ sequence start\n";
	} elsif ( $c eq 'Se' ) {
		print "$_ sequence end\n";
	} elsif ( $c eq 'Sr' ) {
		print "$_ sequence recto - card side\n";
	} elsif ( $c eq 'Sv' ) {
		print "$_ sequence verso - back side\n";
	} elsif ( $c eq 'Db' ) {
		my ( $color, $two, $data ) = @a;
		print "$c;$color;$two;... bitmap\n";
		$two eq '2' or die '2';
		my $path = "$name-Db-$color-$page.pbm"; $page++;
		save_pbm $path, 648, 1015, $data;	# FIXME 1016?
	} elsif ( $c eq 'Dbc' ) { # XXX not in cups
		my ( $color, $line, $len, $comp ) = @a;
		print "$c;$color;$line;$len;... FIXME bitmap - compressed?\n";
		while ( $len > length($comp) ) {
			warn "# slurp more ",length($comp), " < $len\n";
			$comp .= <>;
		}
		$len == length $comp or warn "wrong length $len != ", length $comp;

		my $w = 648 / 2;

=for non-working

		my $data;

		my $i = 0;
		while ( $i < length $comp ) {
			my $len = ord(substr($comp,$i,4));
			$i += 1;
			warn "$i comp $len\n";
			$data .= substr($comp,$i,$len);
			$data .= "\x00" x ( $w - $len );
			$i += $len;
		}

=cut

		my $data = $comp;

		my $path = "$name-Dbc-$color-$page.pbm"; $page++;
		my $h = int( $len / 128 );
		save_pbm $path, $w, $h, $data;

	} else {
		print "FIXME: $_\n";
	}
}

sub save_pbm {
	my ( $path, $w, $h, $data ) = @_;
	open(my $pbm, '>', $path);
	print $pbm "P4\n$w $h\n", $data;
	close($pbm);
	print "saved $path $w * $h size ", -s $path, "\n";
}
