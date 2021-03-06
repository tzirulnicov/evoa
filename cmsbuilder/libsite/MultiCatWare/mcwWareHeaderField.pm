# (с) Токмаков А. И., 2006

package mcwWareHeaderField;
use strict qw(subs vars);
use utf8;

our @ISA = ('plgnSite::Object','CMSBuilder::DBI::Object');

sub _cname {'Параметр товара'}
sub _aview {qw/name value type/}
sub _props
{
	'name'			=> { 'type' => 'string', name => 'Параметр товара'},
	'value'			=> { 'type' => 'string', name => 'Значение(-я)'},
	'type'			=> { 'type' => 'select', name => 'Тип поля',
		variants=>[{text=>'Текст'},{checkbox=>'Чекбокс'},{list=>'Список'}]},
#	'username'		=> { 'type' => 'string', 'length' => 20, 'name' => 'Имя пользователя'},
#	'email'			=> { 'type' => 'string', 'length' => 50, 'name' => 'E-mail' },
#	'emailme'		=> { 'type' => 'checkbox', 'name' => 'Сообщить об ответе на e-mail' },
#	'emailed'		=> { 'type' => 'checkbox', 'name' => 'Уведомление отправлено' },
#	'question'		=> { 'type' => 'text', 'name' => 'Ваш вопрос' },
#	'answer'		=> { 'type' => 'text', 'name' => 'Ответ' }
}

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder::Utils;
use CMSBuilder::IO::Session;
sub admin_props{
   my $o=shift;
   my $r=shift;
=head
print '<table class="props_table">
			<tr>
			<td valign="top" width="20%" align="left"><label for="name">Название раздела полей</label>:</td>
			<td width="80%" align="left" valign="middle">
			<input class="winput" type=text name="name" value="">
			</td></tr>

			
			<tr>
			<td valign="top" width="20%" align="left"><label for="value">��������(-�)</label>:</td>
			<td width="80%" align="left" valign="middle">
			<input class="winput" type=text name="value" value="">
			</td></tr>
			
			<tr>
			<td valign="top" width="20%" align="left"><label for="type">��� ����</label>:</td>

			<td width="80%" align="left" valign="middle">
			<select name="type"><option value="text">�����</option><option value="checkbox">�������</option><option value="list">������</option></select>
			</td></tr>

</table>';
=cut
   $o->SUPER::admin_props($r,@_);
=head
   print '<table class="props_table">
                <tr>
                        <td valign="top" width="20%" align="left"><label for="name">Название</label>:</td>
                        <td width="80%" align="left" valign="middle">
                        <input class="winput" type=text name="name" value="'.$o->{name}.'">
                        </td></tr></table>';
   print '<table class="props_table" id="mcw_table"></table>';
   print '<span id="mcw_span"></span><input type="button" value="Добавить поле" onclick="mcw_add_field();">';
=cut
}
=head
sub _have_icon 
{
	my $o = shift;
	
	return $o->{'answer'}?'icons/fb_quest.gif':'icons/fb_quest_new.gif';
}
=cut
sub name
{
	my $o = shift;
	return substr($o->{'name'},0,25).(length($o->{'name'})>25?'...':'');
}

sub site_head {}

sub admin_edit
{
	my $o = shift;
	my $r = shift;
#foreach my $key(keys %{$r}){
#print $key."<br>";
#}
#print '<script>alert(123);</script>';
	
	my $res = $o->SUPER::admin_edit($r,@_);
	
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
