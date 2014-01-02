# (с) Токмаков А. И., 2005-2006

package mcwWare;
use strict qw(subs vars);
use utf8;

our @ISA = ('plgnSite::Object','CMSBuilder::DBI::FilteredArray','CMSBuilder::DBI::Array');

sub _cname {'Шаблон товара'}
sub _aview {qw/name head_params head_all_params name4newsbot/}
sub _add_classes {qw/mcwWareHeader/}
sub _have_icon {1}
sub admin_props{
   my $o=shift;
   print '<table class="props_table">
		<tr>
			<td valign="top" width="20%" ali
gn="left"><label for="name">Название</label>:</td>
			<td width="80%" align="left" valign="middle">
			<input class="winput" type=text name="name" value="'.$o->{name}.'">
			</td></tr>
                <tr>
                        <td valign="top" width="20%" ali
gn="left"><label for="head_params">Заголовок всех параметров и полей</label>:</td>
                        <td width="80%" align="left" valign="middle">
                        <input class="winput" type=text name="head_params"
value="'.$o->{head_params}.'">
                        </td></tr>
                <!--<tr>
                        <td valign="top" width="20%" ali
gn="left"><label for="head_all_params">Заголовок всех параметров</label>
                        <td width="80%" align="left" valign="middle">
                        <input class="winput" type=text name="head_all_params"
value="'.$o->{head_all_params}.'">
                        </td></tr>-->
                <tr>
                        <td valign="top" width="20%" align="left">
<label for="name4newsbot">Название раздела на сайте, с которого тянем товары:</label>
                        <td width="80%" align="left" valign="middle">
                        <input class="winput" type=text name="name4newsbot"
value="'.$o->{name4newsbot}.'">
                        </td></tr>
<tr><td><script language="javascript">
</script></td></tr>';
   print '</table>';
}
sub _props
{
	'name'	=> { 'type' => 'string', 'length' => 100, 'name' => 'Название' },
	'head_params' => { 'type' => 'string', 'name' => 'Заголовок параметров'},
	'head_all_params' => {'type'=>'string','name'=>'Заголовок всех параметров'},
	'name4newsbot' => {'type'=>'string','name'=>'Название раздела на сайте, с которого  тянемтовары'},
#	'desc'	=> { 'type' => 'miniword', 'name' => 'Описание' }
}

#———————————————————————————————————————————————————————————————————————————————

use plgnUsers;
use CMSBuilder::Utils;

sub interval_filter
{
	my $o = shift;
	
	return @_ if !$o->papa() || $o->papa()->access('w');
	
	return grep {$_->{'answer'}} @_;
}

sub _have_icon 
{
	my $o = shift;
	
	return (grep {!$_->{'answer'}} $o->get_all())?'icons/fbTheme_new.gif':'icons/fbTheme.gif';
}

sub process_params
{
	my $o = shift;
	my $r = shift;
	
	return if $r->{'action'} ne 'save';
	
	if($r->{'question'}) #Нет вопроса - свалим.
	{
		my $to = fbQuestion->cre();
		my $res = $o->elem_paste($to);
		
		$to->admin_edit($r);
		$to->save();
		
		print '<div class="message">';
		
		if($res)
		{
			if($o->papa()->{'emailme'})
			{
				sendmail
				(
					to		=> $o->root->{'email'},
					from	=> $to->{'username'}.' <'.($to->{'email'} || $o->root->{'email'}).'>',
					subj	=> '['.$o->root->{'bigname'}.'] Модуль вопрос-ответ, новая тема:'.$o->name(),
					text	=> $to->{'question'}."\n\n--\n\nОтвет можно написать из админки: ".$o->admin_abs_href,
					ct		=> 'text/html; charset=windows-1251'
				);
			}
			
			print
			'
			<p>Спасибо, ваш вопрос был успешно добавлен. Вы увидите его на сайте, когда он будет обработан.</p>
			'.($to->{'emailme'}?'<p>На указанный вами e-mail придет уведомление об ответе.</p>':'').'
			<p><a href="'.$o->site_href().'?form=yes">Продолжить задавать вопросы...</a></p>
			';
		}
		else
		{
			print
			'
				К сожалению, по техническим причинам, ваш вопрос не был сохранен.
				Попробуйте отправить его по почте: <a href="mailto:',$o->root->{'email'},'">',$o->root->{'email'},'</a>.
			';
			
			return 0;
		}
		
		print '</div>';
	}
	else
	{
		print '<div class="error">Вы не ввели текст вопроса.</div>';
		return 0;
	}
	
	return 1;
}

#Скрывает строчку с номерами страниц во время составления вопроса.
sub site_pagesline
{
	my $o = shift;
	my $r = shift;
	
	return if $r->{'form'};
	
	return $o->SUPER::site_pagesline($r,@_);
}

#Распечатывает список тем. Если их слишком много, бьет на страницы.
sub site_content
{
	my $o = shift;
	my $r = shift;
	
	if($r->{'form'})
	{
		return if $o->process_params($r);
		return $o->print_form($r);
	}
	print '<link href="/main.css" rel="stylesheet" type="text/css" media="all" />';
	print '<link href="/_default.css" rel="stylesheet" type="text/css" media="all" />';
	my @page = $o->get_page($r->{'page'});
	
	print '<div class="mod-feedback">';
	
	print '<a class="ask" href="?form=yes"><span>Написать</span></a>';
	
	if(!@page)
	{
		print '<div class="message">Записей пока нет.</div>';
	}
	else
	{
		map { $_->site_preview() } @page;
	}
	
	print '</div>';
}

sub print_form
{
	my $o = shift;
	my $r = shift;
	
	print '<link href="/main.css" rel="stylesheet" type="text/css" media="all" />';
	print '<link href="/_default.css" rel="stylesheet" type="text/css" media="all" />';
	
	print
	'
	<form action="?" method="post">
		<input type="hidden" name="action" value="save">
		<input type="hidden" name="form" value="yes">
		
	<span class="outgoing">
		<div class="sender">
			<div class="icon"><img class="png" src="/img/buddy_icon.png" onload="Reflection.add(this,null);" /></div>
		</div>
		<div class="message">
			<div class="topleft"></div>
			<div class="top"></div>
			<div class="topright"></div>
			<div class="bbody"><input name="username" value="Ваше имя"></div>
			<div class="left"></div>
			<div class="middle"></div>
			<div class="right"></div>
			<div class="bottomleft"></div>
			<div class="bottom"></div>
			<div class="bottomright"></div>
		</div>
	</span>
	<br clear="all">
	<div id="insert"></div>
	
	<span class="outgoing">
		<div class="message">
			<div class="topleft"></div>
			<div class="top"></div>
			<div class="topright"></div>
			<div class="bbody"><input value="Электронный адрес" name="email" value="',$r->{'email'},'"></div>
			<div class="left"></div>
			<div class="middle"></div>
			<div class="right"></div>
			<div class="bottomleft"></div>
			<div class="bottom"></div>
			<div class="bottomright"></div>
		</div>
	</span>
	<br clear="all">
	<div id="insert"></div>
	
	<span class="outgoing">
		<div class="message">
			<div class="topleft"></div>
			<div class="top"></div>
			<div class="topright"></div>
			<div class="bbody"><input class="checkbox" id="checkbox_emailme" type="checkbox" ',$r->{'emailme'}?'checked="checked"':'',' name="emailme"><label for="checkbox_emailme">Оповестить об ответе на e-mail</label></div>
			<div class="left"></div>
			<div class="middle"></div>
			<div class="right"></div>
			<div class="bottomleft"></div>
			<div class="bottom"></div>
			<div class="bottomright"></div>
		</div>
	</span>
	<br clear="all">
	<div id="insert"></div>

	<span class="outgoing">
		<div class="message">
			<div class="topleft"></div>
			<div class="top"></div>
			<div class="topright"></div>
			<div class="bbody"><textarea cols="30" rows="15" name="question">Текст вопроса</textarea></div>
			<div class="left"></div>
			<div class="middle"></div>
			<div class="right"></div>
			<div class="bottomleft"></div>
			<div class="bottom"></div>
			<div class="bottomright"></div>
		</div>
	</span>
	<br clear="all">
	<div id="insert"></div>


		<button type="submit" style="margin-left: 58px">Задать вопрос</button>
	</form>
	<script>
	$("[name=\'username\']").css("color","#777777")
	$("[name=\'email\']").css("color","#777777")
	$("[name=\'question\']").css("color","#777777")
	
	$("[name=\'username\']").focus( function()
	{
		if ($(this).attr(\'value\') == \'Ваше имя\')
		{
			$(this).attr(\'value\',\'\')
			$(this).css("color", "#000000")
		}
	}
	)
	$("[name=\'username\']").blur( function()
	{
		if (!$(this).attr(\'value\'))
		{
			$(this).attr(\'value\',\'Ваше имя\')
			$(this).css("color", "#777777")
		}
	}
	)


	$("[name=\'email\']").focus( function()
	{
		if ($(this).attr(\'value\') == \'Электронный адрес\')
		{
			$(this).attr(\'value\',\'\')
			$(this).css("color", "#000000")
		}
	}
	)
	$("[name=\'email\']").blur( function()
	{
		if (!$(this).attr(\'value\'))
		{
			$(this).attr(\'value\',\'Электронный адрес\')
			$(this).css("color", "#777777")
		}
	}
	)

	$("[name=\'question\']").focus( function()
	{
		if ($(this).get(0).value == "Текст вопроса")
		{
			$(this).get(0).value = ""
			$(this).css("color", "#000000")
		}
	}
	)
	$("[name=\'question\']").blur( function()
	{
		if ($(this).get(0).value == "")
		{
			$(this).get(0).value = "Текст вопроса"
			$(this).css("color", "#777777")
		}
	}
	)
	</script>
	';
	
	return;
}

sub site_preview
{
	my $o = shift;
	
	print
	'
		<div class="theme-rpeview">
			<div class="name">'.$o->site_aname().'</div>
			'.($o->{'descr'}?'<div class="desc">'.$o->{'desc'}.'</div>':'').'
		</div>
	';
	
	return;
}

1;
