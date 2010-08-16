#!/usr/bin/perl

use warnings;
use strict;

open(my $html, '<', 'Programming_Guide_A5013_RevEs.html') || die "run pdftohtml: $!";

sub strip_html {
	my $t = shift;
	$t =~ s{&nbsp;}{ }gs;
	$t =~ s{(<br>|\n)+}{}gs;
	$t =~ s{\s+$}{}gs;
	return $t;
}

while(<$html>) {
	next if m{^(&nbsp)?Page \d+};
	if ( m{<b>(\w+)&nbsp;</b><br>} ) {
		my $command = $1;
		my $param = <$html>;
		my $description = <$html>;
		print "$command\t", strip_html($param) , "\t", strip_html($description), "\n";
	}
}

