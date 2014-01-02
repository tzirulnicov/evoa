# (с) Леонов П. А., 2005

package CatOrder;
use strict qw(subs vars);
use utf8;

our @ISA = qw(plgnForms::Interface plgnSite::Object CMSBuilder::DBI::Array);

use CMSBuilder;
use CMSBuilder::Utils;

sub _cname {'Заказ'}
#sub _aview {qw/user disp status payment recipient recipientaddr recipientcont recipientdate recipienttime/}
sub aview {qw/user disp status delivered_type delivered_another_face zak_fio zak_tel rec_fio rec_tel addr_metro addr_address addr_mkad addr_tochno addr_addinfo payment_type plat_zak plat_rec plat_addr plat_addr2 plat_eladdr plat_name plat_inn plat_kpp plat_bik plat_rschet plat_bank plat_uraddr/}
sub _sview{qw/delivered_type delivered_another_face zak_fio zak_tel rec_fio rec_tel addr_metro addr_address addr_mkad addr_tochno addr_addinfo payment_type plat_zak plat_rec plat_addr plat_addr2 plat_eladdr plat_name plat_inn plat_kpp plat_bik plat_rschet plat_bank  plat_uraddr/}
#sub _sview
#{qw/
# status
# recipient
# recipientaddr
# recipientcont
# recipientdate
# recipienttime
#/}


#sub _have_icon {1}

sub _add_classes {qw(CatWareHandler)}

sub _props
{
	user		=> { type => 'shcut', name => 'Заказчик' },
	disp		=> { type => 'shcut', name => 'Диспетчер' },
	status		=> { type => 'select', variants => [ {new => 'Новый'}, {active => 'В обработке'}, {archive => 'В архиве'} ], name => 'Статус' },
	payment		=> { type => 'object', class => 'Payment', name => 'Оплата' },
	recipient		=> { type => 'string', name => 'ФИО получателя' },
	recipientaddr	=> { type => 'string', name => 'Адрес получателя' },
	recipientcont	=> { type => 'string', name => 'Контакты получателя' },
	recipientdate	=> { type => 'date', name => 'Дата доставки' },
	recipienttime	=> { type => 'select', variants => [ {per1 => '00:00 — 07:00'}, {per2 => '07:00 — 10:00'}, {per3 => '09:00 — 13:30'}, {per4 => '10:00 — 19:00'}, {per5 => '12:30 — 15:00'}, {per6 => '15:00 — 17:30'}, {per7 => '19:00 — 22:00'}, {per8 => '21:00 — 24:00'} ], name => 'Желаемое время доставки' },

	delivered_type => { type => 'select', variants => [ {courier=>'Курьером по Москве'},
		{courier_express=>'Экспресс курьером по Москве'},
		{courier_mo=>'Курьером по Московской области'},
		#{posylka_mo=>'Посылкой по Московской области'},
		{posylka_russia=>'Посылкой по России'} ],name=>'Способ доставки' },
	delivered_another_face => { type => 'bool', name => 'Доставка другому лицу' },

	zak_fio => { type=>'string',name=>'ФИО заказчика'},
	zak_tel => {type=>'string',name=>'Телефон заказчика'},
	zak_tel2 => {type=>'string',name=>'Дополнительный телефон'},
	rec_fio => {type=>'string',name=>'ФИО получателя'},
	rec_tel => {type=>'string',name=>'Телефон получателя'},

	addr_metro =>{type=>'string',name=>'Ближайшее метро'},
	addr_mkad =>{type=>'string',name=>'Удаление от МКАД'},
	addr_tochno=>{type=>'string',name=>'Точный адрес доставки'},
	addr_address=>{type=>'string',name=>'Адрес доставки'},
	addr_addinfo=>{type=>'string',name=>'Дополнительная информация по адресу'},

	payment_type=>{type=>'select',variants=>[{nal=>'Наличными, оплата курьером при получении заказа'},
		{nal2=>'Наличными, 1 курьер за деньгами, другой с товаром'},
		{beznal=>'По безналу для физ. лиц банковским способом'},
		{beznal2=>'По безналу для юридических лиц'},
		{beznal3=>'По безналу кредитными картами'},
		#{electr=>'Электронными деньгами'}
	],name=>'Оплата'},

	plat_zak=>{type=>'string',name=>'ФИО плательщика'},
	plat_rec=>{type=>'string',name=>'Получатель'},
	plat_addr=>{type=>'string',name=>'Адрес доставки'},
	plat_addr2=>{type=>'string',name=>'Адрес плательщика'},
	plat_eladdr=>{type=>'string',name=>'Электронный адрес для выставления счёта'},
	plat_name=>{type=>'string',name=>'Наименование организации'},
	plat_inn=>{type=>'string',name=>'ИНН организации'},
	plat_kpp=>{type=>'string',name=>'КПП организации'},
        plat_bik=>{type=>'string',name=>'БИК организации'},
	plat_bank=>{type=>'string',name=>'Наименование банка'},
	plat_uraddr=>{type=>'string',name=>'Юридический адрес'},
}
sub _rpcs {qw/site_content/}

#———————————————————————————————————————————————————————————————————————————————

sub name { toDateTimeStr($_[0]->{CTS}) . ', заказ #' . $_[0]->{ID} . ', сумма: ' . $_[0]->summ }

sub summ
{
	my $o = shift;
	
	my $summ;
	map { $summ += $_->summ; } $o->get_all;
	
	$summ || 0;
}

sub email_content
{
	my $o = shift;
	
	return catch_out
	{
		my $summ;
		my $count;
=head		
		print
		'
		<table border="1" cellspacing="0" cellpadding="5">
			<caption><a href="' . $o->admin_abs_href . '">' . $o->name . '</a></caption>
			<tr>
				<th>Товар</th>
				<th>Цена</th>
				<th>Количество</th>
				<th>Сумма</th>
			</tr>
		';
=cut
		for my $to ($o->get_all)
		{
print $to->{ware}->{name}.' - '.$to->{ware}->{price}.' руб.<br>
';
=head
			print
			'
			<tr>
				<td>' . $to->{ware}->name . '</td>
				<td>' . $to->{ware}->{price} . '&nbsp;у.е.</td>
				<td>' . $to->{count} . '</td>
				<td>' . $to->summ . '&nbsp;у.е.</td>
			</tr>
			';		
			$summ += $to->summ;
			$count += $to->{count};
=cut
		}
=head
		print
		'
			<tr><td colspan="4" style="border:none"></td></tr>
			<tr>
				<th colspan="2">Итого:</th>
				<td class="count"><span id="basket_all_count">' . $count . '</span>&nbsp;шт.</th>
				<td class="summ"><span id="basket_all_summ">' . $summ . '</span>&nbsp;у.е.</td>
			</tr>
		</table>
		';
=cut
	};
}

sub site_preview
{
	my $o = shift;
	my $r = shift;
	
	return if ref($user) eq 'Client';
	#return if is_guest($user);
	
	if (!$o->{disp})
	{
		print '<form action="' . $o->site_href . '">
			' . $o->site_aname . '
			<input type="hidden" name="disp" value="' . $user->myurl . '"/>
			<button type="submit">Принять в обработку</button>
		</form>';
		return;
	}
	
	print '<li>' . $o->site_aname . '</li>' if $o->{disp}->myurl eq $user->myurl;
}

sub site_content
{
	my $o = shift;
	my $r = shift;
	
	if ($r->{'disp'})
	{
		$o->{disp} = cmsb_url($r->{'disp'});
		$o->{status} = 'active';
		$o->save;
	}
	
	print '<div id="order" class="ui-accordion-container">
		<div>
			<div class="ui-accordion-left"></div>
			<a href="#" class="ui-accordion-divnk">
				Получатель
				<div class="ui-accordion-right"></div>
			</a>
			<div>
				'; $o->site_props($r, qw/recipient recipientaddr recipientcont recipientdate/);
	print		'</div>

		</div>
		<div>
			<div class="ui-accordion-left"></div>
			<a href="#" class="ui-accordion-divnk">
				Специальные возможности
				<div class="ui-accordion-right"></div>
			</a>
			<div>Lorem ipsum dolor sit amet, consectetur adipisicing edivt, sed do eiusmod tempor incididunt ut labore et dolore magna adivqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut adivquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate vedivt esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt moldivt anim id est laborum.
			</div>
		</div>
		<div>
			<div class="ui-accordion-left"></div>
			<a href="#" class="ui-accordion-divnk">
				Оплата
				<div class="ui-accordion-right"></div>
			</a>
			<div>';
			if ($o->{'payment'}->{'status'} eq 'new')
			{
				print '<form method="POST" action="https://merchant.webmoney.ru/lmi/payment.asp">
					<input type="hidden" name="LMI_PAYMENT_AMOUNT" value="' . $o->summ . '">
					<input type="hidden" name="LMI_PAYMENT_DESC" value="Order">
					<input type="hidden" name="LMI_PAYMENT_NO" value="' . $o->{'ID'} . '">
					<input type="hidden" name="LMI_PAYEE_PURSE" value="' . $o->{'payment'}->papa()->{'wmpurse'} . '">
					<input type="hidden" name="LMI_SIM_MODE" value="0">
					<input type="hidden" name="type" value="webmoney">
					<input type="hidden" name="order" value="' . $o->myurl . '">
					<input type="hidden" name="payment" value="' . $o->{'payment'}->myurl . '">
					<input type="submit" value="Оплатить через WebMoney">
				</form>';
			}
	print	'</div>
		</div>
	</div>';
	
	#$o->forms_site_content_begin();
	#$o->{user}->forms_site_content_begin();

	return; 
}


sub order_preview_by_client
{
	my $o = shift;
	my $r = shift;
	
	return '<li><a href="#" onclick="orderClickFromBasket(\'' . $o->myurl . '\'); return;">' . $o->site_name . '</a></li>';
}



1;
