use inc::Module::Install;

name     'Printer-EVOLIS';
all_from 'lib/Printer/EVOLIS.pm';
author   q{Dobrica Pavlinusic <dpavlin@rot13.org>};
license  'perl';

requires 'Data::Dump';

build_requires 'Test::More';

build_requires 'Module::Install::Repository';
auto_set_repository;

test_requires 'Pod::Readme';

auto_install;

WriteAll;

