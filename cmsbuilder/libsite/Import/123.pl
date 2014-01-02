#!/usr/bin/perl
print "wait...\n";
sleep(10);
print "ok!\n";
open(FILE,'>/www/evoo/evoo.ru/cmsbuilder/tmp/tst.123') or die $!;
close(FILE);
