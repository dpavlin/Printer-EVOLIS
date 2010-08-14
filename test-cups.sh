#!/bin/sh -x

ls test/*.pdf | xargs -i sh -c "./gs-cups-raster.sh < {} > {}.cups"
ls test/*.cups | xargs -i sh -c "./cups-rastertoevolis.sh {} > {}.evolis"
ls test/*.evolis | xargs -i ./evolis-printer.pl {}
ls -al test/
