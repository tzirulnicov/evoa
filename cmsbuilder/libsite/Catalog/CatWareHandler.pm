# (с) Леонов П.А., 2005

package CatWareHandler;
use strict qw(subs vars);
use utf8;

our @ISA = qw(plgnSite::Object CMSBuilder::DBI::Object);

sub _aview {qw(ware count price prop)}
sub _have_icon {'icons/CatWare.gif'}

sub _cname {'Дескриптор товара'}

sub _props
{
	'ware'		=> { 'type' => 'shcut', 'name' => 'Товар' },
	'count'		=> { 'type' => 'int', 'name' => 'Количество единиц товара' },
	'price'		=> { 'type' => 'int', 'name' => 'Стоимость единицы товара' },
	'prop'		=> { 'type' => 'string', 'name' => 'Свойство товара' },
}

#———————————————————————————————————————————————————————————————————————————————


sub ware { $_[0]->{ware} }

sub count { $_[0]->{count} }

sub summ { $_[0]->{count} * $_[0]->{price} } #$_[0]->{price} ? $_[0]->{price} : $_[0]->{ware}->{price} }

sub name { $_[0]->{ware}->name . ' (' . $_[0]->{count} . ')' }


1;