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
use HTML::TreeBuilder;
use HTML::FormatText;
use HTML::Parse;

local $DEBUG=1;
sql_connect();
sql_connect('txt2db',1);
my ($model,$desc);
open(FILE,'/www/evoo/evoo.ru/cmsbuilder/libbot/txt2db_nokia_15082008.txt') or die $!;
while(<FILE>){
   if ($_=~/^[a-zA-Z0-9\- \r\n\/]+$/ && $_=~/[a-zA-Z]{3,}/){
      $_=~s/[\r\n]//g;
if ($model && $desc){
   $model=~s/ +$//;
   $model=~s/^ +//;
   $model=~s/(Nokia 3110 )classic/\1Classic/;
   sql_query('SELECT ID,name from dbo_CatWareSimple where name like "'.Str2Sql($model).'%"');
   $check=0;
   while($row=$db_shandle->fetchrow_hashref){
      $model2=$row->{name};
      $model2=~s/[ a-zA-Z]+$//;
print "Model: ".$row->{name}.", check: |$model2|\n";
      if ($row->{name} eq $model || $model2 eq $model){
         print "OK\n";
	 $check=1;
print "id=".$row->{ID}."\n";
      sql_query('update dbo_CatWareSimple set `desc`="'.Str2Sql($desc).
	'" where ID='.$row->{ID},'txt2db',1);
      }
   }
if (!$check){
  print "|$model| :(((((((((\n";
#exit;
}
}
      $model=$_;
#print "Desc: |".win2koi($desc)."|\n";
#print "Model: |$_|\n";
      $desc='';
   }
   else {
      $desc.=$_;
   }
}
close(FILE);
sql_close(1);
sql_close();
exit;
sql_query('SELECT name,`desc` from dbo_CatWareSimple');
open (FILE,">/www/evoo/evoo.ru/htdocs/catalog.txt") or die $!;
while($row=$db_shandle->fetchrow_hashref){
   $html = HTML::TreeBuilder->new();
   $html->parse($row->{desc});

   $formatter = HTML::FormatText->new(leftmargin => 0, rightmargin => 50);
$row->{desc}=~s/<style>.*?<\/style>//gis;
$row->{desc}=~s/<[^>]+>//gs;
$row->{desc}=~s/[\r\n]+/\r\n/g;
$row->{desc}=~s/[\r\n](MicrosoftInternetExplorer4|false|Normal|0|X\-NONE|RU)[\r\n]//g;
   print FILE ("|".$row->{name}."|\r\n".
#utf2win($formatter->format(parse_html($row->{desc}))).
$row->{desc}.
"\r\n\r\n");
}
close(FILE);
sql_close();
