#!/usr/bin/perl

use warnings;
use strict;
use autodie;

my $card_svg = 'card/ffzg-2010.svg';

warn "# card template: $card_svg\n";

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

open(my $svg_template, '<', $card_svg);
open(my $svg,          '>', "$out.svg");

while(<$svg_template>) {

	if ( m{($re)} ) {
		warn "mapping $1\n";
		s{($1)}{mapping($1)}e;
	}

	print $svg $_;

}

close($svg_template);
close($svg);

open(my $inkscape, '|-', 'inkscape --shell --without-gui');

sub inkscape_export {
	my $part = shift;

	my $shell = "$out.svg --export-area-page --export-id $part";

	print $inkscape "$shell --export-pdf $out.$part.pdf\n";
	print $inkscape "$shell --export-png $out.$part.png --export-dpi 150\n";
}

inkscape_export 'print-front';
inkscape_export 'print-back';

# export visible
print $inkscape "$out.svg --export-png $out.png --export-dpi 300\n";

close($inkscape);

foreach my $pdf ( glob "$out*.pdf" ) {
	my $pbm = $pdf;
	$pbm =~ s/pdf$/pbm/;
	warn "# rendering $pdf => $pbm using ghostscript\n";
	system "gs -dNOPAUSE -dBATCH -q -r300x300 -dDEVICEWIDTHPOINTS=243 -dDEVICEHEIGHTPOINTS=155 -sDEVICE=pbmraw -sOutputFile=$pbm -f $pdf";
}

system "pdftk $out.print-front.pdf $out.print-back.pdf cat output $out.print-duplex.pdf";

__END__

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
