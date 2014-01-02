#!/usr/bin/perl
use strict qw(subs vars);
use warnings;

use CGI::Carp 'fatalsToBrowser';
use DBI;
use DBD::mysql;
use CGI qw/:standard/;
#soundwork - arr_modSite править
BEGIN
{
        require '/www/evoo/evoo.ru/cmsbuilder/Config.pm';
}
#почему вначале News,а затем уже modNews обрабатывается? Из-за этого неверно
#PAPA_ID у детей объекта прописывается, с уже недействительным ID
my $mysql_base=param('db')||'evoo';
my $mysql_user=param('user')||'goga';
my $mysql_pass=param('pass')||'07080900';
my $mysql_port=3306;
my $mysql_data_source= 'DBI:mysql:'.$mysql_base.';port='.$mysql_port;
my @src_modules=qw/modCatalog CatDir CatWareSimple Page modNews News modFeedback Tag Film/;

my $c=CGI->new;
my @cws_added;
my $old_version=1;#old version of CMSBuilder
my $dbh=DBI->connect($mysql_data_source,$mysql_user,$mysql_pass) or die $DBI::errstr;
#$dbh->do('create table if not exists temp(url varchar(100))');
#$dbh->do('truncate table temp');
my @modules=modules_exists();

print header, start_html('Relinking script'), start_form, "Database name: ", 
	textfield('db',$mysql_base), " User: ", textfield('user',$mysql_user),
	" Pass: ", password_field('pass'), " Use MY4: ",
	checkbox('my4','checked'), ' ', hidden('action', 'go'), submit, end_form;
if (param('action') eq 'go'){
   change_url($_) foreach @modules;
}
print end_html;

sub change_url{
   #in one module
   my $module_name=shift;
   my $all_my4=\@_;
   my $d=$dbh->prepare('SELECT max(ID) from dbo_'.$module_name);
   $d->execute or die $DBI::errstr;
   # With Id+1 start inserting new values
   my $max_id=$d->fetchrow_arrayref->[0];
   my ($my4,$d2);
   $d=$dbh->prepare('SELECT ID,PAPA_CLASS'.(param('my4')?',my4':'').' from dbo_'.$module_name);
   $d->execute or die $DBI::errstr;
   while(my $row=$d->fetchrow_hashref){
      print "ID=$row->{ID}, my4=$row->{my4}: ";
      $my4='';# Genering new unique my4 if it's presents
      $my4=gen_new_my4($row->{my4},$all_my4);
      print "change to $module_name".++$max_id.' with my4='.$my4."<br>\n";
      change_url_in_templates(old=>["$module_name$row->{ID}",$row->{my4}],
		new=>["$module_name$max_id",$my4]);
      $dbh->do('UPDATE dbo_'.$module_name.' set ID='.$max_id.
	(param('my4')?',my4='.$dbh->quote($my4):'').' where ID='.$row->{ID}) or die $DBI::errstr;
      if ($module_name ne 'News'){
         $d2=$dbh->prepare('SELECT ourl from '.
		(!$old_version?'relations':'arr_'.
		$module_name).' where aurl=?'.
		(!$old_version?' and type<>"tag"':''));
         $d2->execute($module_name.$row->{ID}) or die $DBI::errstr;
         while(my @row2=$d2->fetchrow_array){
	    print 'update PAPA_ID in dbo_'.$row2[0].'<br>' if $row2[0]=~/^([a-zA-Z]+)(\d+)$/;
#print 'UPDATE dbo_'.$1.' set PAPA_ID='.$max_id.
                ' where ID='.$2;
	    $dbh->do('UPDATE dbo_'.$1.' set PAPA_ID='.$max_id.
		' where ID='.$2) if $row2[0]=~/^([a-zA-Z]+)(\d+)$/;
         }
         $dbh->do('UPDATE '.(!$old_version?'relations':'arr_'.
        	$module_name).' set '.$_.'url="'.$module_name.$max_id.
		'" where '.$_.'url="'.$module_name.$row->{ID}.'"') foreach qw/a o/;
      }
      $dbh->do('UPDATE arr_'.$row->{PAPA_CLASS}.' set ourl="'.
		$module_name.$max_id.'" where ourl="'.$module_name.$row->{ID}.
		'"') if $old_version;
      $dbh->do('UPDATE arr_modSite set ourl="'.$module_name.$max_id.
		'" where ourl="'.$module_name.$row->{ID}.'"') if $old_version;
#      }
      if ($module_name eq 'CatWareSimple'){
	 $dbh->do("UPDATE dbo_$_ set PAPA_ID=$max_id where 
		PAPA_CLASS='CatWareSimple' and PAPA_ID=$row->{ID}")
	    foreach @cws_added;
      }
      elsif ($module_name eq 'Tag'){
	 $d2=$dbh->prepare('SELECT ID,tag from dbo_CatWareSimple where tag like
		"%Tag'.$row->{ID}.'%"');
	 $d2->execute;
	 while(my @row2=$d2->fetchrow_array){
	    $row2[1]=~s/Tag$row->{ID}/Tag$max_id/g;
	    $dbh->do('UPDATE dbo_CatWareSimple set tag='.$dbh->quote($row2[1]).
		' where ID='.$row2[0]);
	 }
      }
   }
}

sub change_url_in_templates{
   my %urls=@_;
   my $d=$dbh->prepare('SELECT ID,content from dbo_TextTemplate');
   $d->execute();
   while(my $row=$d->fetchrow_hashref){
      for (0..1){
	 if ($urls{old}[$_]){
	    #print "change $urls{old}[$_] to $urls{new}[$_]<br>";
	    my $url_new_small=lc($urls{new}[$_]);
	    $row->{content}=~s/(href *\= *['"]\/?)$urls{old}[$_]("|'|\.html)/\1$url_new_small\2/gi;
	    $row->{content}=~s/{$urls{old}[$_]\./{$urls{new}[$_]\./gi;
	 }
      };
      #$row->{content}=~s/(type *\= *['"]text\/css)[^"']+/\1/g;
      my $d2=$dbh->prepare('UPDATE dbo_TextTemplate set content=? where ID=?');
      $d2->execute($row->{content},$row->{ID});
   }
}

sub gen_new_my4{
   my ($my4,$all_my4)=@_;
   my $suffix=1;
   return '' if !$my4;
   while(1){
      last if !grep{$_ eq $my4.$suffix} @$all_my4;
   }
   push @$all_my4,$my4.$suffix;
   $my4.$suffix;
}

sub get_all_my4{
   my @modules=@_;
   my (@my4,@row,$d);
   foreach (@modules){
      $d=$dbh->prepare('SELECT my4 from dbo_'.$_.' where my4<>""');
      $d->execute();
      push @my4,$row[0] while @row=$d->fetchrow_array;
   }
   @my4;
}

sub modules_exists{
   my $d=$dbh->prepare('SHOW tables');
   my @ar;
   $d->execute();
   while(my @row=$d->fetchrow_array){
      $old_version=0 if $row[0] eq 'relations';
      push @ar,substr($row[0],4) if grep{'dbo_'.$_ eq $row[0]} @src_modules;
      push @cws_added,substr($row[0],4) if $row[0] eq 'MultiPropsDir' or
	$row[0] eq 'CommentsDir';
   }
   my @ar_temp=grep{$_=~/^[a-z]/}@ar;
   push @ar_temp,sort{$a cmp $b}grep{$_=~/^[A-Z]/}@ar;
   @ar_temp;
}
