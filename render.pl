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

mkdir 'out' unless -d 'out';
my $out = 'out/' . $nr;

foreach my $existing ( glob $out . '*' ) {
	warn "# remove $existing ", -s $existing, " bytes\n";
	unlink $existing;
}

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

#system "inkscape --file $out.print.svg  --export-pdf $out.pdf";

system "inkscape --file $out.print.svg --export-area-page --export-pdf $out.print-front.pdf --export-id print-front";
system "inkscape --file $out.print.svg --export-area-page --export-pdf $out.print-back.pdf --export-id print-back";
system "pdftk  $out.print-front.pdf $out.print-back.pdf cat output $out.print-duplex.pdf";

#system "inkscape --file $out.screen.svg --export-png $out.png --export-dpi 180";

#system "inkscape --file $out.screen.svg --export-png $out.300.png --export-dpi 300";

system "inkscape --file $out.print.svg --export-area-page --export-png $out.print-front.png --export-dpi 150 --export-id print-front --export-id-only";
system "inkscape --file $out.print.svg --export-area-page --export-png $out.print-back.png --export-dpi 150 --export-id print-back --export-id-only";


#system "qiv $out.png";
#system "xpdf $out.pdf";
