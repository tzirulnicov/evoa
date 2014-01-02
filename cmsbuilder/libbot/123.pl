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
open(PROG,'echo 12345|') or die $!;
print <PROG>;
close(PROG);
exit;
use Time::Local;
($sec,$min,$hour,$mday,$mon,$year)=(localtime(time))[0,1,2,3,4,5];
$mon++;
$year+=1900;
print "$year-$mon-$mday $hour:$min:$sec\n";
exit;
@times=split(/[\- \:]/,'2008-10-15 01:13:20');
$period=24*60*60;#hour*min*sec
$unixtime=timelocal($times[5],$times[4],$times[3],$times[2],--$times[1],$times[0]);
#print join(',',localtime());
if ($unixtime+$period>time()){
print "ne nado start\n";
} else{
print "nado start\n";}
exit;
use cyrillic qw/koi2win/;
$str='Pilotage-RC.ru / Каталог / Авиамодели / Учебно-тренировочные / '.
      'Радиоуправляемый самолет Авиатор "J-3 Sunburst" (Red/Blue), электро';
$str2='Радиоуправляемый самолет Авиатор "J-3 Sunburst" (Red/Blue), электро';
$str2=~s/([\(\)\/\-])/\\\1/g;
print $str2;
$str=~s/$str2//;
print $str."!\n";
exit;
sql_connect();
print "ok\n";
#$head='Автомодель р/у 1:8 "Destroyer 7.7", ДВС , RTR, 4WD';
@{$self->{'content_nav'}}=split(/ /,koi2win('Каталог Авиамодели Учебно-тренировочные'));
sql_query('SELECT t.ID from dbo_modTags as mt,dbo_Tag as t where (mt.name="'.
	$self->{'content_nav'}->[$#{self->{'content_nav'}}-1].'-'.
	koi2win('теги').'" or mt.name="'.
	$self->{'content_nav'}->[$#{self->{'content_nav'}}-1].
	'") and t.PAPA_ID=mt.ID and t.name="'.
	$self->{'content_nav'}->[$#{self->{'content_nav'}}].'"');
while($row=$db_shandle->fetchrow_hashref){
   print "Tag".$row->{'ID'}."\n";
}
sql_close();
