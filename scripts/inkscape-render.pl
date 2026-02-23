#!/usr/bin/perl

use warnings;
use strict;
use autodie;
use utf8;
use Encode qw(decode_utf8);
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

die "unsage: $0 card/template.svg 201008159999 login Ime Prezime\n" unless @ARGV;

my ($card_svg,$nr,$login,$ime,$prezime) = map { decode_utf8($_) } @ARGV;

warn "## $0 @ARGV";

my $png = $ENV{PNG} || 0;

warn "# svg: $card_svg nr: $nr $ime $prezime\n";

my $mapping = {
'200908109999' => $nr,
'login0123456789@ffzg.hr' => $login,
'Knjižničarko' => $ime,
'Čitalić' => $prezime,
};

sub mapping { $mapping->{ $_[0] } }

mkdir 'out' unless -d 'out';
my $out = 'out/' . $nr;

foreach my $existing ( glob $out . '*' ) {
	warn "# remove $existing ", -s $existing, " bytes\n";
	unlink $existing;
}

open(my $svg_template, '<:utf8', $card_svg);
open(my $svg,          '>:utf8', "$out.svg");

while(<$svg_template>) {

	foreach my $k (keys %$mapping) {
		if ( index($_, $k) != -1 ) {
			my $v = $mapping->{$k};
			warn "mapping $k -> $v\n";
			s{\Q$k\E}{$v}g;
		}
	}

	print $svg $_;

}



close($svg_template);
close($svg);

sub inkscape_export {
	my $part = shift;

	my $actions = "file-open:$out.svg ; export-id:$part ; export-id-only ; export-area-page ;";

	$part =~ s/print-//; # FIXME change svg files

	warn "# inkscape_export $part";
	system qq{inkscape --actions="$actions ; export-type:pdf ; export-filename:$out.$part.pdf ; export-do ;"};
#	print $inkscape "$actions ; export-type:png ; export-filename:$out.$part.png ; export-dpi 150 ; export-do ;" if $png;
}

inkscape_export 'print-front';
inkscape_export 'print-back';

# export visible
#print $inkscape "$out.svg --export-png $out.png --export-dpi 300\n" if $png;


foreach my $pdf ( glob "$out*.pdf" ) {
	my $pbm = $pdf;
	$pbm =~ s/pdf$/pbm/;
	warn "# rendering $pdf => $pbm using ghostscript\n";
	system "gs -dNOPAUSE -dBATCH -q -r300x300 -dDEVICEWIDTHPOINTS=243 -dDEVICEHEIGHTPOINTS=155 -dPDFFitPage -sDEVICE=pbmraw -sOutputFile=$pbm -f $pdf";
}

system "pdftk $out.front.pdf $out.back.pdf cat output $out.duplex.pdf" if $ENV{DUPLEX};

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
