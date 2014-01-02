# (с) Токмаков А. И., 2005-2006

package mcwWareBase;
use strict qw(subs vars);
use utf8;

use CMSBuilder;
our @ISA = qw(CMSBuilder::DBI::Array);

sub _props
{
	'ware_id'=>{'type'=>'int',name=>'ware_id'},
	'field_id'=>{'type'=>'int',
#'type'=>'object','class'=>'mcwWareHeaderField',
'name'=>'ID поля'},
	'field_value'=>{'type'=>'string','name'=>'Значение'},
#	'mcw_link'=>{'type'=>'object','class'=>'mcwWareBase','name'=>'Свойства'}
#	'name'	=> { 'type' => 'string', 'length' => 100, 'name' => 'Название' },
#	'desc'	=> { 'type' => 'miniword', 'name' => 'Описание' }
}

#———————————————————————————————————————————————————————————————————————————————

1;
