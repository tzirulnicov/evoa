# (с) Леонов П.А., 2005

package Client;
use strict qw(subs vars);
use utf8;

our @ISA = qw(plgnForms::Interface plgnUsers::UserMember CMSBuilder::DBI::Object);

sub _cname {'Клиент'}
sub _aview
{qw/
 login pas
 basket orders
 email
 fam name second bdate
 country city address building zip tel
/}

sub _sview
{qw/
 email
 fam name second bdate
 country city address  zip tel
/}

sub _props
{
	basket		=> { type => 'object', class => 'CatBasket', name => 'Корзина' },
	orders		=> { type => 'object', class => 'CatUserOrders', name => 'Заказы' },
	email		=> { type => 'string', name => 'E-mail', require => 1 },
	fam		=> { type => 'string', name => 'Фамилия', require => 1 },
	name		=> { type => 'string', name => 'Имя', require => 1 },
	second		=> { type => 'string', name => 'Отчество' },
	bdate		=> { type => 'string', check => qr/\d\d.\d\d.\d\d\d\d/, name => 'Дата&nbsp;рождения' },
	country		=> { type => 'string', name => 'Страна' },
	city		=> { type => 'string', name => 'Город' },
	address		=> { type => 'string', name => 'Адрес' },
	zip		=> { type => 'string', name => 'Почтовый&nbsp;индекс' },
	tel		=> { type => 'string', name => 'Телефон', require => 1 }
}

#———————————————————————————————————————————————————————————————————————————————


use plgnUsers;
use CMSBuilder::Utils;

sub site_navigation { $_[0]->name; }

sub email_content
{
	my $o = shift;
	
	my $p = $o->props;
	
	return
	'
	<table border="1" cellspacing="0" cellpadding="5">
		<caption><a href="' . $o->admin_abs_href . '">' . $o->name . '</a></caption>
		<tr>
		' . join('</tr><tr>', map { '<th>' . $p->{$_}->{name} . '</th><td>' . $o->{$_} . '</td>' } grep {$o->{$_}} $o->sview) . '
		</tr>
	</table>';
}

sub site_content
{
	my $o = shift;
	my $r = shift;
	
	if($o->access('r'))
	{
		print parsetpl
		'
		Имя: ${name}<br/>
		Дата регистрации: ${date}<br/>
		'
		,{%$o,'date'=>$o->site_cdate()};
	}
}

sub name
{
	my $o = shift;
	
	return $o->{name} || $o->{login} || $o->{email} if $o->access('w');
	return $o->SUPER::name;
}

sub access
{
	my $o = shift;
	my $type = shift;
	
	return 1 if $type eq 'w' && $user->myurl eq $o->myurl;
	
	return $o->SUPER::access($type,@_);
}

1;