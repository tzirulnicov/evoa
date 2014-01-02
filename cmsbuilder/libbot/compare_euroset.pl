#!/usr/bin/perl
# йЪ-ЪБ ЙУРПМШЪПЧБОЙС УЙУФЕНОПЗП date() УЛТЙРФ ТБВПФБЕФ ФПМШЛП Ч *nix !
# уТБЧОЕОЙЕ ПРЙУБОЙК ОБ evoo.ru Й ОБ euroset.ru
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
#use cyrillic qw/win2koi koi2win utf2win/;
use HTML::TreeBuilder;
use HTML::FormatText;
use HTML::Parse;
use Encode;

local $DEBUG=1;
sql_connect();
sql_connect('txt2db',1);
use WWW::RU::EUROSET;
use LWP::Simple;
use Data::Dumper;
$h=WWW::RU::EUROSET->new();
$h->{links}=['/catalog/phones/mobile/lg/-/14645/'];
sql_query('set names "utf8"');
use utf8;

my $dbh=$db_handle;
=head
my $data_ar = $dbh->selectall_arrayref(qq~select ID, `desc` from dbo_CatWareSimple
	where `desc` like '%catwaresimple%'~) or die $dbh->errstr;
foreach my $item( @$data_ar ){
	 foreach my $id( $item->[1]=~m|catwaresimple(\d+)|g ){
	 	  my $data = $dbh->selectall_arrayref(qq~select concat('/',cd.my4,'/',cws.my4) url
	 	  		from tmp t, dbo_CatWareSimple cws, dbo_CatDir cd where t.ID=? and
	 	  		cws.name=t.name and cws.PAPA_ID=cd.ID and cws.PAPA_CLASS="CatDir";~,
	 	  		{Slice=>{}}, $id);
	 	  unless (@$data){
	 	  	  $item->[1]=~s/<a href=".*?catwaresimple$id.html">(.*?)<\/a>/$1/g;
	 	  	  next;
	 	  }
	 	  $item->[1]=~s/".*?catwaresimple$id.html/"$data->[0]->{url}/g;
	 }
	 $dbh->do(qq~UPDATE dbo_CatWareSimple set `desc`=? where ID=?~, undef, $item->[1], $item->[0]) or die $dbh->errstr;
}
exit;
=cut
#
my $data_ar = $dbh->selectall_arrayref(qq~select cws.ID,c.username, c.email,
	c.emailme,c.`desc`, c.ATS, c.CTS from test.dbo_Comment c, test.dbo_CommentsDir cd,
	test.dbo_CatWareSimple cws_old,dbo_CatWareSimple cws where c.PAPA_ID=cd.ID and c.PAPA_CLASS="CommentsDir" and
	cws.name=cws_old.name and cws_old.comments=cd.ID and c.`desc` not like '%http://%' and c.`desc`
	not like '%<a%' and c.`desc` not like '%[url%' and c.`desc` not like '%Email%' group by c.ID;~,{Slice=>{}}) or die $dbh->errstr;
my $count=0;
my %c_dirs;
$dbh->do(qq~delete from relations where ourl like 'CommentsDir%' or
	aurl like 'CommentsDir%'~) or die $dbh->errstr;
$dbh->do(qq~update dbo_CatWareSimple set comments=0~) or die $dbh->errstr;
$dbh->do(qq~truncate table dbo_CommentsDir~) or die $dbh->errstr;
$dbh->do(qq~truncate table dbo_Comment~) or die $dbh->errstr;
foreach my $comment( @$data_ar ){
	 warn (++$count).". Processing $comment->{username}...";
	 unless ($c_dirs{$comment->{ID}}){
	 	  $dbh->do(qq~INSERT into dbo_CommentsDir(ATS,CTS,PAPA_CLASS,PAPA_ID,OWNER) values (now(),now(),
	 	  	'CatWareSimple',?,'User1')~, undef, $comment->{ID} ) or die $dbh->errstr;
	 	  $c_dirs{$comment->{ID}} = { id => $dbh->{mysql_insertid}, cws_num => 1, c_dir_num => 1 };
	 	  $dbh->do(qq~UPDATE dbo_CatWareSimple set comments=? where ID=?~,undef,
	 	  	$c_dirs{$comment->{ID}}->{id},$comment->{ID});
#	 	  $dbh->do(qq~INSERT into relations (aurl, num, ourl, type, date) values
#	 	  	(?,?,?,'child',now())~, undef, "CatWareSimple".$comment->{ID},
#	 	  	($c_dirs{$comment->{ID}}->{cws_num}++), "CommentsDir".
#	 	  	$c_dirs{$comment->{ID}}->{id} ) or die $dbh->errstr;
	 }
	 $dbh->do(qq~INSERT into dbo_Comment (CTS,ATS,email,emailme,username,`desc`,
	 	PAPA_CLASS,PAPA_ID,OWNER) values (?,?,?,?,?,?,"CommentsDir",?,'User1')~, undef,
	 	$comment->{ATS}, $comment->{CTS}, $comment->{email}, $comment->{emailme},
	 	$comment->{username}, $comment->{desc}, $c_dirs{$comment->{ID}}->{id} ) or die $dbh->errstr;
	 my $comment_id = $dbh->{mysql_insertid};
	 $dbh->do(qq~INSERT into relations (aurl, num, ourl, type, date) values
	 	  	(?,?,?,'child',now())~, undef, "CommentsDir".$c_dirs{$comment->{ID}}->{id},
	 	  	($c_dirs{$comment->{ID}}->{c_dir_num}++), "Comment$comment_id"
	 ) or die $dbh->errstr;
}

exit;
my @rus_sym=split '', 'абвгдеёжзийклмнопрстуфхцчшщьыъэюя';
my @eng_sym=('a', 'b', 'v', 'g', 'd', 'e', 'yo', 'zh', 'z', 'i', 'y',
    'k', 'l', 'm', 'n', 'o', 'p', 'r', 's', 't', 'u', 'f',
    'kh', 'ts', 'ch', 'sh', 'shch', '', 'y', '', 'e', 'yu', 'ya');
my $data_ar = $db_handle->selectall_arrayref(qq~select `desc` from dbo_CatWareSimple where `desc` like '%catwaresimple%'~);
foreach my $desc(@$data_ar){
	  while($desc->[0]=~s/catwaresimple(\d+).html">(.*?)<\/a>//s){#"
	  		my $id=$1;
	      my $html=$2;
	      $html=~s/<[^>]+>//g;
	      $html=~s/^\s+//;
	      $html=~s/\s+$//;
	      $db_handle->do(qq~insert into tmp (ID,name) values (?,?)~,undef,$id,$html) or die $db_handle->errstr;
	      warn $id.'='.$html;
    }
}
exit;
my $data_ar = $db_handle->selectall_arrayref(qq~select ID,name,my4 from dbo_Tag~,{Slice=>{}}) or die $db_handle->errstr;
foreach my $row(@$data_ar){
Encode::_utf8_on($row->{name});
	 $row->{my4}=lc($row->{name});
#warn length( $row->{name} );
   $row->{my4}=~s/$rus_sym[$_]/$eng_sym[$_]/g foreach 0..$#rus_sym;
   $row->{my4}=~tr/a-z0-9\-/_/cs;
#warn $row->{name}.'/'.$row->{my4};
   my $count=0;
warn "$row->{ID}";
   while ( @{ $db_handle->selectall_arrayref(qq~select 1 from dbo_Tag where my4=?~,undef,$row->{my4}) } ){
   	  $row->{my4}=~s/\d+$//;
   	  $row->{my4}.=++$count;
   }
   $db_handle->do(qq~update dbo_Tag set my4=? where ID=?~,undef,$row->{my4},$row->{ID}) or die $db_handle->errstr;
}

exit;
my $data_ar=$db_handle->selectall_arrayref(qq~select ID,name from dbo_CatWareSimple
	where
	name regexp "^[ a-zA-Z0-9\@\$.,+-]+\$"~,{Slice=>{}});
die 'Nothing to do' unless @$data_ar;
my $count=0;
foreach my $data(@$data_ar){
my $ID=$data->{ID};
my $path='../../htdocs/ee/wwfiles/';
my @images;
if ( $h->get_topic( BY_NAME => $data->{name},
	SAVE_IMG_PATH => $path ) ){
#warn $h->{errmsg};
	@{$h->{content_images}} = grep{$_} @{$h->{content_images}};
 	sql_query('update dbo_CatWareSimple set photo="'.$h->{content_images}->[0].'"'.
 		(scalar(@{$h->{content_images}})>1?', photobig2="'.$h->{content_images}->[1].'"':'').
 		(scalar(@{$h->{content_images}})>2?', photobig3="'.$h->{content_images}->[2].'"':'').
 		(scalar(@{$h->{content_images}})>3?', photobig4="'.$h->{content_images}->[3].'"':'').
 		(scalar(@{$h->{content_images}})>4?', photobig5="'.$h->{content_images}->[4].'"':'').
 		(scalar(@{$h->{content_images}})>5?', photobig6="'.$h->{content_images}->[5].'"':'').
 		(scalar(@{$h->{content_images}})>6?', photobig7="'.$h->{content_images}->[6].'"':'').
 		(scalar(@{$h->{content_images}})>7?', photobig8="'.$h->{content_images}->[7].'"':'').
 		(scalar(@{$h->{content_images}})>8?', photobig9="'.$h->{content_images}->[8].'"':'').
 		(scalar(@{$h->{content_images}})>9?', photobig10="'.$h->{content_images}->[9].'"':'').
 			' where ID='.$ID) if @{$h->{content_images}};
   $count++ if @{$h->{content_images}};
} else {
#   warn $h->{errmsg};
}
get(qq~http://evoa.ru/catwaresimple$ID.html?init=1~);
}
warn "$count items successfully updated";
exit;
#use cyrillic qw/win2koi/;
open(FILE,'>/www/evoo/evoo.ru/cmsbuilder/libbot/compare_euroset.txt') or die $!;
foreach $k(qw/nokia samsung motorola sony-ericsson lg philips fly communicators bluetooth/){
$h=WWW::RU::EUROSET->new();
if (!$h->list_item(#Since_id=>239000,
#       SAVE_IMG_PATH=>'/www/evoo/evoo.ru/cmsbuilder/tmp',
#       SAVE_IMG_URL=>'http://evoo.ru',
        GROUP=>$k,
#        LIMIT=>1,
        DEBUG=>1)){
   die $h->{'errmsg'};
}
while($h->get_topic(DEBUG=>1)){
   print $h->{'id'}.'. |'.win2koi($h->{'content_subj'})."\n";
   sql_query('SELECT ID,`desc` from dbo_CatWareSimple where name="'.$h->{'content_subj'}.'"');
   next if (!($row=$db_shandle->fetchrow_hashref) || $h->{'content_body'} ne $row->{'desc'});
print FILE $h->{'content_subj'}." http://euroset.ru".$h->{'content_url'}.
	", http://evoo.ru/catwaresimple".$row->{ID}.".html\n";
print "Not difference: ".$h->{'content_subj'}."\n";
}
print $h->{errmsg}."\n";
}
close(FILE);
exit;
my ($model,$desc);
open(FILE,'/www/evoo/evoo.ru/cmsbuilder/libbot/txt2db_garniturs_23082008.txt') or die $!;
while(<FILE>){
   if ($_=~/^[a-zA-Z0-9\- \r\n]+$/ && $_=~/[a-zA-Z]{3,}/){
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

sub win2koi{
   my $text=shift;
   Encode::from_to($text,'cp1251','koi8-r');
   return $text;	
}