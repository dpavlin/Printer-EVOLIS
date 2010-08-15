package Printer::EVOLIS;

use warnings;
use strict;

=head1 NAME

Printer::EVOLIS - pixel-exact driver for EVOLIS Dualys two-side card printer in perl

=cut

our $VERSION = '0.01';

=head1 DESCRIPTION

This is experimental support for EVOLIS Dualys 3 printer with black ribbon (K) to provide
pixel-exact driver with support for two-side printing.

Existing cups driver available at

L<http://www.evolis.com/eng/Drivers-Support/Product-support/Dualys-3>

does work, but I haven't been able to make it print duplex on cards, especially when generating
front and back pages separatly.

=head1 SCRIPTS

Current toolset consists of following scripts:

=head2 scripts/inkscape-render.pl card/template.svg 201008159999 Name Surname

Generate pdf files from Inkscape SVG template in C<card/> using
C<print-front> and C<print-back> object IDs. Layers doesn't work
since we can't toggle visilbity easily. To print more than one
object gruop them and change ID of group.

After pdf files are created, GhostScript is used to rasterize them
into pbm (monochrome) bitmaps.

=head2 scripts/evolis-driver.pl front.pbm back.pbm > evolis.commands

Provides driver which generates printer command stream to print
two-sided card from pbm files.

=head2 scripts/evolis-simulator.pl evolis

Simulator for EVOLIS printer commands which is useful for development.
It creates one pbm file per page printed.

=head1 EXAMPLE

Following is simple walk-through from svg image in Inkscape to
evolis command stream which can be executed in top-level directory
of this distribution:

  ./scripts/inkscape-render.pl card/ffzg-2010.svg 201008159999 Ime Prezime
  ./scripts/evolis-driver.pl out/201008159999.front.pbm out/201008159999.back.pbm > evolis
  ./scripts/evolis-simulator.pl evolis
  qiv evolis*.pbm

=cut
