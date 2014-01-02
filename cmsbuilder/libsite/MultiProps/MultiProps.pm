# (с) Леонов П.А., 2005

package MultiProps;
use strict qw(subs vars);
use utf8;

use CMSBuilder;

sub _admin_right_panels {qw(admin_multiprops_view)}
sub _rpcs {qw(admin_multiprops_save admin_multiprops_add_prop)}

sub _props
{
	'multiprops'			=> { 'type' => 'object', 'class' => 'MultiPropsDir', 'name' => 'Свойства' },
}

#———————————————————————————————————————————————————————————————————————————————


sub mp_get
{
	my $o = shift;
	my $key = shift;
	
	map { return $_->{value} if $_->{name} eq $key } $o->{multiprops}->get_all;
	
	return;
}


sub admin_multiprops_add_prop
{
	my $o = shift;
	my $r = shift;
	
	do { print "<result><error>Не указано имя нового свойства.</error></result>"; return; } unless $r->{name};
	do { print "<result><error>Класс не публичный.</error></result>"; return; } unless cmsb_classOK($r->{class});
	
	my $to = $r->{class}->cre();
	$to->{name} = $r->{name};
	$o->{multiprops}->elem_paste($to);
	
	print
	'<result>
		<html><tr><td>' . $r->{name} . ':</td><td><input name="' . $r->{name} . '" class="winput"/></td></tr></html>
		<ok>Добавлено.</ok>
		<script>
		function (r)
		{
			var html = r.responseXML().getElementsByTagName("html")[0];
			var tbody = document.getElementById("multiprops_table").getElementsByTagName("tbody")[0];
			
			//tbody.appendChild(document.importNode(html, true));
			appendChildsContent(tbody, html);
			
			//alert(tbody.innerHTML);
		}
		</script>
	</result>';
}

sub admin_multiprops_save
{
	my $o = shift;
	my $r = shift;
	
	print '<result>';
	
	map { $_->admin_prop_save($r) } $o->{multiprops}->get_all();
	
	print '<ok>Данные успешно сохранены.</ok>';
	#print '<error>' . join(', ',%$r) . '</error>';
	
	print map {"<error>$_</error>"} $o->err_strs;
	
	print '</result>';
}

sub admin_multiprops_view
{
	my $o = shift;
	
	my $dsp = {CGI::cookie('admin_multiprops_view')}->{'s'};
	
	print
	'
	<fieldset><legend onmousedown="ShowHide(admin_multiprops_view,treenode_admin_multiprops_view)"/>
	<span class="objtbl"><img class="ticon" id="treenode_admin_multiprops_view" src="img/'.($dsp?'minus':'plus').'.gif"><span class="subsel">Индивидуальные свойства</span></span></legend>
	<div class="padd" id="admin_multiprops_view" style="display:'.($dsp?'block':'none').'">
	
	<form action="/srpc/' . $o->myurl . '/admin_multiprops_save" method="post" onsubmit="return ajax_form_send(event,this)">
	<table class="props_table" id="multiprops_table"><tbody>
	';
	
	for my $to ($o->{multiprops}->get_all()) #sort {$a->name cmp $b->name}
	{
		print '<tr><td width="20%">' . $to->name . ':</td><td>' . $to->admin_prop_view . '</td></tr>';
	}
	
	print
	'
	</tbody></table>
	<p align="center"><button type="submit" title="Сохранить изменения"><img src="icons/save.gif" /> Сохранить</button></p>
	</form>
	
	<div style="float:left;padding:1em">' . $o->{multiprops}->admin_multiprops_add_list . '</div>
	<div style="float:right;padding:1em"><small><a href="' . $o->{multiprops}->admin_right_href . '">Дополнительно...</a></small></div>
	
	</div>
	</fieldset>
	';
}

1;