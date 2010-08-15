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

=head2 Printer simulator

C<evolis-printer.pl> provides simulator for EVOLIS printer which is useful for development

=head2 Printer driver

C<evolis-driver.pl> provides driver which generates printer commands

=cut
