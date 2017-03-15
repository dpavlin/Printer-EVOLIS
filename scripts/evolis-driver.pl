#!/usr/bin/perl

use warnings;
use strict;

my ( $front, $back ) = @ARGV;
die "usage: $0 front.pbm back.pbm\n" unless $front;

sub read_pbm;

sub cmd {
	my ( $cmd, $description ) = @_;
	print "\x1B",$cmd,"\r";
	$cmd =~ s/^(Db[\w\d;]+).+/$1_/s;
	warn sprintf "## %-10s %s\n", $cmd, $description;
}

cmd 'Pr;k' => 'ribbon: black';

# F = Feeder
# M = Manual
# B = Auto
cmd 'Pmi;F;s' => 'mode insertion: F';

cmd 'Pc;k;=;10' => 'contrast k = 10';

# FIXME ? only implemented in windows
#cmd 'Pdt;DU';
#cmd 'Mr;s';
#cmd 'Ppws;1281732635';

cmd 'Ss' => 'sequence start';

cmd 'Sr' => 'front side';

my $data = read_pbm $front;
cmd 'Db;k;2;' . $data => 'download front';

cmd 'Sv' => 'back side';

cmd 'Pc;k;=;10' => 'contrast k = 10';

$data = read_pbm $back;
cmd 'Db;k;2;' . $data => 'download back';

cmd 'Se' => 'sequence end';
print "\x00" x 64; # FIXME some padding?


sub read_pbm {
	my $path = shift;
	open(my $pbm, "pnmflip -rotate270 $path |");
	my $magic = <$pbm>; chomp $magic;
	my $size = <$pbm>; chomp $size;
	my ($x_size,undef) = split(/\s/,$size,2);
	if ( $x_size <= 640 || $x_size > 648 ) {
		die "picture has to have 81 bytes in line line, so 641 - 648 pixels hight";
	}
	my $bitmap;
	if ( $magic eq 'P4' ) { # portable bitmap
		local $/ = undef;
		$bitmap = <$pbm>;
		warn "# $path $size ", length($bitmap), " bytes\n";
	} elsif ( $magic eq 'P5' || $magic eq 'P6' ) { # portable graymap/pixmap
		my $max_color = <$pbm>; chomp $max_color;

		my $trashold = $max_color / 2;

		local $/ = undef;
		my $rgb = <$pbm>;

		my $mask = 0x80;
		my $byte = 0;

		my $step = $magic eq 'P6' ? 3 : 1;

		my $o = 0;
		while ( $o < length($rgb) ) {
			my $px = ord(substr($rgb,$o,1)); $o += $step;
			$byte ^= $mask if $px < $trashold;
			$mask >>= 1;
			if ( ! $mask ) { 
				$bitmap .= chr($byte);
				$byte = 0;
				$mask = 0x80;
			}
		}

		warn "# $path $size ", length($bitmap), " bytes\n";

	} else {
		die "unsupported $magic format!";
	}

	if ( my $padding = ( 648 * 1016 / 8 - length($bitmap) ) ) {
		warn "# adding $padding zero bytes padding\n";
		$bitmap .= "\x00" x $padding;
	}

	return $bitmap;
}
