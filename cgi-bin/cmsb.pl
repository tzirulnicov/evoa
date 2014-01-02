#!/usr/bin/perl
use strict qw(subs vars);
use warnings;

use CGI::Carp 'fatalsToBrowser';

BEGIN
{
	require '/home/httpd/evoa.ru/cmsbuilder/Config.pm';
#open(FILE,">>/www/evoo/evoo.ru/cmsbuilder/tmp/test.log") or die $!;
#print FILE $ENV{REQUEST_URI}."\n";
#close(FILE);
}
use CMSBuilder::Starter;
CMSBuilder::Starter->start();
