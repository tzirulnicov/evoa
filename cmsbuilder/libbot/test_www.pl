#!/usr/bin/perl
BEGIN{
   push(@INC,'/www/evoo/evoo.ru/cmsbuilder/libbot/lib');
}
use WWW::RU::MOBIGURU;
use cyrillic qw/win2koi/;
#use CRC16;
#print crc16('testddddddddddsda4cic45icu5453%$%#%#$@#$#$@%VGHGFHGFHFHGHGFFGFGFGFGFGFGFGFGFGFGFGFGFGFGFGFGFGFGFGFGFGFGHFG  &&&$#^^%@^^@^@^@^@^%^$^$%^%$^$^%$GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGFGDGDGF%$%$%$%$%$%#%$#%   $% $#% $%$%#%$');
#exit;
$h=WWW::RU::MOBIGURU->new();
if (!$h->list_item(#Since_id=>239000,
#	SAVE_IMG_PATH=>'/www/evoo/evoo.ru/cmsbuilder/tmp',
#	SAVE_IMG_URL=>'http://evoo.ru',
	GROUP=>'/phones/nokia',
#	LIMIT=>10,
	DEBUG=>1)){
   die $h->{'errmsg'};
}
while($h->get_topic(DEBUG=>1)){
   next if $h->{content_body}!~/(с|С)енсор/;
next if $h->{content_body}=~/несенсор/;
   print "!!!!!!!!!!\n".$h->{'id'}.'. |'.win2koi($h->{'content_body'}.$h->{'content_body_add'})."|\n--------------\n";
print "!".$h->{'content_image'}."!\n";
#exit;
}
print $h->{errmsg}."\n";
