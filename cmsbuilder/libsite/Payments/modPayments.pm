package modPayments;
use strict qw(subs vars);
use utf8;

our @ISA = qw(plgnSite::Object CMSBuilder::DBI::TreeModule);

our $VERSION = 1.0.0.0;

sub _cname {'Платежи'}
sub _aview {qw(name wmpurse)}
sub _add_classes {qw(Payment)}
sub _have_icon {0}

sub _props
{
	'wmpurse'		=> { 'type' => 'string', 'name' => 'Номер кошелька WebMoney' }
}


#———————————————————————————————————————————————————————————————————————————————

use CMSBuilder;
use CMSBuilder::Utils;
use CMSBuilder::IO;

sub install_code
{
}

sub site_content
{
	my $o = shift;
	my $r = shift;
	
	if ($r->{'type'} eq 'webmoney')
		{
			if ($ENV{QUERY_STRING} eq 'success')
			{
				print 'cool';
				return;
			}
		
			if ($ENV{QUERY_STRING} eq 'fail')
			{
				return;
			}
			
			return if $ENV{QUERY_STRING};
			return if $r->{'LMI_PREREQUEST'};
			my $checkhash = MD5($r->{'LMI_PAYEE_PURSE'} . $r->{'LMI_PAYMENT_AMOUNT'} . $r->{'LMI_PAYMENT_NO'} . $r->{'LMI_MODE'} . $r->{'LMI_SYS_INVS_NO'} . $r->{'LMI_SYS_TRANS_NO'} . $r->{'LMI_SYS_TRANS_DATE'} . 'gammadelta' . $r->{'LMI_PAYER_PURSE'} . $r->{'LMI_PAYER_WM'}); #$r->{'LMI_SECRET_KEY'}
			return if uc ($checkhash) ne $r->{'LMI_HASH'};
			cmsb_url($r->{'payment'})->{'status'} = 'pass';
			cmsb_url($r->{'payment'})->{'customer'} = $r->{'LMI_PAYER_PURSE'} . ' (' . $r->{'LMI_PAYER_WM'} . ')';
			cmsb_url($r->{'payment'})->{'type'} = 'webmoney';
			cmsb_url($r->{'payment'})->save();
			return;
		}
}

1;