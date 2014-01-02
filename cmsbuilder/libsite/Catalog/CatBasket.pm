# (с) Леонов П. А., 2005

package CatBasket;
use strict qw(subs vars);
use utf8;

our @ISA = ('plgnSite::Object','CMSBuilder::DBI::Array');

use CMSBuilder;
use CMSBuilder::Utils;
use CMSBuilder::IO;
use plgnUsers;
use plgnAccess;

sub _cname {'Корзина'}
#sub _aview {qw/name photo desc onpage previewtype/}
#sub _have_icon {1}

sub _add_classes {qw(CatWareHandler)}

sub _props
{
	
}

sub _rpcs {qw(catalog_add_ware catalog_edit_ware catalog_update_basket catalog_delete_from_basket site_catalog_minibasket site_content catalog_basket_checkmail catalog_basket_newpass)}

#———————————————————————————————————————————————————————————————————————————————

sub name {'Корзина'}

sub catalog_delete_from_basket
{
	my $o = shift;
	my $r = shift;
	
	my $url = $r->{url};
	
	my $h = cmsb_url($url);
	return unless $h;
	
	if($o->elem_cut($h->enum))
	{
		$h->del();
		
		if($o->len)
		{
			print
			'
			var e = document.getElementById("row_' . $url . '");
			if ($.browser.msie)
			{
				$("#row_' . $url . ' td *").fadeOut(1000, function() { $(e).remove() } )
			}
			else $(e).animate( { height: 0 }, 500, "linear", function() { $(this).remove() } )
			
			catalog_update_basket(document.getElementById("basket_table"));
			';
		}
		else
		{
			print
			'
			var e = document.getElementById("basket_table");
			var p = e.parentNode;
			p.removeChild(e);
			$(".supernext").empty();
			p.innerHTML = "<div class=\\"message\\">Корзина пуста.</div>"
			';
		}
	}
	else
	{
		print 'alert("Невозможно удалить из корзины товар: ' . $h->{ware}->name . '")';
	}
	
	
}

sub catalog_update_basket
{
	my $o = shift;
	my $r = shift;
	
	my $summ;
	my $count;
	
	for my $h ($o->get_all)
	{
		$h->{count} = $r->{$h->myurl};
		$h->save();
		
		print 'document.getElementById("basket_' . $h->myurl . '_summ").innerHTML = "' . $h->summ . "<span> руб.</span>\";\n";
		
		$summ += $h->summ;
		$count += $h->{count};
	}
	
	print 'document.getElementById("basket_all_summ").innerHTML = ' . $summ . ";\n";
#	print 'document.getElementById("basket_all_count").innerHTML = ' . $count . ";\n";
	#print 'alert("done")';
}

sub site_content
{
	my $o = shift;
	my $r = shift;
#print '<script>$(".catalog").css({display:"none"})</script>';
=head
                        sendmail
                        (
                                'to' => 'sale@evoo.ru',
                                'from' => 'Evoo.Ru <'.$o->root->{'email'}.'>',
                                'subj' => 'Вы_зарегистрировались.на.Evoo.ru',
                                'text' => 'Ваш логин: '."\n".'Ваш пароль: '
                        );
=cut
	if($r->{action} eq 'submit')
	{
		unless ($o->len && $o->elem(1)) { print '<div class="message">Ошибка! Корзина пуста.<div>'; return; }
		
		my $cat_root = $o->elem(1)->{ware}->catalog_root;

		my $orders = $cat_root->{orders};
		unless ($orders) { print '<div class="message">Ошибка! Не найдена папка с заказами.<div>'; return; }
$r->{zak_tel2}=~s/\+7 495 999 99 09//;
$r->{rec_fio}=~s/Имя Фамилия//;
$r->{rec_tel}=~s/\+7 495 999 99 09//;
$r->{addr_tochno}=~s/Как в карте найти можно (с указанием названий улиц и номеров домов)//;
$r->{addr_addinfo}=~s/подъезд, этаж, код, домофон, наземный транспорт и т. д.//;
#$r->{plat_name}=~s/ОАО ВАСЯ ПУПКИН И КО//;
		my %fields=(email=>'E-Mail',
	 delivered_type=>'Способ доставки',
	 zak_fio=>'Заказчик',
	 zak_tel=>'Контактный телефон заказчика',
	 #addr_metro=>'Ближайшее метро',
	 addr_address=>'Адрес доставки',
	 #addr_addinfo=>'Дополнительная информация',

	 #plat_name=>'Наименвоание организации',
	 #plat_inn=>'ИНН',
	 #plat_kpp=>'КПП',
	 #plat_uraddr=>'Юридический адрес'
	,);
my $bad_fields;
foreach my $k(keys %fields){
   if (!$r->{$k}){
      $bad_fields.="'".$fields{$k}."', ";
   }
}
   if ($bad_fields){
      print '<div class="message" style="color:red;font-weight:bold">Ошибка ! Следующие поля не были заполнены: '.substr($bad_fields,0,-2).'</div>';
      return;
   }
			#------------------- регистрируем нового пользователя, если оформил заказ Гость, и заходим сразу под новым пользователем --------------------------
		
		my $myregistration = modRegistration->new(1);
		if($r->{'reg'} eq "1")
		{
                #foreach my $key(keys %{$r}){
                #   next if $key eq 'action';
                #   print $key."|".$r->{$key}."<br>";
                #}
			if(user_classes_sel_one(' login = ? ',$r->{'email'}))
			{
				print
				'
				<div class="message"><span class="head">Ошибка!</span> Пользователь с такой почтой уже существует.</div>
				<p>Система может <a href="',$myregistration->site_href(),'?act=remind&email=',$r->{'email'},'">выслать ключ</a> на этот почтовый ящик. Ключ поможет сменить пароль.</p>
				';
				return;
			}
			my $tu;
			acs_off
			{
				$tu = $myregistration->{'class'}->cre();
				$tu->{'login'} = $tu->{'email'} = $r->{'email'};
				$tu->{'pas'} = genpas();
				$tu->{'tel'} = $r->{'telephone'};
				$tu->save();
				$myregistration->{'group'}->elem_paste($tu);
			};
print "<div class='message'>Для Вас была создана новая учётная запись. Вся необходимая информация отправлена Вам на E-Mail</div><p>";			
			plgnUsers->login($tu->{'login'},$tu->{'pas'});
#print "emails: ".$r->{'email'}."<br>";
$r->{'pass'}=$tu->{'pas'};
#			sendmail
#			(
#				'to' => $r->{'email'},
#				'from' => 'Evoo.Ru <'.$o->root->{'email'}.'>',
#				'subj' => 'Вы.зарегистрировались.на.Evoo.ru',
#				'text' => 'Ваш логин: '.$tu->{'login'}."\n".'Ваш пароль: '.$tu->{'pas'}
#			);
		}
		
		if($r->{'reg'} eq "0")
		{
			if(!plgnUsers->login($r->{'email'},$r->{'pass'}))
			{
				print '<div class="message"><span class="head">Ошибка!</span> ',plgnUsers->last_error(),'</div>';
				return;
			}
		}
		#-------------------
		my $summ;
        	for my $h ($o->get_all){
                   $summ += $h->summ;
        	}
		
		my $order = CatOrder->cre();
		#$order->ochown($user);
		$order->{user} = $user;
		
		if ($user->{orders}) { $user->{orders}->elem_paste($order) };
		map { $o->elem_cut($_->enum); $order->elem_paste($_); } $o->get_all();
		
		acs_off { $orders->elem_paste($order); };
		
		#my ($day,$month,$year)=(localtime())[3,4,5];
		#$year+=1900;
		#$month++;
		my $mess =
		'
		<html>
			<body>
			<h2>Заказ #' . $order->{ID} . '</h2>
			
			
			<p>Дата заказа: '.myNOWhm().'
ФИО клиента: '.$r->{zak_fio}.'<br>
Заказанные товарные позиции:<br>
<br>
' . $order->email_content . '<br>
<br>
Сумма без учёта доставки:'.$summ.'<br>
Адрес доставки: '.$r->{addr_address}.'<br>
'.($r->{addr_addinfo}?'Дополнительно: '.$r->{addr_addinfo}:'').'</p>
			
			<hr/>
			
			<small>Внутренний код заказа: ' . $order->myurl . '</small>
			</body>
		</html>
		';
		for my $email (split /\s+/, $orders->{emails})
		{
			sendmail
			(
				to => $email,
				from => $user->name . ' <' . $user->{'email'} . '>',
				subj => 'Заказ #' . $order->{ID} . ' (' . $user->name . ')',
				text => $mess,
				ct => 'text/html'
			)
			or warn 'Can`t email: ' . $!;
		}
my $del_price=($r->{delivered_type} eq 'courier'?200:500);
                my $mess =
                '
                <html>
                        <body>
                        <h2>Здравствуйте '.$r->{zak_fio}.' !</h2>


                        <p>Компания EVOO.ru благодарит вас за оформление заказа на нашем сайте!<br>
Заказ #'.$order->{ID}.' принят.<br>
Ваш логин - '.$r->{email}.'. Ваш пароль - '.$r->{pass}.'<br>
Вы заказали:<br>
<br>
' . $order->email_content . '<br>
Сумма заказа '.$summ.' руб., доставка '.$del_price.' руб.<br>
Итого: '.($summ+$del_price).' руб.<br>
Способ оплаты: '.($r->{'payment_type'}=~/nal/?'Наличными':'По безналичному расчету').'<br>
Адрес доставки: '.$r->{addr_address}.'<br>
В самое ближайшее время наш менеджер свяжется с вами, чтобы уточнить детали доставки и подтвердить заказ.<br>
Благодарим, за то что воспользовались услугами нашей компании!<br>
Если у вас появятся вопросы или пожелания свяжитесь с нами любым из удобных способов!
</p>

                        <hr/>

<p><small>Тел. +7(495)514-81-22 | <a href="mailto:info@evoo.ru">info@evoo.ru</a> | Icq 22222222 | Mail Agent (<a href="mailto:evoo@mail.ru">evoo@mail.ru</a>) | Gmail (<a href="mailto:evoo.ru@gmail.com">evoo.ru@gmail.com</a>) |Skype e-v-o-o</small></p>
                        </body>
                </html>
                ';
                        sendmail
                        (
                                to => $r->{email},
                                from => 'Evoo.Ru <' . $o->root->{'email'} . '>',
                                subj => 'Заказ #' . $order->{ID},
                                text => $mess,
                                ct => 'text/html'
                        )
                        or warn 'Can`t email: ' . $!;
		#$order->{recipient} = $r->{'recipient'};
		#$order->{recipientaddr} = $r->{'recipientaddr'};
		#$order->{recipientcont} = $r->{'recipientcont'};
		#$order->{recipientdate} = $r->{'recipientdate'};
		#$order->{recipienttime} = $r->{'recipienttime'};
		#$order->{payment}->{type} = $r->{'type'};
		#$order->{payment}->save();
		foreach my $key(keys %{$r}){
		   next if $key=~/action|email|reg|pass/;
		   $order->{$key}=$r->{$key};
	        }
		$order->save();
		
		$user->{'tel'} = $r->{'zak_tel'};
		$user->save();
		
#		print '<script>$("#payment").slideUp(1000)</script>';
		print '<div class="message">Спасибо ! Заказ отправлен на обработку. В ближайшее время мы свяжемся с вами.<div>';
		#$o->del;
		#$order->forms_site_content_begin();
		#$order->{'payment'}->forms_site_content_begin();
		return;
	} #-------------------------------------------------------------------------
	
if ($o->len){
   my $summ;
   print '<div class="steps" id="step1"><div class="block1-1" style="border: 0;">
<div class="block2-7">
<div class="block2-8">
<div class="block1-2">
<div class="block1-3">
<div class="block1-4">
<div class="block1-5">
<div class="block1-6" style="padding: 0;">
<div class="block2-9">
<div class="block2-10">
<div class="block2-11">
<h2><img src="/i/basket/of.png" alt="Оформление заказа" /></h2>
<div class="zakaz-tbl"><table id="basket_table" action="/srpc/'.$o->myurl.
	'/catalog_update_basket" onkeyup="catalog_basket_onkeyup(this)">';
   for my $to ($o->get_all){
      print '      <tr id="row_'.$to->myurl.'">
	 <th>
	    <a href="'.$to->{ware}->site_href.'" class="bsk-price-img">
	    <img src="'.$to->{ware}->{mediumphoto1}->href.'" width="54">
	    <div class="bsk-price-descr">
	       <h4><a href="'.$to->{ware}->site_href.'">'.$to->{ware}->{name}.'</a></h4>
	       <p>'.$to->{ware}->site_props.'</p>
	    </div>
	 </th>
	 <td>
	    <span class="bsk-price-title">Цена</span>
	    <span class="bsk-price"><span style="display:none" id="basket_' . $to->myurl . '_summ"></span>'.$to->{ware}->{price}.' <span>руб</span></span>
	 </td>
	 <td>
	    <span class="bsk-price-kolvo">Кол-во</span>
	    <input type="text" name="'.$to->myurl.'" value="'.$to->{count}.'">
	 </td>
	 <td>
	    <span class="bsk-price-del">Удалить</span>
	    <a href="#" class="bsk-delbutton" title="Удалить" action="/srpc/'.$o->myurl.'/catalog_delete_from_basket" url="'.$to->myurl.'" onclick="catalog_delete_from_basket(this);return false"><img src="/i/basket/del.png" alt="Удалить"></a>
	 </td>
      </tr>';
      $summ+=$to->summ;
   }
   print '</table></div></div></div></div></div></div></div></div></div></div>
</div></div>
<div class="big-button big-button-sel">
   <a href="#" class="supernext">
      <span>
	 <span>Стоимость без учёта доставки: <b><b id="basket_all_summ">'.$summ.'</b> руб.</b>
	 </span>
      </span>
   </a>
</div>
<span id="basket_all_count" style="display:none"></span>
</div>';
=head
<div class="steps" style="display: none;">
<div class="block1-1" style="border: 0;">
<div class="block2-7" style="background: url(i/basket/bg44.jpg) repeat-y right top;">
<div class="block2-8" style="background: url(i/basket/bg4.jpg) no-repeat right top;">
<div class="block1-2">
<div class="block1-3">
<div class="block1-4">
<div class="block1-5">
<div class="block1-6" style="padding: 0;">
<div class="block2-9">
<div class="block2-10" style="background: url(i/basket/rb3.gif) no-repeat right bottom;">
<div class="block2-11" style="background: url(i/basket/lb3.gif) no-repeat left bottom;">
<h2><img src="i/basket/avtr.png" alt="Авторизация" /></h2>
<div class="bsk-email">
   <span>Мой адрес электронной почты</span>
   <input class="bsk-email1" type="text" />
   <input class="bsk-email2" type="image" src="i/basket/gogo.gif" />
</div>
<div class="me-new">
   <div class="me-new-yeah"><label><input type="radio" name="ia" /> Я новый покупатель</label></div>
   <div class="me-lost-pass">
      <label><input type="radio" name="ia" /> Я уже оформлял покупки и зарегистрирован,</label>
      <div>
	 <span class="left">мой пароль</span>
	 <input class="bsk-email1" style="width: 155px;" type="text" disabled="disabled" />
	 <input class="bsk-email2" type="image" src="i/basket/gogo.gif" />
      </div>
   </div>
</div>
<div class="lost-pass">
   <span><a href="#">Я забыл пароль</a></span>
   <input class="bsk-email1" style="width: 110px;" type="text" disabled="disabled" value="Zabil-parol@site.ru" />
   <input class="bsk-email2" type="image" src="i/basket/gogo.gif" />
</div></div></div></div></div></div></div></div></div></div></div></div>
<div class="block4-1">
<div class="block4-2">
<div class="block4-3">
<div class="block4-4">
<div class="block4-5">
<a href="#" class="left superprev"><img src="i/basket/prev.png" alt="" /></a>
<a href="#" class="right supernext"><img src="i/basket/next.png" alt="" /></a>
</div></div></div></div></div></div>

';
=cut
} else {
   print '<div class="message">Корзина пуста.</div>';
}
#print '</div>';
return;	
	print '<div class="catalog-basket">';
	
	if($o->len)
	{
		my $summ;
		my $count;
		
		print
		'
		<table width="100%" id="basket_table" action="/srpc/'. $o->myurl . '/catalog_update_basket" onkeyup="catalog_basket_onkeyup(this)">
		';
		
		for my $to ($o->get_all)
		{
			next unless $to->{ware};
			print #' . (($to->{prop}) ? '<span>' . cmsb_url($to->{prop})->{name} . '</span>' : '') . ' 
			'
			<tr id="row_' . $to->myurl . '" class="basketrow">
				<td>
				<div class="catalog">
										<img alt="" style="left: -1px; top: -1px;" class="cat_corners" src="i/cat-lt.png"/>
										<img alt="" style="right: -1px; top: -1px;" class="cat_corners" src="i/cat-rt.png"/>
										<img alt="" style="left: -1px; bottom: -1px;" class="cat_corners" src="i/cat-lb.png"/>
										<img alt="" style="right: -1px; bottom: -1px;" class="cat_corners" src="i/cat-rb.png"/>
										<h1><a href="' . $to->{ware}->site_href . '">' . $to->{ware}->name . '</a></h1>
										
										<table width="100%" cellspacing="10">
										<tr>
											<td class="basket-photo" width="20%" align="center">
												<a href="' . $to->{ware}->site_href . '"><img src="' . $to->{ware}->{mediumphoto1}->href . '"/></a></td>
											<td class="basket-descr" width="20%">
															<h4><a href="' . $to->{ware}->site_href . '">' . $to->{ware}->name . '</a></h4>
											</td>
											<td width="20%" class="basket-price"><span id="basket_' . $to->myurl . '_summ">' . $to->summ . '<span> руб.</span></span></td>
											<td width="20%" class="basket-number"><input style="font-size: 20px" type="text" size="3" name="' . $to->myurl . '" value="' . $to->{count} . '"/></td>
											<td width="20%" align="center" class="basket-del"><a href="#" action="/srpc/'. $o->myurl . '/catalog_delete_from_basket" url="' . $to->myurl . '" onclick="catalog_delete_from_basket(this); return false;" title="Удалить из корзины">Удалить</td>
										</tr>
										</table>	
											
										</div>
				</div>
				</td>
				
			</tr>
			';
			
			
			$summ += $to->summ;
			$count += $to->{count};
		}
		
		my $newclient = '';
		
		print
		'
		</table>
		<div class="price-block">';
		# print	'<div class="price-confirm"><a title="Подтвердить не регистрируясь" href="#"><img alt="Подтвердить" src="img/confirm-button.png"/></a></div>' if !is_guest($user); #сразу оформляем товар
		print	'<div class="price-confirm"><a class="thickbox" title="Оформить заказ" href="#TB_inline?height=400&width=300&inlineId=regform&modal=true">Сделать заказ</a></div>';
		#показываем форму регистриации
		print	'<div class="count"><span class="itogo">Итого: </span><span id="basket_all_summ" class="digit">' . $summ . '</span><span>&nbsp;руб.</span> (<span id="basket_all_count" class="digit">' . $count . '</span><span>&nbsp;шт.</span>)</div>
		</div>
		';
		
		
		if (is_guest($user))
		{
			$newclient = '
			<div class="pane greenpane">
				<h2>Шаг 1. Информация о Вас</h2>
				<div class="content">
					<div class="check">
						<input type="radio" checked="checked" value="1" name="reg" id="reg" onclick="$(\'div.pass\').hide(500)"/><br/>
						<label for="reg">Это мой первый заказ</label>
					</div>
					<div class="check">
						<input type="radio" value="0" name="reg" id="noreg" onclick="$(\'div.pass\').show(500)"/><br/>
						<label for="noreg">Я уже делал заказ раньше</label>
					</div>
					<div class="email" style="clear:both">
						<p>Введите адрес электронной почты:</p><input class="e-mail" name="email" type="text"/>
					</div>
					<div class="pass">
						<p>Введите пароль:</p><input name="password" type="password"/>
					</div>
					<div class="tel">
						<p style="display:block;width:90%;">Укажите телефон, и можете переходить к шагу №3&nbsp;&mdash; детали заказа уточнит у Вас наш менеджер:</p><input name="telephone" type="text"/>
					</div>
					<br/>
					<span style="cursor: pointer; margin-top: 10px;" onclick="$(\'div.redpane h2\').click()">Следующий шаг</span>
				</div>
				<script>$("div.pass").hide()</script>
			</div>
			
			<div class="pane redpane">
				<h2>Шаг 2. Информация о доставке</h2>
				<div class="content">'
					. CatOrder->site_props($r, qw/recipient recipientaddr recipientcont recipientdate recipienttime/) . '
					<br/>
					<span style="cursor: pointer; margin-top: 10px;" onclick="$(\'div.violetpane h2\').click()">Следующий шаг</span>
				</div>
			</div>
			
			<div class="pane violetpane">
				<h2>Шаг 3. Подтверждение и оплата</h2>
				<div class="content">
					<div id="payment">'
						. Payment->site_props($r, qw/type/) . '<br/>
						<span style="cursor: pointer; margin-top: 10px;" onclick="confirmOrder(\'' . $o->myurl . '\')">Подтвердить</span>
					</div>
				</div>
			</div>
			';
	}
	else
		{
			$newclient = '
			<div class="pane greenpane">
				<h2>Шаг 1. Информация о Вас</h2>
				<div class="content">
					<div class="tel">
						<p style="display:block;width:90%;">Укажите телефон, и можете переходить к шагу №3&nbsp;&mdash; детали заказа уточнит у Вас наш менеджер:</p><input name="telephone" type="text" value="' . $user->{tel} . '"/>
					</div>
					<br/>
                                        <span style="cursor: pointer;margin-top: 10px;" onclick="$(\'div.redpane h2\').click()">Следующий шаг</span>
					<!--<img src="/i/next1.jpeg" style="cursor: pointer; margin-top: 10px;" onclick="$(\'div.redpane h2\').click()"/>-->
				</div>
				<script>$("div.pass").hide()</script>
			</div>
			
			<div class="pane redpane">
				<h2>Шаг 2. Информация о доставке</h2>
				<div class="content">'
					. CatOrder->site_props($r, qw/recipient recipientaddr recipientcont recipientdate recipienttime/) . '
					<br/>
                                        <span style="cursor: pointer;margin-top: 10px;" onclick="$(\'div.violetpane h2\').click()">Следующий шаг</span>
					<!--<img src="/i/next2.jpeg" style="cursor: pointer; margin-top: 10px;" onclick="$(\'div.violetpane h2\').click()"/>-->
				</div>
			</div>
			
			<div class="pane violetpane">
				<h2>Шаг 3. Подтверждение и оплата</h2>
				<div class="content">
					<div id="payment">'
						. Payment->site_props($r, qw/type/) . '<br/>
                                                <span style="cursor: pointer;margin-top: 10px;" onclick="confirmOrder(\'' . $o->myurl . '\')">Подтвердить</span>
						<!--<img src="/i/pod.jpg" style="cursor: pointer; margin-top: 10px;" onclick="confirmOrder(\'' . $o->myurl . '\')"/>-->
					</div>
				</div>
			</div>
			';
	}
		
		print '<div id="regform" style="display:none;"><form class="basket-submit-form" action="' . $o->site_href . '">
			' . $newclient . '
			<input type="hidden" name="action" value="submit"/>
		</form></div>';
	}
	else
	{
		print '<div class="message">Корзина пуста.</div>';
	}
	
	print '</div>';
	
	return;
}

sub site_navigation { $_[0]->name; }

sub catalog_add_ware
{
	my $o = shift;
	my $r = shift;
	
	my $to = cmsb_url($r->{ware});
	my $mp = cmsb_url($r->{prop});
	
	return unless $to;
	
	my $hnd = $o->search_ware_handler($to);
	
	if ($hnd)
	{
		$hnd->{count}++;
		$hnd->{price} = $mp ? $mp->{value} : $to->{price};
		$hnd->{prop} = $mp->myurl if $mp;
		$hnd->save();
	}
	else
	{
		$o->elem_paste($to->ware_handler($mp));
	}
	
	$o->site_catalog_minibasket($r, type => 'add');
}

sub catalog_edit_ware
{
	my $o = shift;
	my $r = shift;
	
	my $to = cmsb_url($r->{ware});
	my $mp = cmsb_url($r->{prop});
	
	return unless $to;
	
	my $hnd = $o->search_ware_handler($to);
	
	if ($hnd)
	{
		$hnd->{price} = $mp ? $mp->{value} : $to->{price};
		$hnd->{prop} = $mp->myurl if $mp;
		$hnd->save();
	}
	
	$o->site_catalog_minibasket($r, type => 'add');
}

sub site_catalog_html
{
	my $o = shift;
	my $r = shift;

	print '<div id="catalog_mini_basket" action="/srpc/'. $o->myurl . '/site_catalog_minibasket">';
	
	$o->site_catalog_minibasket($r);
	
	print '</div>';
}

sub search_ware_handler
{
	my $o = shift;
	my $ware = shift;

	$ware = cmsb_url($ware) || $ware;
	
	return undef unless $ware;
	
	map { return $_ if $_->{ware}->myurl eq $ware->myurl } $o->get_all;
	
	return undef;
}


sub genpas
{
	srand;
	return substr(MD5(rand().{}.rand()),0,9)
}


sub site_catalog_minibasket
{
	my $o = shift;
	my $r = shift;
return if $r->{action} eq 'submit';	
	my $pt = {@_};
	print '<h5 style="margin: 0pt 0pt 6px; padding: 0pt 0pt 5px 10px; background: transparent url(/i/basket/sep.png) no-repeat scroll center bottom; font-size: 16px; font-weight: normal; color: rgb(51, 178, 226); -moz-background-clip: -moz-initial; -moz-background-origin: -moz-initial; -moz-background-inline-policy: -moz-initial;">В корзине</h5>';
	if($o->len)
	{
		my $summ;
		my $count;
		my $tmp;
		for my $to ($o->get_all)
		{
		   $tmp=$to->summ;
		   $tmp=substr($tmp,0,-3).' '.substr($tmp,-3) if length $tmp>3;
		   print '<div style="border-bottom: 1px dotted rgb(153, 153, 153); padding: 5px 0pt 5px 10px; color: rgb(51, 51, 51);">
				<a style="text-decoration: none; color: rgb(0, 0, 0);" href="'.$to->{ware}->site_href.'">'.$to->{ware}->name.'</a>
						<span style="display: block; color: rgb(117, 117, 117);">Кол-во: '.$to->{count}.'</span>
						<b style="color: rgb(8, 118, 175);">'.$tmp.' руб </b>
					</div>';

#			print '<div class="mini-ware">' . $to->{ware}->site_basket_view_img($to) . '</div>'; #&nbsp;(' . $to->{count} . ')
			$summ += $to->summ;
			$count += $to->{count};
		}
                $summ=substr($summ,0,-3).' '.substr($summ,-3) if length $summ>3;
		print '					<div style="font-size: 14px; background: url(/i/basket/sep.png) no-repeat center top; padding: 6px 0 12px 10px; color: #333;">
						На сумму     	<span style="color: #0876af;">'.$summ.' руб </span>
					</div>';
		print '					<div style="text-align: center;">
						<a href="'.$o->site_href.'"><img src="/i/basket/change.png" alt="" /></a>
					</div>&nbsp;';
#		print '<p><a class="baskethref" href="' . $o->site_href . '">' . $count . '&nbsp;' . rus_case($count, ['товаров', 'товар', 'товара', 'товаров']) . ', на&nbsp;сумму:&nbsp;' . $summ . '&nbsp;руб. (посмотреть детали заказа)</a></p>';
		
		
	}
	else
	{
	#	print 'пусто.';
	}

	
}

sub catalog_basket_checkmail{
   my $o=shift;
   my $r=shift;
   my $result=0;
   my $res;
   my $str=$CMSBuilder::DBI::dbh->prepare('SELECT ID from dbo_Client where email=?');
   $str->execute($r->{'email'});
   if ($res=$str->fetchrow_array()){
      $result=1;
   }
   print 'document.forms[1].reg[1].checked=1;$(".bsk-email span").css({color:"black"});show_pass_input()' if $result;
}

sub catalog_basket_newpass{
   my $o=shift;
   my $r=shift;
   my $tu;
   acs_off { $tu = user_classes_sel_one(' login = ? ',$r->{'email'}) };

   unless($tu)
     {
        print 'Такого E-Mail нет';
        return;
     }

     srand;
     my $key = MD5($r->{'email'}.rand().[]);
     $tu->{'remind'} = $key;
     acs_off { $tu->save() };
$r->{email}=~/^(.*?)\@/;
                my $mess =
                '
                <html>
                        <body>
                        <h2>Здравствуйте, '.$1.' !</h2>


                        <p>Вы получили это письмо, потому что кто то, скорее всего Вы, указали этот адрес электронной почты в качестве зарегистрированного логина в интернет-магазине <a href="http://evoo.ru">EVOO.ru</a></p>

			<p>Для восстановления пароля пройдите по ссылке: '.
	"<a href='".modRegistration->new(1)->site_abs_href().'?act=remind&key='.$key."'>".modRegistration->new(1)->site_abs_href().'?act=remind&key='.$key.'</a></p>

                        <hr/>

                        <small>Если у вас появятся вопросы или пожелания свяжитесь с нами любым из удобных способов:</small>
<p><small>Тел. +7(495)514-81-22 | <a href="mailto:info@evoo.ru">info@evoo.ru</a> | Icq 22222222 | Mail Agent (<a href="mailto:evoo@mail.ru">evoo@mail.ru</a>) | Gmail (<a 
	href="mailto:evoo.ru@gmail.com">evoo.ru@gmail.com</a>) | Skype e-v-o-o</small></p>
                        </body>
                </html>
                ';
     sendmail
        (  
                      'to' => $r->{'email'},
                        'from' => 'Evoo.Ru <info@evoo.ru>',
			'subj' => 'Восстановление пароля на EVOO.ru',
			'text' => $mess,
#                        'text' => 'Здравствуйте ,'
#'Перейдите по ссылке для смены пароля: '
#.modRegistration->new(1)->site_abs_href().'?act=remind&key='.$key
			'ct' => 'text/html'
        		);
# or print 'Ошибка сервера';

   print 'Смотрите почту';
}

1;
