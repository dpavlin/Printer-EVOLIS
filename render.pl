#!/usr/bin/perl

use warnings;
use strict;
use autodie;

my ($nr,$ime,$prezime) = ( qw/
200900000042
Dobrica
Pavlinušić
/ );

my $mapping = {
'200908109999' => $nr,
'Knjižničarko' => $ime,
'Čitalić' => $prezime,
};

sub mapping { $mapping->{ $_[0] } }

my $re = join('|', keys %$mapping);

my $out = 'out/' . $nr;

open(my $in,     '<', 'template.svg');
open(my $print,  '>', "$out.print.svg");
open(my $screen, '>', "$out.screen.svg");

while(<$in>) {

	if ( m{($re)} ) {
		warn "mapping $1\n";
		s{($1)}{mapping($1)}e;
	}

	if ( s{##print##}{none} ) {
		warn "print layer: $_\n";
		print $print $_;
		s{none}{inline};
		print $screen $_;

	} else {
		print $print  $_;
		print $screen $_;
	}

}

close($in);
close($print);
close($screen);

system "inkscape --file $out.print.svg  --export-pdf $out.pdf";
system "inkscape --file $out.screen.svg --export-png $out.png --export-dpi 180";

system "inkscape --file $out.screen.svg --export-png $out.300.png --export-dpi 300";

#system "qiv $out.png";
#system "xpdf $out.pdf";
