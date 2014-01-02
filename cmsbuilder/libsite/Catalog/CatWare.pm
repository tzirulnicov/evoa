# (с) Леонов П.А., 2005

package plgnCatalog::Ware;
use strict qw(subs vars);
use utf8;
use Encode;
use CGI;

our @ISA = qw(plgnCatalog::Member MultiProps Comments);# mcwWareLink

use plgnUsers;
use CMSBuilder;
use CMSBuilder::IO;
use CMSBuilder::Utils;
use Switch;
sub _add_classes{qw/mcwWareBase/}

sub _aview {qw/name photo photobig2 photobig3 photosmall price artikul exportto insight sostav desc mcw_select/;}

sub _main {qw/smartphone gsm900 gsm1800 gsm1900 wcdma optstandart os platform type opttype ant optfeature year/}

sub _camera {qw/camera photorec cameraob camerazoom cameralight videorec secondvideo/}

sub _multi {qw/stereo radio mp3 aplayback optaudio voicerec java games/}

sub _memory {qw/memory cards/}

sub _screen {qw/screentype screensize screenrus screenlight/}

sub _interface {qw/irda usb wifi blue1 blue2 optinterface wap gprs edge optinternet modem gps pcconnect/}

sub _calls {qw/melodytype vibrocall melodyedit melodyspeaker melodymute coding/}

sub _org {qw/orgclock orgcalc orgcal orgoffice realplayer flashplayer lifeblog orgchat orgkeys orgsec orgconv bud/}


sub _mess {qw/sms mms email/}

sub _power {qw/powertype powersize powerwait powertime/}

sub _sizes{qw/dims weight/}

sub _sostav{qw/sostav/}

sub _callcontrol{qw/uder conf pere opred/}

sub _keybrd{qw/joy keylight keyblock keysound t9 keyrus/}

sub _dop{qw/dop/}

sub _yandex{qw/bid cbid/}


sub _all {qw/name photo photobig2 photobig3 price artikul insight sostav desc smartphone gsm900 gsm1800 gsm1900 wcdma optstandart os platform type opttype ant optfeature year camera photorec cameraob camerazoom cameralight videorec secondvideo stereo radio mp3 aplayback optaudio voicerec java games memory cards screentype screensize screenrus screenlight irda usb wifi blue1 blue2 optinterface wap gprs edge optinternet modem gps pcconnect melodytype vibrocall melodyedit melodyspeaker melodymute orgclock orgcalc orgcal orgoffice realplayer flashplayer lifeblog orgchat orgkeys sms mms email powertype powersize powerwait powertime dims weight template hidden title my4 tag description usetime start end uder conf pere opred coding joy keylight keyblock keysound t9 keyrus orgsec orgconv dop bud exportto bid cbid mcw_id mcw_select/}

sub _have_icon {'icons/CatWare.gif'}

sub _props
{
	joy			=> { type => 'bool', name => 'Джойстик' },
	keylight			=> { type => 'bool', name => 'Подсветка' },
	keyblock			=> { type => 'bool', name => 'Блокировка' },
	keysound			=> { type => 'bool', name => 'Звуковая индикация' },
	keyrus			=> { type => 'bool', name => 'Ввод русскими буквами' },
	uder			=> { type => 'bool', name => 'Удержание звонка' },
	conf			=> { type => 'bool', name => 'Конференц-связь' },
	pere			=> { type => 'bool', name => 'Переадресация звонка' },
	opred			=> { type => 'bool', name => 'Определение номера' },
	orgsec			=> { type => 'bool', name => 'Секундомер' },
	orgconv			=> { type => 'bool', name => 'Конвертер валют' },
	exportto		=> { type => 'ExportTo', name => 'В списках XML'},
#my field (c) tz
	photosmall		=> { type => 'img', name => 'Превьюшка' },
	photosmallest		=> { type => 'sizedimg', 'for'=> 'photosmall', size => '140x*', 'quality' => 8, 'format' => 'jpeg'},
	photosmallest2		=> { type => 'img', name => 'field for bot'},
	photobig2		=> { 'type' => 'img', 'msize' => 10000, 'name' => 'Большая дополнительная фотография' },
	photobig3		=> { 'type' => 'img', 'msize' => 10000, 'name' => 'Большая дополнительная фотография' },
	photobig4		=> { 'type' => 'img', 'msize' => 10000, 'name' => 'Большая дополнительная фотография' },
	photobig5		=> { 'type' => 'img', 'msize' => 10000, 'name' => 'Большая дополнительная фотография' },
	photobig6		=> { 'type' => 'img', 'msize' => 10000, 'name' => 'Большая дополнительная фотография' },
	photobig7		=> { 'type' => 'img', 'msize' => 10000, 'name' => 'Большая дополнительная фотография' },
	photobig8		=> { 'type' => 'img', 'msize' => 10000, 'name' => 'Большая дополнительная фотография' },
	photobig9		=> { 'type' => 'img', 'msize' => 10000, 'name' => 'Большая дополнительная фотография' },
	photobig10		=> { 'type' => 'img', 'msize' => 10000, 'name' => 'Большая дополнительная фотография' },
	mediumphoto1		=> { 'type' => 'sizedimg', 'for' => 'photo', 'size' => '*x170', 'quality' => 8, 'format' => 'jpeg'},
	smallphoto1		=> { 'type' => 'sizedimg', 'for' => 'photo', 'size' => '*x51', 'quality' => 8, 'format' => 'jpeg'},
	smallphoto2		=> { 'type' => 'sizedimg', 'for' => 'photobig2', 'size' => '*x51', 'quality' => 8, 'format' => 'jpeg'},
	smallphoto3		=> { 'type' => 'sizedimg', 'for' => 'photobig3', 'size' => '*x51', 'quality' => 8, 'format' => 'jpeg'},
	smallphoto4		=> { 'type' => 'sizedimg', 'for' => 'photobig3', 'size' => '*x51', 'quality' => 8, 'format' => 'jpeg'},
	smallphoto5		=> { 'type' => 'sizedimg', 'for' => 'photobig3', 'size' => '*x51', 'quality' => 8, 'format' => 'jpeg'},
	smallphoto6		=> { 'type' => 'sizedimg', 'for' => 'photobig3', 'size' => '*x51', 'quality' => 8, 'format' => 'jpeg'},
	smallphoto7		=> { 'type' => 'sizedimg', 'for' => 'photobig3', 'size' => '*x51', 'quality' => 8, 'format' => 'jpeg'},
	smallphoto8		=> { 'type' => 'sizedimg', 'for' => 'photobig3', 'size' => '*x51', 'quality' => 8, 'format' => 'jpeg'},
	smallphoto9		=> { 'type' => 'sizedimg', 'for' => 'photobig3', 'size' => '*x51', 'quality' => 8, 'format' => 'jpeg'},
	smallphoto10		=> { 'type' => 'sizedimg', 'for' => 'photobig3', 'size' => '*x51', 'quality' => 8, 'format' => 'jpeg'},
	price			=> { type => 'int', name => 'Цена' },
	insight			=> { type => 'bool', default => 1, name => 'В продаже' },
	artikul			=> { type => 'string', name => 'Артикул' },
	smartphone		=> { type => 'bool', default => 0, name => 'Смартфон' },
	gsm900			=> { type => 'bool', name => 'GSM 900' },
	gsm1800			=> { type => 'bool', name => 'GSM 1800' },
	gsm1900			=> { type => 'bool', name => 'GSM 1900' },
	bud			=> { type => 'bool', name => 'Будильник' },
	wcdma			=> { type => 'bool', name => 'WCDMA' },
	optstandart		=> { type => 'string', name => 'Дополнительный стандарт' },
	year			=> { type => 'string', name => 'Год выпуска' },
	os				=> { type => 'string', name => 'Операционная система' },
	platform		=> { type => 'string', name => 'Платформа' },	
	type			=> { type => 'select', variants => [ {'Раскладушка' => 'Раскладушка'}, {'Моноблок' => 'Моноблок'}, {'Слайдер' => 'Слайдер'}, {'0' => 'Другое'} ], name => 'Тип корпуса' },
	opttype			=> { type => 'string', name => 'Тип корпуса' },
	ant				=> { type => 'bool', default => 1, name => 'Встроенная антенна' },
	optfeature		=> { type => 'string', name => 'Дополнительная характеристика' },
	camera			=> { type => 'string', name => 'Камера, МПикс' },
	photorec		=> { type => 'string', name => 'Запись изображения до, пикселей' },
	cameraob		=> { type => 'string', name => 'Объектив' },
	camerazoom		=> { type => 'string', name => 'Цифровой zoom' },
	cameralight		=> { type => 'bool', default => 0, name => 'Встроенная вспышка' },
	videorec		=> { type => 'string', name => 'Видеокамера' },
	secondvideo		=> { type => 'bool', default => 0, name => 'Вторая камера для видеотелефонии' },	
	stereo			=> { type => 'bool', default => 0, name => 'Стереодинамики' },
	radio			=> { type => 'bool', name => 'FM-приемник' },	
	mp3			=> { type => 'bool', name => 'MP3-проигрыватель' },	
	aplayback		=> { type => 'string', name => 'Чтение аудиоформатов' },
	optaudio		=> { type => 'string', name => 'Нестандартная аудио-характеристика' },
	voicerec		=> { type => 'bool', name => 'Диктофон' },
	java			=> { type => 'bool', name => 'JAVA' },
	games			=> { type => 'string', name => 'Игры' },
	memory			=> { type => 'string', name => 'Втроенная память, Мб' },
	cards			=> { type => 'string', name => 'Слот для карт памяти' },
	screentype		=> { type => 'string', name => 'Тип экрана' },
	screensize		=> { type => 'string', name => 'Размер экрана' },
	screenrus		=> { type => 'bool', name => 'Руссификация' },
	screenlight		=> { type => 'bool', name => 'Подсветка экрана' },
	irda			=> { type => 'bool', name => 'Инфракрасный порт' },
	usb				=> { type => 'bool', name => 'USB' },
	wifi			=> { type => 'bool', name => 'WiFi' },
	blue1			=> { type => 'bool', name => 'Bluetooth 1.0' },
	blue2			=> { type => 'bool', name => 'Bluetooth 2.0' },
	optinterface	=> { type => 'string', name => 'Дополнительный интерфейс' },
	wap				=> { type => 'bool', name => 'WAP 2.0' },
	gprs			=> { type => 'bool', name => 'GPRS' },
	edge			=> { type => 'bool', name => 'EDGE' },
	optinternet	=> { type => 'string', name => 'Дополнительный доступ в интернет' },
	modem			=> { type => 'bool', name => 'Модем' },
	gps				=> { type => 'bool', name => 'GPS-приемник' },
	pcconnect		=> { type => 'bool', name => 'Подключение к ПК' },
	melodytype		=> { type => 'string', name => 'Тип мелодий' },
	vibrocall		=> { type => 'bool', name => 'Виброзвонок' },
	melodyedit		=> { type => 'bool', name => 'Редактор мелодий' },
	coding		=> { type => 'bool', name => 'Кодирование речи' },
	melodyspeaker	=> { type => 'bool', name => 'Динамик для громкого звука' },
	melodymute	=> { type => 'bool', name => 'Бесшумный вызов' },
	orgclock		=> { type => 'bool', name => 'Часы' },
	orgcalc			=> { type => 'bool', name => 'Калькулятор' },
	orgcal			=> { type => 'bool', name => 'Календарь' },
	orgoffice		=> { type => 'bool', name => 'Офис' },
	realplayer		=> { type => 'bool', name => 'Realplayer' },
	flashplayer		=> { type => 'bool', name => 'Flash-проигрыватель' },
	lifeblog		=> { type => 'bool', name => 'Lifeblog' },
	orgchat			=> { type => 'bool', name => 'Чат' },
	orgkeys			=> { type => 'bool', name => 'Ключи' },	
	t9				=> { type => 'bool', name => 'Предиктивный ввод текста Т9' },
	sms				=> { type => 'bool', name => 'SMS' },
	mms				=> { type => 'bool', name => 'MMS' },
	email			=> { type => 'bool', name => 'E-mail' },	
	powertype		=> { type => 'string', name => 'Тип аккумулятора' },
	powersize		=> { type => 'string', name => 'Емкость аккумулятора, мАч' },
	powerwait		=> { type => 'string', name => 'Время ожидания до, часов' },
	powertime		=> { type => 'string', name => 'Время разговора до, часов' },
	dims			=> { type => 'string', name => 'Размеры, мм' },
	weight			=> { type => 'string', name => 'Вес, г' },
	sostav			=> { type => 'miniword', name => 'Комплектация' },
	dop				=> { type => 'miniword', name => 'Дополнительный функционал' },
	bid				=> { type => 'int', name => 'Яндекс.Маркет Bid' },
	cbid			=> { type => 'int', name => 'Яндекс.Маркет CBid' },
	mcw_id		=> {type=>'int',name=>'Шаблон'},
	mcw_select	=> {type=>'McwSelect',name=>'Шаблон категории'}
}

sub _template_export {qw(site_title site_buy_button site_papa_url site_basket_url site_basket_step1)}

sub _rpcs {qw(catalog_add_to_comp ajaxsave)}

#———————————————————————————————————————————————————————————————————————————————

sub checked
{
	my $o = shift;
	my $tag = shift;

	map { return 'checked' if $_->myurl eq $tag } @{$o->{exportto}};
	return;
}

sub ajaxsave
{
	my $o = shift;
	my $r = shift;
	
	unless ($r->{notags})
	{
		my @stags;
	
		my @alltags = modMarket->new(1)->get_all();
		map { push @stags, $_ if $r->{$_->myurl} } @alltags;

		map { $_->elem_relation_del($o,'tag') } @alltags;
	
		for (@stags)
		{
			my ($tag) = ExportList->find('name = ?', $_->name);
			if ($tag)
			{
				$tag->elem_relation_paste_ref($o,'tag');
			}
		}
	
		$o->{exportto} = [@stags];
	}
	$o->{price} = $r->{price};
	$o->{bid} = $r->{bid};
	$o->{cbid} = $r->{cbid};
	$o->save();
	print $o->name . ': сохранено!';
	return;
}

sub site_title
{
	my $o = shift;
	
	if($o->{'title'}){ print $o->{'title'}; return; }
        if($o->papa->{'title_child'}){ print $o->papa->{'title_child'}; return; }	
	my $ttl = $o->site_name();
	my $gttl = $o->papaN(0)->{'title'};
       if ($gttl && $ENV{'SERVER_NAME'} ne $CMSBuilder::Config::server_main){
               $gttl=modSite->new($CMSBuilder::site_id)->{title};
       }
	print $gttl?"$ttl — $gttl":$ttl;
	
	return;
}

sub admin_props
{
	my $o = shift;
	my $mcw_id;
	print '<table class="props_table">';

	print '<tr><td colspan="2"><h2>Служебные характеристики</h2></td></tr>';
	$o->admin_view_props('_aview');
#print $o->{};
if ($ENV{QUERY_STRING}=~/mcw\=mcw[a-zA-Z]+(\d+)/ || $o->{mcw_id}){
   $mcw_id=($o->{mcw_id}?$o->{mcw_id}:$1);
   foreach my $k (cmsb_url('mcwWare'.$mcw_id)->get_all){
      $o->admin_view_props2($k);
   }
} else {
	print '<tr><td colspan="2"><h2>Общие характеристики</h2></td></tr>';
	$o->admin_view_props('_main');
	print '<tr><td colspan="2"><h2>Камера</h2></td></tr>';
	$o->admin_view_props('_camera');
	print '<tr><td colspan="2"><h2>Мультимедиа</h2></td></tr>';
	$o->admin_view_props('_multi');
	print '<tr><td colspan="2"><h2>Память</h2></td></tr>';
	$o->admin_view_props('_memory');
	print '<tr><td colspan="2"><h2>Экран</h2></td></tr>';
	$o->admin_view_props('_screen');
	print '<tr><td colspan="2"><h2>Интерфейсы</h2></td></tr>';
	$o->admin_view_props('_interface');
	print '<tr><td colspan="2"><h2>Звонки</h2></td></tr>';
	$o->admin_view_props('_calls');
	print '<tr><td colspan="2"><h2>Управление звонками</h2></td></tr>';
	$o->admin_view_props('_callcontrol');
	print '<tr><td colspan="2"><h2>Клавиатура</h2></td></tr>';
	$o->admin_view_props('_keybrd');
	print '<tr><td colspan="2"><h2>Органайзер</h2></td></tr>';
	$o->admin_view_props('_org');
	print '<tr><td colspan="2"><h2>Сообщения</h2></td></tr>';
	$o->admin_view_props('_mess');
	print '<tr><td colspan="2"><h2>Питание</h2></td></tr>';
	$o->admin_view_props('_power');
	print '<tr><td colspan="2"><h2>Размеры и вес</h2></td></tr>';
	$o->admin_view_props('_sizes');
	print '<tr><td colspan="2"><h2>Дополнительный функционал</h2></td></tr>';
	$o->admin_view_props('_dop');
	print '<tr><td colspan="2"><h2>Экспорт в Яндекс.Маркет</h2></td></tr>';
	$o->admin_view_props('_yandex');
}	
	
	print '</table><!--<input type="hidden" name="mcw_id" value="'.$mcw_id.'">-->';
	
	return 1;
}

sub admin_edit{
        my $o = shift;
        my $r = shift;
        my $na =
        {
                -keys => [$o->aview('_all')],
                @_
        };

        my $p = $o->props();

        my ($val,$vt);
        for my $key (@{$na->{'-keys'}})
        {
                do { warn ref($o).': _props{} has no key "'.$key.'"'; next } unless exists $p->{$key};
                $vt = 'CMSBuilder::VType::'.$p->{$key}{'type'};
                $val = $r->{$key};
                unless($group->{'html'} || ${$vt.'::dont_html_filter'}){ $val = HTMLfilter($val); }
                $o->{$key} = $vt->aedit($key,$val,$o,$r);
        }

        $o->notice_add( $o->err_cnt()?'Изменения внесены частично.<br>':'Изменения успешно сохранены.<br>' );
	my $dbs;
        if ($r->{mcw_id}!=$o->{mcw_id}){
		$dbs=$CMSBuilder::DBI::dbh->prepare('DELETE from dbo_mcwWareBase where ware_id=?');
		$dbs->execute($o->{ID});
	}
	if ($r->{mcw_id}){
#open(FILE,'>/www/evoo/evoo.ru/cmsbuilder/tmp/test4.log');
#print FILE $r->{mcw_id};
#close(FILE);
	   my $mcw;
	   my $myurl;
	   foreach my $k(cmsb_url('mcwWare'.$r->{mcw_id})->get_all){
	      foreach my $k2($k->get_all){
		 $myurl=lc($k2->myurl);
		 next if !defined ($r->{$myurl});
		 $dbs=$CMSBuilder::DBI::dbh->prepare('SELECT ID from dbo_mcwWareBase where field_id=? and ware_id=?');
                 $myurl=~/(\d+)/;
		 $dbs->execute($1,$o->{ID});
		 my $dbrow;
		 if (!($dbrow=$dbs->fetchrow_hashref)){
		    $mcw=mcwWareBase->cre();
		 } else {
		    $mcw=cmsb_url('mcwWareBase'.$dbrow->{ID});
		 }
		 $mcw->{'field_value'}=$r->{$myurl};
#		 $myurl=~/(\d+)/;
		 $mcw->{'field_id'}=$1;
		 $mcw->{'ware_id'}=$o->{ID};
#print $mcw->{ID}.'|'.keys(%{$mcw->props()})."<br>";
		 $mcw->save();
		 #$o->elem_paste($mcw);
	      }
	   }
	}
}
sub admin_view_props2{
   my $o=shift;
   my $k=shift;
   my $check=0;
   my $type;
   my $val;
   print '<tr><td colspan="2"><h2>'.$k->{name}.'</h2></td></tr>';
   foreach my $field($k->get_all){
      $val='';
   foreach my $key(mcwWareBase->all){$val=$key->{field_value} if $key->{ware_id}==$o->{ID} and $key->{field_id}==$field->{ID};};
      switch ($field->{type}){
	case 'text'{
	 $type='<input type="text" name="'.lc($field->myurl).'" value="'.$val.'">';}
        case 'checkbox'{
	 $type='<input type="checkbox" name="'.lc($field->myurl).'">';}
	else {
	 $type='<select name="'.lc($field->myurl).'">'.join(',','<option>'.
		$field->{value}.'</option>').'</select>';
	}
      }
      print '           <tr>
                        <td valign="top" width="20%" align="left"><label for="'.
			lc($field->myurl).'">'.$field->{name}.'</label>:</td>
                        <td width="80%" align="left" valign="middle">
                        '.$type.'
                        </td></tr>
			';
     $check=1;
   }
   print 'Нет доступных для редактирования свойств в данном разделе' if (!$check);
}

sub admin_view_props
{
	my $o = shift;
	my $view = shift;
	
	my $na =
	{
		-keys => [$o->aview($view)],
		-action => 'view',
		@_
	};
	
	unless( @{$na->{-keys}} )
	{ print '<p align="center">Нет доступных для редактирования свойств.</p>'; return 0; }
	
	my $p = $o->props();
	
	for my $key (@{$na->{-keys}})
	{
		do { warn ref($o).': _props{} has no key "'.$key.'"'; next } unless exists $p->{$key};
		
		my $vt = 'CMSBuilder::VType::'.$p->{$key}{'type'};
		
		if(${$vt.'::admin_own_html'})
		{
			my $val = $na->{-action} eq 'create' ? $p->{$key}{'default'} : $o->{$key};
			print $vt->aview( $key, $val, $o );
		}
		else
		{
			print
			'
			<tr>
			<td valign="top" width="20%" align="left"><label for="',$key,'">',$p->{$key}{'name'},'</label>:</td>
			<td width="80%" align="left" valign="middle">
			',$vt->aview($key,$o->{$key},$o),'
			</td></tr>
			';
		}
	}
}

sub catalog_add_to_comp
{
	my $o = shift;
	my $r = shift;
	
	if ($r->{checked})
	{
		$sess->{catalog_comp}->{$o->myurl} = 1;
	}
	else
	{
		delete $sess->{catalog_comp}->{$o->myurl};
	}
	
	$o->catalog_root->catalog_add_to_comp_js($r);
}

sub ware_handler
{
	my $o = shift;
	my $mp = shift;
	
	my $h = CatWareHandler->cre();
	
	my $tmp;
	map { $tmp = $_ if $o->{price} eq $_->{value} } $o->{multiprops}->get_all;
	$mp = $mp || $tmp;
	
	$h->{ware} = $o;
	$h->{count} = 1;
	$h->{price} = $mp ? $mp->{value} : $o->{price};
	$h->{prop} = $mp->myurl if $mp;
	return $h;
}

sub site_basket_view_img
{
	my $o = shift;
	my $handler = shift;
	
	return '<span class="catalog-ware-basket"><img src="' . $o->{'smallphoto'}->href . '" class="icon" align="absmiddle"/> <a href="' . $o->site_href . '">' . $o->name . ($handler->{prop} ? ' (' . cmsb_url($handler->{prop})->{name} . ')' : '') . '</a></span>';
}

sub site_basket_view
{
	my $o = shift;
	
	return '<span class="catalog-ware-basket"><a href="' . $o->site_href . '">' . $o->name . '</a></span>';
}

sub site_add_to_comp_button
{
	my $o = shift;
	my $r = shift;
	
	return
	'
	<div class="to-comp">
		<input
			type="checkbox"
			action="/srpc/' . $o->myurl . '/catalog_add_to_comp"
			onclick="catalog_add_to_comp(this)"
			id="' . $o->myurl . '_add_to_comp"
			' . ($sess->{catalog_comp}->{$o->myurl} && 'checked="true"') . '
		/>
		<label for="' . $o->myurl . '_add_to_comp">сравнить</label>
	</div>
	';
}

sub site_to_the_basket_button
{
	my $o = shift;
	my $r = shift;

	my $basket = $user->{basket} || cmsb_url($sess->{basket});

	return unless $basket;
	if ($o->{insight})
	{
		my $hnd = $basket->search_ware_handler($o);
		
		if ($hnd)
		{
			return '<img src="/i/vkorzine.png">';#'<a href="#"><img src="/i/buy.png" alt="" /></a>';
			#return '<div class="to-the-basket"><a class="add" action="/srpc/' . $basket->myurl . '/catalog_edit_ware?ware=' . $o->myurl . '" onclick="catalog_edit_basket(this)" style="cursor: pointer;" title="Внести изменения"><img alt="Внести изменения" src="/img/edit.png"/></a></div>';
		}
		else
		{
			return '<a class="add" action="/srpc/' . $basket->myurl . '/catalog_add_ware?ware=' . $o->myurl . '" actionedit="/srpc/' . $basket->myurl . '/catalog_edit_ware?ware=' . $o->myurl . '" onclick="catalog_move_to_basket(this)" style="cursor: pointer;" title="Купить">
			<img src="/i/buy'.($ENV{'SERVER_NAME'} ne $CMSBuilder::Config::server_main?'_sat':'').'.png" alt="" /></a>';
			#'<div class="to-the-basket"><img alt="Купить" src="/img/buy.png"/></a></div>';
		}
	}
	else
	{
		return '<div class="to-the-basket"><button class="not-in-sight" disabled="yes"/>Нет&nbsp;в&nbsp;наличии</button></div>';
	}
}

sub site_to_the_basket_button_preview
{
	my $o = shift;
	my $r = shift;

	my $basket = $user->{basket} || cmsb_url($sess->{basket});

	return unless $basket;
	
	if ($o->{insight})
	{
		my $hnd = $basket->search_ware_handler($o);
		
		if ($hnd)
		{
			return '<div class="to-the-basket"><button class="not-in-sight" disabled="yes"/>Добавлено</button></div>'; #&nbsp;(' . $hnd->count . ')
		}
		else
		{
			return '<div class="to-the-basket"><button class="add" action="/srpc/' . $basket->myurl . '/catalog_add_ware?ware=' . $o->myurl . '" onclick="catalog_move_to_basket(this)"/>В&nbsp;корзину</button></div>';
		}
	}
	else
	{
		return '<div class="to-the-basket"><button class="not-in-sight" disabled="yes"/>Нет&nbsp;в&nbsp;наличии</button></div>';
	}
}

sub site_basket_step1
{
	my $o=shift;
        my $basket = $user->{basket} || cmsb_url($sess->{basket});
	my $sum=$o->{price};
	my $count=1;
        for my $to ($basket->get_all)
        {
           $sum+=$to->summ;
	   $count+=$to->{count};
	}
	$sum=substr($sum,0,-3).' '.substr($sum,-3) if length $sum>3;
	print '<div class="tovar">
	<a href="'.$o->site_href.'" class="tovar-photo"><img src="'.$o->{photo}->href.'" alt="" width="93" id="mainphoto2" /></a>
	<h3><a href="'.$o->site_href.'">'.$o->{name}.'</a></h3>
	<span>'.$o->{price}.' руб</span>
</div>
<div class="basket-variants">
	<div>
		Теперь в корзине <span>'.$count.' товаров</span><br />

		на сумму <span>'.$sum.' р</span>
	</div>
	<ol>
		<li style="color: #02a0df;">1 - <a href="'.$o->papa->site_href.'" style="color: #02a0df; border-bottom: 1px dotted #02a0df;">Продолжить выбор покупок</a></li>
		<!--<li style="color: #e71e25;">2 - <a href="'.$basket->site_href.'" style="color: #e71e25; border-bottom: 1px dotted #e71e25;">Перейти в корзину</a></li>-->
		<li style="color: #38c000;">2 - <a href="'.$basket->site_href.'" style="color: #38c000; border-bottom: 1px dotted #38c000;" class="supernext">Оформить заказ</a></li>
	</ol>
</div>';
}

sub site_basket_url
{
        my $basket = $user->{basket} || cmsb_url($sess->{basket});
	return $basket->site_href;
}

sub site_papa_url
{
	my $o=shift;
#	print '/'.lc($o->papa->myurl).'.html';
	print $o->papa->site_href;
}

sub site_content
{
	my $o = shift;
	my $r = shift;
	
	my $photo;
	my $zoom;
	my $propdesc;
	my $basket = $user->{basket} || cmsb_url($sess->{basket});
	
	# print $o->site_to_the_basket_button;
	if ($r->{init}){
           CMSBuilder::VType::sizedimg->filter_load('photosmallest',$o->{photosmallest},$o);
	   CMSBuilder::VType::sizedimg->filter_load('smallphoto1',$o->{smallphoto1},$o);
           CMSBuilder::VType::sizedimg->filter_load('smallphoto2',$o->{smallphoto2},$o);
           CMSBuilder::VType::sizedimg->filter_load('smallphoto3',$o->{smallphoto3},$o);
	}
if ($ENV{'SERVER_NAME'} eq $CMSBuilder::Config::server_main){
	print
	'
	<div class="catalog" id="divCatalog" style="padding-top: 16px; border: 0; background: url(/i/center.png) repeat-x left bottom; margin-bottom: 15px;">
	<img class="cat_corners" alt="" style="bottom: 0pt; left: 0pt; display: block ! important;" src="/i/lb.png"/>
	<img class="cat_corners" alt="" style="bottom: 0pt; right: 0pt; display: block ! important;" src="/i/rb.png"/>';
}
my $price;
	print	'<div class="buy">
			<div>Цена: <span class="prices_span">';
if ($ENV{SERVER_NAME} eq $CMSBuilder::Config::server_main){
   $price=($o->{price} ? $o->{price} . ' руб.' : 'не указана');
} else {
   $price=$o->{price};
   $price=substr($price,0,-3).' '.substr($price,-3) if length($price)>4;
   $price=($price ? $price . ' руб' : 'не указана');
}
print $price.'</span></div>
			' . $o->site_to_the_basket_button . '
		</div>';
if ($ENV{'SERVER_NAME'} eq $CMSBuilder::Config::server_main){
	print '<h1>' . $o->name . '</h1>';
} else {
        print '<h2>' . $o->name . '</h2>';
}
my $simg_exists=($o->{photosmall} && $o->{photosmall}->exists?1:0);
my @img_ar=grep{$_ ne '/ee/wwfiles/'}($o->{photo}->href,$o->{photobig2}->href,$o->{photobig3}->href);
	print '<div class="cat_container">
			<div class="phone_photos" align="center">
				<script language="javascript">
				var imgs=new Array("'.join('","',@img_ar).'");
				</script>
				<a'.($simg_exists && $o->{photo}->exists?' href="'.$o->{photo}->href.'" class="thickbox" rel="gallery-wares"':'').'><img id="mainphoto"'.($simg_exists?'':' onclick="change_foto(this)"').' src="' . ($simg_exists?$o->{photosmall}->href:$o->{photo}->href) . '" alt="" />'.($simg_exists && $o->{photo}->exists?'<p><span>Увеличить</span>':'').'</a>';
print '<div style="display:none">'.join('',map{"<a href='$_' class='thickbox' rel='gallery-wares'><img src='$_'></a>"}(grep{$_ ne $o->{photo}->href}(@img_ar))).'</div>' if ($simg_exists);
print '				<table class="smallphotos"'.($simg_exists?' style="display:none"':'').'>
					<tr>
						<td><a class="sel"'.($o->{smallphoto2}->href eq '/ee/wwfiles/' and $o->{smallphoto3}->href eq '/ee/wwfiles/'?' style="display:none"':'').' onclick="changePhoto(\'' . $o->{photo}->href . '\'); $(this).addClass(\'sel\'); return false;" style="background-image: url(' . $o->{smallphoto1}->href . ')"><img src="' . $o->{smallphoto1}->href . '"/></a></td>
						<td><a onclick="changePhoto(\'' . $o->{photobig2}->href . '\'); $(this).addClass(\'sel\'); return false;" style="background-image: url(' . $o->{smallphoto2}->href . ')"><img src="' . $o->{smallphoto2}->href . '" /></a></td>
						<td><a onclick="changePhoto(\'' . $o->{photobig3}->href . '\'); $(this).addClass(\'sel\'); return false;" style="background-image: url(' . $o->{smallphoto3}->href . ')"><img src="' . $o->{smallphoto3}->href . '" /></a></td>
					</tr>
				</table>
			</div>
			<div class="phone_descr" id="div_phone_descr">
				';
print '<p>' if ($ENV{'SERVER_NAME'} ne $CMSBuilder::Config::server_main);
print $o->{desc};
print '</p><div style="margin:0 160px 0 20px;">' if ($ENV{'SERVER_NAME'} ne $CMSBuilder::Config::server_main);
   if (!$o->papa->{dont_view_props}){

my $h4='';
if ($o->{mcw_id}){
$h4=cmsb_url('mcwWare'.$o->{mcw_id})->{'head_params'};
}
$h4='Технические характеристики' if !$h4;

print '				<h4 id="h4header">'.$h4.'</h4>
				<div class="about_phone" id="div_about_phone">';
				$o->mcw_site_prop();
				print	$o->site_prop(qw/camera
				memory cards type radio
				wifi gps gprs edge blue1 blue2
				screentype screensize powertime powerwait 
				/) if !$o->{mcw_id};
			print '</div>';
my $head_full;
#my $head_full='Полные технические характеристики';
#if ($o->{mcw_id}){
#   $head_full=cmsb_url('mcwWare'.$o->{mcw_id})->{'head_all_params'};
#}
if (!$o->{mcw_id}){
			print '<br><a class="more">Смотреть полные характеристики</a>
			<script>
				$("a.more").click(
					function()
					{
						$(this).hide()
						$(".less").show()
						$("div.about_phone").slideUp(1000)
						$("#h4header").text("'.$head_full.'")
						$("div.morediv").slideDown(1500)
					}
					)
			</script>';
				print	'<div class="morediv about_phone" id="div_morediv">';
				print '
				<table>
													<tbody>';
print '<tr>
														<th width="50%"></th>
														<th><div style="width: 35px;"/></th>
														<th width="50%"></th>
													</tr>
													<tr valign="top">
														<td>
														<h3>Характеристики</h3>
															' . $o->td_prop(_main) . 
														'<h3>Мультимедиа</h3>' .	
															 $o->td_prop(_multi) .
														'<h3>Экран</h3>' .
															 $o->td_prop(_screen) .
														'<h3>Звонки</h3>' .
															 $o->td_prop(_calls) .
														'<h3>Сообщения</h3>' .
															 $o->td_prop(_mess) .
														'<h3>Размеры и вес</h3>' .
															 $o->td_prop(_sizes) .
														'<h3>Клавиатура</h3>' .
															 $o->td_prop(_keybrd) .
															'
														</td>
														<td class="noborder"/>
														<td>
														<h3>Камера</h3>
															' . $o->td_prop(_camera) .
														'<h3>Память</h3>' .
															 $o->td_prop(_memory) .
														'<h3>Интерфейсы</h3>' .
															 $o->td_prop(_interface) .
														'<h3>Органайзер</h3>' .
															 $o->td_prop(_org) .
														'<h3>Питание</h3>' .
															 $o->td_prop(_power) .
														 '<h3>Управление звонками</h3>' .
															 $o->td_prop(_callcontrol) .
															 '
														</td>
													</tr>' if !$o->{mcw_id};
$o->mcw_table_prop if $o->{mcw_id};
print '												</tbody></table>
				';
				# print '
				# <table>
				# 									<tbody><tr>
				# 										<th width="50%">Мультимедиа</th>
				# 										<th><div style="width: 35px;"/></th>
				# 										<th width="50%">Память</th>
				# 									</tr>
				# 									<tr valign="top">
				# 										<td>
				# 											' . $o->td_prop(_multi) . '
				# 										</td>
				# 										<td class="noborder"/>
				# 										<td>
				# 											' . $o->td_prop(_memory) . '
				# 										</td>
				# 									</tr>
				# 								</tbody></table>
				# ';
				# print '
				# <table>
				# 									<tbody><tr>
				# 										<th width="50%">Экран</th>
				# 										<th><div style="width: 35px;"/></th>
				# 										<th width="50%">Интерфейсы</th>
				# 									</tr>
				# 									<tr valign="top">
				# 										<td>
				# 											' . $o->td_prop(_screen) . '
				# 										</td>
				# 										<td class="noborder"/>
				# 										<td>
				# 											' . $o->td_prop(_interface) . '
				# 										</td>
				# 									</tr>
				# 								</tbody></table>
				# ';
				# print '
				# <table>
				# 									<tbody><tr>
				# 										<th width="50%">Звук</th>
				# 										<th><div style="width: 35px;"/></th>
				# 										<th width="50%">Органайзер</th>
				# 									</tr>
				# 									<tr valign="top">
				# 										<td>
				# 											' . $o->td_prop(_calls) . '
				# 										</td>
				# 										<td class="noborder"/>
				# 										<td>
				# 											' . $o->td_prop(_org) . '
				# 										</td>
				# 									</tr>
				# 								</tbody></table>
				# ';
				# print '
				# <table>
				# 									<tbody><tr>
				# 										<th width="50%">Сообщения</th>
				# 										<th><div style="width: 35px;"/></th>
				# 										<th width="50%">Питание</th>
				# 									</tr>
				# 									<tr valign="top">
				# 										<td>
				# 											' . $o->td_prop(_mess) . '
				# 										</td>
				# 										<td class="noborder"/>
				# 										<td>
				# 											' . $o->td_prop(_power) . '
				# 										</td>
				# 									</tr>
				# 								</tbody></table>
				# ';
				# print '
				# <table>
				# 									<tbody><tr>
				# 										<th width="50%">Размер и вес</th>
				# 										<th><div style="width: 35px;"/></th>
				# 										<th width="50%">Управление звонками</th>
				# 									</tr>
				# 									<tr valign="top">
				# 										<td>
				# 											' . $o->td_prop(_sizes) . '
				# 										</td>
				# 										<td class="noborder"/>
				# 										<td>
				# 											' . $o->td_prop(_callcontrol) . '
				# 										</td>
				# 									</tr>
				# 								</tbody></table>
				# ';
				# print '
				# <table>
				# 									<tbody><tr>
				# 										<th width="50%">Клавиатура</th>
				# 										<th><div style="width: 35px;"/></th>
				# 										<th width="50%"></th>
				# 									</tr>
				# 									<tr valign="top">
				# 										<td>
				# 											' . $o->td_prop(_keybrd) . '
				# 										</td>
				# 										<td class="noborder"/>
				# 										<td>
				# 											
				# 										</td>
				# 									</tr>
				# 								</tbody></table>
				# ';
					# print	$o->site_prop(qw/smartphone gsm900 gsm1800 gsm1900 wcdma optstandart os platform type opttype ant optfeature/);
					# 					print '<h4><br/>Камера</h4>';
					# 					print	$o->site_prop(qw/camera photorec cameraob camerazoom cameralight videorec secondvideo/);
					# 					print '<h4><br/>Мультимедиа</h4>';
					# 					print	$o->site_prop(qw/stereo radio mp3 aplayback optaudio voicerec java games/);
					# 					print '<h4><br/>Память</h4>';
					# 					print	$o->site_prop(qw/memory cards/);
					# 					print '<h4><br/>Экран</h4>';
					# 					print	$o->site_prop(qw/screentype screensize screenrus/);
					# 					print '<h4><br/>Интерфейсы</h4>';
					# 					print	$o->site_prop(qw/irda usb wifi blue1 blue2 optinterface wap gprs edge optinternet modem gps pcconnect/);
					# 					print '<h4><br/>Звук</h4>';
					# 					print	$o->site_prop(qw/melodytype vibrocall melodyedit melodyspeaker/);
					# 					print '<h4><br/>Органайзер</h4>';
					# 					print	$o->site_prop(qw/orgclock orgcalc orgcal orgoffice realplayer flashplayer lifeblog orgchat orgkeys/);
					# 					print '<h4><br/>Сообщения</h4>';
					# 					print	$o->site_prop(qw/sms mms email/);
					# 					print '<h4><br/>Питание</h4>';
					# 					print	$o->site_prop(qw/powertype powersize powerwait powertime/);
					# 					print '<h4><br/>Размеры и вес</h4>';
					# 					print	$o->site_prop(qw/dims weight/);
#if (!$o->{mcw_id}){
					print '<h3><br/>Дополнительный функционал</h3>' if $o->{dop};
					print $o->{dop};
					print '<h3><br/>Комплектация</h3>';
					print $o->{sostav};
#}
				print '</div>';
				print '<a class="less more">Коротко о главном</a>
				<script>
					$("a.less").click(
						function()
						{
							$.scrollTo( 0, 800 );
							$(".more").show()
							$(this).hide()
							$("div.about_phone").show()
							$("#h4header").text("'.$h4.'")
							$("div.morediv").hide();
						}
						)
				</script>';
}
print '</div>' if ($ENV{'SERVER_NAME'} ne $CMSBuilder::Config::server_main);
	print		'<!--<div class="info_container">
					<div class="rating">
						<b>Рейтинг</b>
						<span class="stars"><span></span></span>
					</div>
				</div>
			</div>-->
		</div>';}
   print '<table><tbody>';
   my $price=$o->{price};
   print '<script>function changePrice(val,obj){
		$(".prices_span").html(val+" руб");
	}</script>';
   for my $mp ($o->{multiprops}->get_all){
#      my $price = $basket->search_ware_handler($o->myurl)->{price} if $basket->search_ware_handler($o->myurl);
      my $checked;
      my $onthephoto;
      $checked = 'checked=1' if $mp->{value} eq $price;
      print '<script>$(".prices_span").html("' .$mp->{value} . '")</script>' if $mp->{value} eq $price;
      if (!$price){
	 $checked ='checked=1' if $mp->{value} eq $o->{price};
      }
      $propdesc = $mp->{desc} if $checked;
      $onthephoto = 'на фотографии' if $mp->{value} eq $o->{price};
      print '<tr>
         <td style="border: 0pt none ;">
         <input name="price" id="' . $mp->myurl . '" type="radio" value="' . 
	$mp->myurl . '" ' . $checked . ' onclick="changePrice(' . $mp->{value} .
	 ', \'' . $mp->myurl . '\')"></td><td class="tbl-name"><div id="' . 
	$mp->myurl . '_desc" style="display:none">' . $mp->{desc} . 
	'</div><label for="' . $mp->myurl . '">' . $mp->name . '</label></td>
        <td class="tbl-price">' . $mp->{value} . 
	'</td><td class="rub">руб</td><td>' . $onthephoto . 
	(($checked) ? '<script>changePrice(' . $mp->{value} . ', \'' . 
	$mp->myurl . '\')</script>' : '') . '</td>
                                </tr>';
   }
   print '</tbody></table>';
   print '                        <div class="buy">
                                <div>Цена: <span>' . ($o->{price}? $o->{price} . ' руб.' : 'не указана') . '</span></div>
                                ' . $o->site_to_the_basket_button . '
                        </div>' if !$o->papa->{dont_view_second_price};
   print '</div>';
print '	<div class="catalog ie6omg similar" style="min-height: 150px; margin-bottom: 15px; background: url(/i/profile-bg.png) repeat-x #fcfcfc; border: 1px solid #e3e3e3;">
		<img src="/i/last.png" class="cat_corners" style="right: -1px; top: -1px;" alt="" />
		<img src="/i/profile-lb.png" class="cat_corners" style="left: -1px; bottom: -1px;" alt="" />
		<img src="/i/profile-rb.png" class="cat_corners" style="right: -1px; bottom: -1px;" alt="" />
		<ul class="omg_goga">
			<li><a href="#"><img src="/i/1.png" alt="" /></a></li>
			<li><a href="#"><img src="/i/2.png" alt="" /></a></li>
			<li><a href="#"><img src="/i/3.png" alt="" /></a></li>
		</ul>
		
		<div class="otzivi_block" style="clear: both;">';
my $modcatalog=$o->papa->papa;
my $dbh=$CMSBuilder::DBI::dbh->prepare('SELECT ID from dbo_CatDir where 
	PAPA_CLASS="modCatalog" and PAPA_ID='.$modcatalog->{ID});
$dbh->execute;
my ($row,$catdirs,$price_params);
while($row=$dbh->fetchrow_hashref){
   $catdirs.=' PAPA_ID='.$row->{ID}.' OR ';
}
$catdirs=substr($catdirs,0,-4);
$price_params=' AND price>='.($o->{price}-$modcatalog->{price_from}) if $modcatalog->{price_from};
$price_params.=' AND price<='.($o->{price}+$modcatalog->{price_to}) if $modcatalog->{price_to};
my $check=0;
if ($catdirs){
$dbh=$CMSBuilder::DBI::dbh->prepare('SELECT ID,name,price,photo,photosmall,photosmallest,photosmallest2 from dbo_CatWareSimple
	where ('.$catdirs.')'.$price_params.' order by RAND() limit 3');
$dbh->execute();
my $photo;
#!!!
while($row=$dbh->fetchrow_hashref){
   $check=1;
   Encode::_utf8_on($row->{name});
   $photo=$row->{photo};
   $photo.='_smallphoto1.jpeg' if -e $CMSBuilder::Config::path_wwfiles.'/'.$photo.'_smallphoto1.jpeg';
   $photo=$row->{smallphoto}.'" smallphoto="1' if $row->{smallphoto};
   $photo=$row->{photosmallest}.' photosmallest="1' if $row->{photosmallest};
   $photo=$row->{photosmallest2}.' photosmallest2="1' if $row->{photosmallest2};
   print '                        <div class="same">
                                <a href="/catwaresimple'.$row->{ID}.
					'.html" class="same_photo">
			<img src="/ee/wwfiles/'.$photo.'" alt="" /></a>
                                <div class="same_block">
                                        <a href="/catwaresimple'.$row->{ID}.
					'.html">'.$row->{name}.' </a>
                                        <b>Цена: '.$row->{price}.' руб </b>
                                        <p></p>
                                </div>
                        </div>';
}}
print 'Нет предложений' if (!$check);
=head
			<div class="same">
				<a href="#" class="same_photo">
<img src="/i/small1.jpg" alt="" /></a>
				<div class="same_block">
					<a href="#">Nokia n95 </a>
					<b>Цена: 15 290 руб </b>
					<p>Основная особе΍
½ность Nokia N95 – отличная 5-меОсновная ос΍
¾бенность Nokia N95 – отличная 5-меОсновная
 особенность Nokia N95</p>
				</div>
			</div>
			<div class="same">
				<a href="#" class="same_photo"><img src="/i/small1.jpg" alt="" /></a>
				<div class="same_block">
					<a href="#">Nokia n95 </a>
					<b>Цена: 15 290 руб </b>
					<p>Основная особенность Nokia N95 – отличная 5-меОсновная особенность Nokia N95 – отличная 5-меОсновная особенность Nokia N95</p>
				</div>
			</div>
			<div class="same">
				<a href="#" class="same_photo"><img src="/i/small1.jpg" alt="" /></a>
				<div class="same_block">
					<a href="#">Nokia n95 </a>
					<b>Цена: 15 290 руб </b>
					<p>Основная особенность Nokia N95 – отличная 5-меОсновная особенность Nokia N95 – отличная 5-меОсновная особенность Nokia N95</p>
				</div>
			</div>
=cut
print	'	</div>
	</div>

	';
$o->{comments}->site_content;
=head
print '<div class="catalog feedback" style="min-height: 200px; background: url(/i/profile-bg.png) repeat-x #fcfcfc; border: 1px solid #e3e3e3;">
		<img src="/i/profile-lt.png" class="cat_corners" style="left: -1px; top: -1px; display: block;" alt="" />
		<img src="/i/profile.jpg" class="cat_corners" style="right: -2px; top: -1px; display: block;" alt="" />
		<img src="/i/profile-lb.png" class="cat_corners" style="left: -1px; bottom: -1px;" alt="" />
		<img src="/i/profile-rb.png" class="cat_corners" style="right: -1px; bottom: -1px;" alt="" />
		
		<div class="otzivi_block">
			
			<form action="">
				<input type="text" class="otzivi_name" name="email" value="E-mail" />
				<input type="text" class="otzivi_mail" value="Ваше имя" />
				
				<textarea>Ваш отзыв</textarea>
				<table>
					<tr>
						<td><div><label><input type="checkbox" name="comment_emailme" /><span>Оповестить об ответе на e-mail</span></label></div></td>
						<td><input type="image" src="/i/comment.png" class="gogo" /></td>
					</tr>
				</table>
				
				
				
			</form>
			<div class="otzivi">
				<h5>Отзывы</h5>
				<dl>
					<dt>Потзователь: <a href="#" style="color: #622c96;">Demo</a></dt>
					<dd>Фильм хороший, можно  посмотреть Фильм хороший, можно  посмотретьФильм хороший, можно  посмотретьФильм хороший, можно  посмотреть</dd>	
					<dt>Потзователь: <a href="#" style="color: #622c96;">Demo</a></dt>
					<dd>Фильм хороший, можно  посмотреть</dd>
				</dl>
			</div>
		</div>
	</div>';
=cut
print '	<div class="description">
		<h2>' . $o->papa->name . '</h2>
		' . $o->papa->{desc} . '
	</div>
	';
}

sub site_preview
{
	my $o = shift;
#	my $r = shift;
	my $count = shift;
	my $style;
	$style = 'style="width:49%"' if $count == 2;
	
	my $photo_href;
        if (CGI::param('init') && $o->{photosmall} && $o->{photosmall}->exists){
           CMSBuilder::VType::sizedimg->filter_load('photosmallest',$o->{photosmallest},$o);
           CMSBuilder::VType::sizedimg->filter_save('photosmallest',$o->{photosmallest},$o);
        }
#	if ($o->{PAPA_ID}==54 && $o->{smallphoto1} && $o->{smallphoto1}->exists){
#		$photo_href=$o->{smallphoto1}->href;
#	} els
	if ($o->papa->{ID}!~/^(53|60|61|58|54|62|59|63)^/ && $o->{photosmallest2} && $o->{photosmallest2}->exists){
		$photo_href=$o->{photosmallest2}->href;
	}
	elsif ($o->papa->{ID}!~/^(53|60|61|58|54|62|59|63)$/ && $o->{photosmallest} && $o->{photosmallest}->exists){
		$photo_href=$o->{photosmallest}->href;
	}
	elsif ($o->{mediumphoto1} && $o->{mediumphoto1}->exists)
	{
		$photo_href = $o->{mediumphoto1}->href
	}
	elsif ((my $cr = $o->catalog_root)->{shownophoto})
	{
		$photo_href = $cr->{nophotoimg}->href;
	}
my $href=$o->site_href;
my $start_html;
if ($ENV{'SERVER_NAME'} eq $CMSBuilder::Config::server_main){	
	$start_html='
<div class="cat_block" ' . $style . '>';
} else {
        $start_html='
<div class="left" '.($style?$style:'style="width:33%"').'>';
$href=~s/(\/catware)/_sat\1/;
}
my $img_alt=$o->name;
$img_alt=~s/"/'/g;
my $papa_my4;
$papa_my4=$o->papa->papa->{my4} if $o->papa->papa;
if ($papa_my4 eq 'radiomodel' #or $o->papa->{ID}=~/^(53|60|61|58|54|62|59|63)$/
){
   print '   <div class="radiomodel"><div align="center"><div class="image"><a href="'.$o->site_href.'"><img align="center" alt="'.$img_alt.'" src="'.$photo_href.'" style="float:center"/></a></div>
   <h4 style="color:black">'.$o->site_aname.'</h4>
   <p></p>
   <p'.($ENV{'SERVER_NAME'} eq $CMSBuilder::Config::server_main?' class="price"':'').'>' . ($o->{price} ? $o->{price} . ' руб.' : 'Цена не указана').'</p></div>';
} else {
   print $start_html.'
				<a class="cat_img" href="' . $href . '"><img alt="' . $img_alt . '" src="' . $photo_href . '"/>'.($ENV{'SERVER_NAME'} ne $CMSBuilder::Config::server_main?'<img src="i/shadow.png" alt="" />':'').'</a>
				<div class="cat_descr">
					<h3><a href="' . $o->site_href . '">' . $o->name . '</a></h3>
					<p>';
	print $o->site_props;
	print			'</p>
					<span'.($ENV{'SERVER_NAME'} eq $CMSBuilder::Config::server_main?' class="price"':'').'>' . ($o->{price} ? $o->{price} . ' руб.' : 'Цена не указана') . '</span>
				</div>';
}
print '			</div>';
	return;
}

sub site_props
{
	my $o = shift;
	
	my $props =  '' ; 
if ($o->{mcw_id}){
   my ($val,$count);
   $count=1;
   my ($dbs,$row);
   foreach my $k (cmsb_url('mcwWare'.$o->{mcw_id})->get_all){
      foreach my $k2 ($k->get_all){
        $val='';
$dbs=$CMSBuilder::DBI::dbh->prepare('SELECT field_value from 
dbo_mcwWareBase where field_id='.$k2->{ID}.' and ware_id='.$o->{ID});
$dbs->execute();
$val=$row->{field_value} if ($row=$dbs->fetchrow_hashref);
Encode::_utf8_on($val);
#        map{$val=$_->{field_value} if $_->{field_id}==$k2->{ID}
#                && $_->{ware_id}==$o->{ID}} mcwWareBase->all;
	  $props.=$k2->{name}." $val, " if $val;
	last if ++$count>4;
      }
   }
} else {
	$props.=			($o->{camera} ? "Камера $o->{camera} Мпикс, " : "" ) .
					($o->{gps} ? "GPS, " : "") .
					($o->{ggg} ? "3G, " : "") .
					($o->{wifi} ? "WiFi, " : "") .
					($o->{edge} ? "EDGE, " : "") .
					($o->{bluetooth} ? "Bluetooth $o->{bluetooth}, " : "") .
					($o->{cards} ? "$o->{cards}, " : "") .
					($o->{memory} ? "память $o->{memory} Мб, " : "") .
					($o->{vplayback} ? "видео" . ($o->{aplayback} ? "-" : "") : "") .
					($o->{aplayback} ? "аудио " : "") .
					($o->{vplayback} || $o->{aplayback} ? " плеер, " : "") .
					($o->{radio} ? "FM, " : "") .
					($o->{voicerec} ? "диктофон, " : "") .
					($o->{games} ? "игры, " : "") .
					($o->{screentype} ? "экран $o->{screentype}, " : "") .
					($o->{screeninc} ? "$o->{screeninc}\", " : "") .
					($o->{screensize} ? "$o->{screensize}, " : "") .
					($o->{screencolor} ? "$o->{screencolor} тыс. цветов" : "") ;
}
	$props =~ s/, $//;
	
	return $props;
}
sub admin_cname{
   my $o=shift;
   shift;
   $_[0]=~/url\=([^\&]+)/;
   my $tmp=$1;
   my $all_list=($ENV{QUERY_STRING}=~/^url\=(CatDir|modCatalog)\d+$/?1:0);
   $o->admin_cname_print(shift,'Товар') if ($all_list || (!$all_list && $ENV{'QUERY_STRING'}!~/mcw\=mcw/));
  if ($all_list || (!$all_list && $ENV{'QUERY_STRING'}=~/mcw\=mcw/)){
   foreach my $k (mcwWare->all){
      $o->admin_cname_print('right.ehtml?url='.$tmp.'&act=cms_array_add&cname=CatWareSimple&mcw='.$k->myurl,$k->{name}) if ($all_list || (!$all_list && index($ENV{'QUERY_STRING'},'mcw='.$k->myurl)!=-1));
   }
  }
}
sub admin_cname_print{
   my $o=shift;
   print '<table class="objtbl"><tr><td><a href="'.shift.'"><img src="icons/CatWare.gif"/><span class="subsel">'.shift.'</span></a></td></tr></table>';
}
sub mcw_site_prop{
   my $o=shift;
   return if !$o->{mcw_id};
   my $count=0;
   my $val;
   print '
	<table>
';
   foreach my $k (cmsb_url('mcwWare'.$o->{mcw_id})->get_all){
      print '		<tr>
';
      foreach my $k2 ($k->get_all){
	if ($count && !($count%2)){
	   print '	</tr><tr>
';
	}
$count++;
	$val='';
	map{$val=$_->{field_value} if $_->{field_id}==$k2->{ID}
                && $_->{ware_id}==$o->{ID}} mcwWareBase->all;
	if ($val){
	   print '			<td class="bordered_td" width="50%" style="font-size:12px">'.
		'<span class="left">'.$k2->{name}.': </span><span class="'.
		'right">'.$val;
	   print '</span></td>
';
	   print '			<td class="noborder"><div style="width: 35px;'.
		'"></div></td>' if ($count%2);
	} else {
	   $count--;
	}
      }
      print '		</tr>';
   }
   print '	</table>';
}
=head
sub mcw_table_prop{
   my $o=shift;
   return if !$o->{mcw_id};
   my ($val,$len,$len2,$count);
   map{$len++ if $_->{ware_id}==$o->{ID}} mcwWareBase->all;
   $len2=cmsb_url('mcwWare'.$o->{mcw_id})->get_all;
   if ($len2>1){
      print '
<tr>
        <th width="50%"></th>
	<th><div style="width: 35px;"/></th>
	<th width="50%"></th></tr>';
   }# else {
    #  print '
    #    <th width="100%"></th></tr>';
   #}

print '        <tr valign="top"><td>
';
   foreach my $k (cmsb_url('mcwWare'.$o->{mcw_id})->get_all){
      print '           <h3>'.$k->{name}.'</h3><table>
';
      foreach my $k2 ($k->get_all){
	$count++;
        map{$val=$_->{field_value} if $_->{field_id}==$k2->{ID}
                && $_->{ware_id}==$o->{ID}} mcwWareBase->all;
           print '<tr><td class="bordered_td">'.
                '<span class="left">'.$k2->{name}.'</span><span class="'.
                'right">'.($val?$val:'-').'</span></td></tr>
';
      }
      print '           </table>';
      print '</td><td class="noborder"/><td>' if ($len2>1 && $count>$len/2);
   }
   print '      </td></tr>';
}
=cut
1;
