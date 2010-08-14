ls test/*.pdf | xargs -i sh -c "./gs-cups-raster.sh < {} > {}.cups"
ls test/*.cups | xargs -i sh -c "./cups-rastertoevolis.sh {} > {}.evolis"
ls -al test/
