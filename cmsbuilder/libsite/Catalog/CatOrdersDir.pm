# (с) Леонов П. А., 2005

package CatOrdersDir;
use strict qw(subs vars);
use utf8;

our @ISA = qw(plgnSite::Object CMSBuilder::DBI::TreeModule);

sub _cname {'Список заказов'}
sub _aview {qw(emails)}
#sub _have_icon {1}

sub _add_classes {qw/!* CatOrder/}

sub _props
{
	emails		=> { type => 'string', name => 'E-mail адреса администраторов'},
}

#———————————————————————————————————————————————————————————————————————————————


sub install_code {}

sub mod_is_installed {1}

sub site_content
{
	my $o = shift;
	my $r = shift;
	
	my @arr = $o->get_all();
	
	print '<fieldset class="neworders">
		<legend>Новые заказы</legend>';
		map { $_->site_preview } grep { !$_->{disp} } @arr;
	print '</fieldset>';
	
	print '<fieldset class="myorders">
		<legend>Текущие заказы</legend>';
		map { $_->site_preview } grep { $_->{disp} && $_->{status} eq 'active' } @arr;
	print '</fieldset>';
	
	print '<fieldset class="archorders">
		<legend>Архив заказов</legend>';
		map { $_->site_preview } grep { $_->{status} eq 'archive' } @arr;
	print '</fieldset>';

	return;
}


1;