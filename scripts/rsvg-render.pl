#!/usr/bin/perl

use warnings;
use strict;
use autodie;

use XML::Twig;
use Data::Dump qw(dump);

die "unsage: $0 card/template.svg 201008159999 login Ime Prezime\n" unless @ARGV;

my ($card_svg,$nr,$login,$ime,$prezime) = @ARGV;

my $png = $ENV{PNG} || 0;

warn "# svg: $card_svg nr: $nr $ime $prezime\n";

my $mapping = {
'200908109999' => $nr,
'login0123456789@ffzg.hr' => $login,
'Knjižničarko' => $ime,
'Čitalić' => $prezime,
};

mkdir 'out' unless -d 'out';
my $out = 'out/' . $nr;

foreach my $existing ( glob $out . '*' ) {
	warn "# remove $existing ", -s $existing, " bytes\n";
	unlink $existing;
}

my $twig = XML::Twig->new(
	twig_handlers => {
		'text/tspan' => sub {
			if ( my $replace = $mapping->{ $_->text } ) {
				warn "# replace ", $_->text, " => $replace\n";
				$_->set_text( $replace );
			}
		},
	},
	pretty_print => 'indented',                
);
$twig->parsefile( $card_svg );

while ( my($from,$to) = each %$mapping ) {
	warn "# replace $from -> $to\n";
	$twig->subs_text( qr{$from}, $to );
}

foreach my $layer ( qw( front back ) ) {

	foreach my $el ( $twig->get_xpath(q{g[@inkscape:groupmode="layer"]}) ) {
		if ( $el->{att}->{'inkscape:label'} eq $layer ) {
			$el->set_att( 'style' => 'display:inline' );
		} else {
			$el->set_att( 'style' => 'display:none' );
		}

	}

	my $base = "$out.$layer";

	my $rsvg_convert = "rsvg-convert --width=1016 --height=648";
	if ( $png ) {
		$rsvg_convert  .= " --output $base.png";
	} else {
		$rsvg_convert .= " | pngtopnm -alpha | pnminvert > $base.pnm";
	}
	$rsvg_convert = "tee /tmp/test.svg | $rsvg_convert";

	open(my $rsvg, '|-', $rsvg_convert);
	$twig->print( $rsvg );
	close($rsvg);

	my $path =(glob("$base*"))[0];
	warn "# $path ", -s $path, " bytes\n";

}

