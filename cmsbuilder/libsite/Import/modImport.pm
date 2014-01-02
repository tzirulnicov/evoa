# (с) Леонов П.А., 2005

package modImport;
use strict qw(subs vars);
use utf8;

our @ISA = ('plgnSite::Members','CMSBuilder::DBI::TreeModule');

use CMSBuilder;
use CMSBuilder::Utils;
use plgnUsers;
sub _cname {'Импорт прайс-листа'};
sub _aview{qw/disable period rules sopostavil/};
sub _props{
	'disable'=> {'type'=>'bool','name'=>'Отключить скрипт обновления товаров'},
	'period' => {'type'=>'string',name=>'Период скачивания, часов'},
	'rules'	=> {'type'=>'text',name=>'Правила обработки'},
	'sopostavil'=>{'type'=>'text',name=>'Сопоставление через ">" товаров в прайсе товарам в базе'},
	'times' => {'type'=>'timestamp'}
}
sub _rpcs{qw/import_now_update/}
sub name{
   return shift->_cname;
}
sub import_now_update{
   print 123;
   close(STDOUT);
#close(STDERR);
#close(STDIN);
   my $fpid;
   die "Cannot fork" unless defined($fpid=fork);
   return if $fpid;
   #open(STDOUT,'>/dev/null') or die "Cannot write /dev/null";
   #open(STDIN,'</dev/null') or die "Cannot read /dev/null";
   #open(STDERR,'>&STDOUT') or die "Cannot copying stderr";
use Proc::Daemon;
Proc::Daemon::Init;
   print `perl /home/httpd/evoa.ru/cmsbuilder/libbot/price_update.pl`;
}
sub admin_props{
   my $o=shift;
   print '<center><input type="button" value="Обновить прайс '.
	'сейчас" action="/srpc/'.$o->myurl.'/import_now_update" onclick="update_price(this)"><p>
	Дата последнего запуска: <input type="text" disabled value="'.$o->{times}.'"></center>';
   $o->SUPER::admin_props(@_);
}
1;
