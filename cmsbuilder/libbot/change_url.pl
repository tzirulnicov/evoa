#!/usr/bin/perl
# Из-за использования системного date() скрипт работает только в *nix !
BEGIN{
   use FindBin qw($Bin);
   $errorMailNotify=1;
   $errorMailBox="tz\@tz.ints.ru";
   $FromEMail="tz\@tz.ints.ru";
   $splitStringsChar="\n";
   $logConsole=1;
   $splitStringsChar="\n";
   $DEBUG=1;
   require "$Bin/func.pl";
}
use cyrillic qw/win2koi koi2win utf2win/;
my $url_from='evoo.ru';
my $url_to='qiid.ru';
sql_connect();
for $k(qw/CatWareSimple/){
   sql_query('SELECT ID,`desc` from dbo_'.$k.' where `desc` like "%'.$url_from.'%"');
   while($row=$db_shandle->fetchrow_hashref){
      $row->{desc}=~s/$url_from/$url_to/g;
      $db_shandleAr[0]=$db_handle->prepare('UPDATE dbo_'.$k.' set `desc`=? where ID=?');
      $db_shandleAr[0]->execute($row->{desc},$row->{ID});
   }
}
sql_close();
