# (с) Леонов П. А., 2005

package CatUserOrders;
use strict qw(subs vars);
use utf8;

our @ISA = qw(plgnSite::Object CMSBuilder::DBI::TreeModule);

sub _cname {'Список заказов'}
#sub _aview {qw/name photo desc onpage previewtype/}
#sub _have_icon {1}

sub _add_classes {qw/!* CatOrder/}
sub _handle_elems {0}

sub _props
{
	
}

#———————————————————————————————————————————————————————————————————————————————


sub install_code {}
sub mod_is_installed {1}




1;