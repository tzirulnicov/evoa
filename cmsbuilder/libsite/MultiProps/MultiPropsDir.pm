package MultiPropsDir;
use strict qw(subs vars);
use utf8;

use CMSBuilder;

our @ISA = qw(CMSBuilder::DBI::Array);
sub _add_classes {qw(MultiProp)}

sub _cname {'Свойства'}

#———————————————————————————————————————————————————————————————————————————————

sub admin_multiprops_add_list
{
	my $o = shift;
	
	unless($o->access('a')){ return; }
	
	return '<form action="/srpc/' . $o->papa->myurl . '/admin_multiprops_add_prop" method="post" onsubmit="ret = ajax_form_send(event,this); this.name.value = \'\'; return ret">Тип:&nbsp;<select name="class">' . join
	(
		'',
		map { '<option value="' . $_ . '">' . $_->cname . '</option>' }
		grep { $o->elem_can_add($_) && !$_->one_instance } cmsb_classes()
	)
	. '</select>&nbsp;название:&nbsp;<input type="text" name="name">&nbsp;<button type="submit">Добавить...</button></form>';
}

1;