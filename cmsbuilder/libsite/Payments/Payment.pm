package Payment;
use strict qw(subs vars);
use utf8;

our @ISA = qw(CMSBuilder::DBI::Object plgnSite::Member);

sub _cname {'Платеж'}
sub _aview {qw(name customer order status type)}
sub _have_icon {0}

sub _props
{
	name		=> { type => 'string', length => 100, 'name' => 'Название' },
	order		=> { type => 'string', name => 'Заказ' },
	customer	=> { type => 'string', name => 'Покупатель' },
	status		=> { type => 'select', variants => [ {new => 'Не оплачен'}, {pass => 'Оплачен'} ], name => 'Статус платежа' },
	type		=> { type => 'select', variants => [ {cash => 'Наличными курьеру'} ], name => 'Способ оплаты' },
}

#———————————————————————————————————————————————————————————————————————————————

use CMSBuilder;

# sub admin_view
# {
# 	my $o = shift;
# }

sub site_content
{
}

sub initobj
{
	my $o = shift;
	my $sender = shift;
	
	$o->{'order'} = $sender;
	#$o->save();
	modPayments->new(1)->elem_paste($o);
}


1;