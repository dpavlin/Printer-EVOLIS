#!/usr/bin/perl

use warnings;
use strict;

open(my $html, '<', 'docs/Programming_Guide_A5013_RevEs.html') || die "run pdftohtml: $!";

sub strip_html {
	my $t = shift;
	$t =~ s{&(nbsp|#160);}{ }gs;
	$t =~ s{(<br/?>|\n)+}{}gs;
	$t =~ s{\s+$}{}gs;
	$t =~ s{\s*;\s*}{;}gs;
	return $t;
}

while(<$html>) {
	next if m{^(&(nbsp|#160);)?Page \d+};
	if ( m{<b>(\w+)(&nbsp;|&#160;)?</b><br/?>} ) {
		my $command = $1;
		my $param = <$html>;
		next if $param =~ m{Page #};
		my $description = <$html>;
		printf "%-4s %-15s %s\n", $command, strip_html($param), strip_html($description);
	}
}

