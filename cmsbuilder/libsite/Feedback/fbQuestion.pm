﻿# (с) Токмаков А. И., 2006

package fbQuestion;
use strict qw(subs vars);
use utf8;

our @ISA = ('plgnSite::Object','CMSBuilder::DBI::Object');

sub _cname {'Вопрос'}
sub _aview {qw/username email emailme question answer emailed/}

sub _props
{
	'username'		=> { 'type' => 'string', 'length' => 20, 'name' => 'Имя пользователя'},
	'email'			=> { 'type' => 'string', 'length' => 50, 'name' => 'E-mail' },
	'emailme'		=> { 'type' => 'checkbox', 'name' => 'Сообщить об ответе на e-mail' },
	'emailed'		=> { 'type' => 'checkbox', 'name' => 'Уведомление отправлено' },
	'question'		=> { 'type' => 'text', 'name' => 'Ваш вопрос' },
	'answer'		=> { 'type' => 'text', 'name' => 'Ответ' }
}

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder::Utils;
use CMSBuilder::IO::Session;

sub _have_icon 
{
	my $o = shift;
	
	return $o->{'answer'}?'icons/fb_quest.gif':'icons/fb_quest_new.gif';
}

sub name
{
	my $o = shift;
	return substr($o->{'question'},0,25).(length($o->{'question'})>25?'...':'');
}

sub site_head {}

sub admin_edit
{
	my $o = shift;
	my $r = shift;
	
	my $res = $o->SUPER::admin_edit($r,@_);
	
	if($o->{'emailme'} && $o->{'email'} && $o->{'answer'} && !$o->{'emailed'})
	{
		my $sended = sendmail
		(
			to		=> $o->{'email'},
			from	=> $o->root->{'email'},
			subj	=> '['.$o->root->{'bigname'}.'] Re: '.$o->papa()->name(),
			text	=> '<strong>Вопрос:</strong><p><dir>' . $o->{'question'} . '</dir></p><strong>Ответ:</strong><p><dir>' . $o->{'answer'} . '</dir></p> -- <p>Оригинал: <a href="' . $o->site_abs_href . '">' . $o->site_abs_href . '</a></p>',
			ct		=> 'text/html; charset=utf-8'
		);
		
		if($sended)
		{
			$o->notice_add('Пользователю отправлено уведомление.');
			$o->{'emailed'} = 1;
		}
		else
		{
			$o->err_add('Ошибка отправки уведомления.');
		}
	}
	
	$sess->{'admin_refresh_left'} = 1;
	
	return $res;
}
#-------------------------------------------------------------------------------
sub site_preview
{
	my $o = shift;
		
	$o->{'answer'} or return;
	
	print
	'
	<span class="incoming">
		<div class="sender">
			<div class="icon"><img src="/img/buddy_icon.png" alt="" width="32" height="32" onload="Reflection.add(this,null);" /></div>
			<div class="name">'.$o->{'username'}.'</div>
			<div class="service">Вопрос</div>
		</div>
		<div class="message">
			<div class="topleft"></div>
			<div class="top"></div>
			<div class="topright"></div>
			<div class="time">'.$o->{'CTS'}.'</div>
			<div class="bbody">'.$o->{'question'}.'</div>
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
		<div class="sender">
			<div class="icon"><img class="png" src="/img/ansicon.jpg" onload="Reflection.add(this,null);" /></div>
			<div class="name">Evoo</div>
			<div class="service">Ответ</div>
		</div>
		<div class="message">
			<div class="topleft"></div>
			<div class="top"></div>
			<div class="topright"></div>
			<div class="time">'.$o->{'ATS'}.'</div>
			<div class="bbody">'.$o->{'answer'}.'</div>
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
	';
	
	return;
}
#-------------------------------------------------------------------------------
sub site_content
{
	my $o = shift;
	return $o->site_preview(@_);
}
#-------------------------------------------------------------------------------
1;