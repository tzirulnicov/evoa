#!/usr/bin/perl
# йЪ-ЪБ ЙУРПМШЪПЧБОЙС УЙУФЕНОПЗП date() УЛТЙРФ ТБВПФБЕФ ФПМШЛП Ч *nix !
BEGIN{
   use FindBin qw($Bin);
   $errorMailNotify=1;
   $errorMailBox="tz\@tz.ints.ru";
   $FromEMail="tz\@tz.ints.ru";
   $splitStringsChar="\n";
   $logConsole=1;
   $splitStringsChar="\n";
   $DEBUG=1;
   $Bin='/www/evoo/evoo.ru/cmsbuilder/libbot';
   require "$Bin/func.pl";
}
use cyrillic qw/win2koi koi2win utf2win/;

local $DEBUG=1;
sql_connect();
sql_query('SELECT cws.name,cws.price,ct.name from dbo_CatWareSimple as cws,
	dbo_CatDir as ct where cws.PAPA_ID=ct.ID order by cws.name');
print '<html><META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=windows-1251">';
print '<body><pre>';
while (@row=$db_shandle->fetchrow_array()){
   #print $row[2].' > ';
   print $row[0].' '.$row[1]."\n";
}
print '</pre></body></html>';
sql_close();
