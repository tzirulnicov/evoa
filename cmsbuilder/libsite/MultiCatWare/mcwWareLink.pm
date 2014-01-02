# (с) Токмаков А. И., 2005-2006

package mcwWareLink;
use strict qw(subs vars);
use utf8;

use CMSBuilder;

sub _props
{
	'mcw_link'=>{'type'=>'object','class'=>'mcwWareBase','name'=>'Свойства'},
#	'name'	=> { 'type' => 'string', 'length' => 100, 'name' => 'Название' },
#	'desc'	=> { 'type' => 'miniword', 'name' => 'Описание' }
}

#———————————————————————————————————————————————————————————————————————————————

1;
