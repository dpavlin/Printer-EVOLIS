package Printer::EVOLIS;

use warnings;
use strict;

=head1 NAME

Printer::EVOLIS - pixel-exact driver for EVOLIS Dualys two-side card printer in perl

=cut

our $VERSION = '0.01';

=head1 DESCRIPTION

This is experimental support for EVOLIS Dualys 3 printer with black ribbon (K)
to provide pixel-exact driver with support for two-side printing.

Existing cups driver is available at

L<http://www.evolis.com/eng/Drivers-Support/Product-support/Dualys-3>

but I haven't been able to make it print on both sides of cards,
partly because using dumplex option in cups seems to segfault GhostScript
and/or C<rastertoevolis> cups filter depending on combination of duplex
options.

I also needed pixel perfect transfer to printer, and cups
bitmap format is always in color, leaving final pixel modifications down
to cups filter which always produced differences between file sent to
printer and perfect black and white rendition of it.

=head1 SCRIPTS

Current toolset consists of following scripts:

=head2 scripts/inkscape-render.pl card/template.svg 201008159999 login Name Surname

Generate pdf files from Inkscape SVG template in C<card/> using
C<print-front> and C<print-back> object IDs. Layers doesn't work
since we can't toggle visilbity easily. To print more than one
object gruop them and change ID of group.

After pdf files are created, GhostScript is used to rasterize them
into pbm (monochrome) bitmaps.

=head2 scripts/evolis-driver.pl front.pbm back.pbm > evolis.commands

Provides driver which generates printer command stream to print
two-sided card from pbm files. Back side file is optional if you want
to print just on front side of card.

=head2 scripts/evolis-simulator.pl evolis

Simulator for EVOLIS printer commands which is useful for development.
It creates one pbm file per page printed.

=head2 scripts/evolis-command.pl

Command-line interface to send commands to printer and receive responses.
Supports readline for editing and history.
Requires local parallel port connection, probably to USB parallel device.

=head1 EXAMPLE

Following is simple walk-through from svg image in Inkscape to
evolis command stream which can be executed in top-level directory
of this distribution:

  ./scripts/inkscape-render.pl card/ffzg-2010.svg 201008159999 Ime Prezime
  ./scripts/evolis-driver.pl out/201008159999.front.pbm out/201008159999.back.pbm > evolis
  ./scripts/evolis-simulator.pl evolis
  qiv evolis*.pbm

=cut
