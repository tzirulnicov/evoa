#!/usr/bin/perl
use strict;
use warnings;

print "Content-type: text/plain\n\n";
print "$_: $ENV{$_}\n" for keys %ENV;
open LOG, '>', 'echo.log';
select LOG;

print LOG "$_: $ENV{$_}\n" for keys %ENV;

print $_ while <STDIN>;