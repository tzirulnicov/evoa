﻿# (с) Леонов П.А., 2006

package Page;
use strict qw(subs vars);
use utf8;

our @ISA = qw(plgnSite::Member CMSBuilder::DBI::Array);

sub _cname {'Страница'}
sub _aview {qw(name content submenu)}
sub _have_icon {1}

sub _props
{
	name		=> { type => 'string', length => 100, 'name' => 'Название' },
	content	=> { type => 'miniword', name => 'Текст' },
	submenu	=> { type => 'select', variants => [ {before => 'выводить перед текстом'}, {after => 'выводить после текста'}, {no => 'не выводить'}, {only => 'выводить без текста'} ], name => 'Вложенные страницы' },
	script => { type => 'html', name => 'Скрипты' },
}

#———————————————————————————————————————————————————————————————————————————————


# sub site_content
# {
# 	my $o = shift;
# 	my $r = shift;
# 	
# 	if($o->{'submenu'} eq 'only')
# 	{
# 		$o->site_submenu($r);
# 		print $o->{'script'};
# 	}
# 	elsif($o->{'submenu'} eq 'after')
# 	{
# 		print $o->{'content'} . $o->{'script'};
# 		$o->site_submenu($r);
# 	}
# 	elsif($o->{'submenu'} eq 'before')
# 	{
# 		$o->site_submenu($r);
# 		print $o->{'content'} . $o->{'script'};
# 	}
# 	else
# 	{
# 		print $o->{'content'} . $o->{'script'};
# 	}
# 	
# 	return;
# }

1;
