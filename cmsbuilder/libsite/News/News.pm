# (с) Леонов П.А., 2005

package News;
use strict qw(subs vars);
use utf8;

our @ISA = ('plgnSite::Object','CMSBuilder::DBI::Object');

sub _cname {'Новость'}
sub _aview {qw/name content ndate/}
sub _have_icon {1}

sub _props
{
	'name'		=> { 'type' => 'string', 'length' => 100, 'name' => 'Заголовок' },
	'content'	=> { 'type' => 'miniword', 'name' => 'Текст' },
	'ndate'		=> { 'type' => 'date', 'name' => 'Дата' }
}

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder::Utils;

sub site_content
{
	my $o = shift;
	
	print
	$o->{'content'};
	return;
}

sub site_preview
{
	my $o = shift;
	
	my $text = $o->papa->{'blockfull'} ? $o->{'content'} : $o->preview_text;
	my $more = $o->papa->{'blockfull'} ? '' : '<div class="more"><a href="' . $o->site_href . '">Подробнее...</a></div>';
	
	print
		toDateStr($o->{'ndate'}),'<br/>
			<a href="' . $o->site_href . '">',$text,'</a>
			',$more;
	
	return;
}

sub preview_text
{
	my $o = shift;
	
	my $desc = $o->{'content'};
	$desc =~ s/<.*?>/ /sg;
	$desc =~ s/&nbsp;?/ /g;
	$desc =~ s/^\s+|\s+$//g;
	
	my @words = split /\s+/, $desc;
	
	$desc = join ' ',@words[0..30];
	$desc =~ s/([\.\?\!]+$)|([\,\;\:\-]+$)//;
	
	return $desc.(@words>10 && !$1?'...':'');
}

1;