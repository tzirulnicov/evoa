package ExportList;
use strict qw(subs vars);
use utf8;
use cyrillic qw/utf2win/;
use Encode qw/_utf8_on/;
our @ISA = qw(CMSBuilder::DBI::Object);

sub _cname {'Список экспорта'}
sub _aview {qw(name)}
sub _have_icon {0}

sub _props
{
	name		=> { type => 'string', length => 100, 'name' => 'Название' }
}

sub _template_export {qw(site_title block_content)}

#———————————————————————————————————————————————————————————————————————————————

use CMSBuilder;
use CMSBuilder::IO;
use CMSBuilder::Utils;

sub _rpcs {qw(modsearch_search addwares removewares)}

sub addwares
{
	my $o = shift;
	my $r = shift;
	
	my @wares = split /\s* \s*/, $r->{q};

	for (@wares)
	{
		my $ware = cmsb_url($_);
		if ($ware)
		{
			$o->elem_relation_del($ware,'tag');
			$o->elem_relation_paste_ref($ware,'tag');
			my @a;
			for my $i (@{$ware->{exportto}})
			{
				push @a, $i if $i->myurl ne $o->myurl;
			}
			push @a, $o;
			$ware->{exportto} = [@a];
			$ware->save;
		}
	}
}

sub removewares
{
	my $o = shift;
	my $r = shift;
	
	my @wares = split /\s* \s*/, $r->{q};

	for (@wares)
	{
		my $ware = cmsb_url($_);
		if ($ware)
		{
			$o->elem_relation_del($ware,'tag');
			my @a;
			for my $i (@{$ware->{exportto}})
			{
				push @a, $i if $i->myurl ne $o->myurl;
			}
			$ware->{exportto} = [@a];
			$ware->save;
		}
	}
}

sub modsearch_search
{
	my $o = shift;
	my $r = shift;
	
	
	if($r->{'q'})
	{
		
		my @res;
		
		{
			my @keys = split /\s+/, $r->{'q'};
			map { push @res, $_->search(keys => [@keys]) } sort {$a->name cmp $b->name} grep { $_->isa('plgnCatalog::Ware') } cmsb_classes();
		}
		
		if(@res)
		{
			print map { '<option value="' . $_->myurl . '">' . $_->name . '</option>'} @res;
		}
	}
}

sub site_href
{
	my $o = shift;
	return '<a target="blank" href="/' . $o->myurl . '.xml">/' . $o->myurl . '.xml</a>';
}

sub site_page
{
	my $o = shift;
	my $r = shift;
	my $count = shift;
	my $class = shift;
	
	%headers =
	(
		'Content-type'		=> 'plain/xml',
		'Content-Disposition'	=> 'filename=price.xml'
	);
	
	$count = $o->len_relation('tag') unless $count;
	my $tmp;
	my @wares = grep {$_->{insight}} sort {$a->name cmp $b->name} $o->get_relation_interval(1,$count,'tag');	
	$tmp=utf2win('<?xml version="1.0" encoding="windows-1251"?>
	<!DOCTYPE yml_catalog SYSTEM "shops.dtd">
	<yml_catalog date="' . myNOWhm() . '">
	<shop>
	  <name>' . $o->papa->{namename} . '</name>
	  <company>' . $o->papa->{company} . '</company>
	  <url>' . $o->papa->{address} . '</url>

	<currencies>
		<currency id="RUR" rate="1"/>
	</currencies>
	<categories>
		<category id="1">'.'Сотовые телефоны'.'</category>');
	_utf8_on($tmp);
	print $tmp;
	my %catdirs=();
	my $tmp;
	my $num=1;
	foreach my $k (cmsb_url("modCatalog1")->get_all()){
	   $tmp=$k->name;
	   $tmp=~s/Мобильные телефоны //;
	   $tmp=utf2win($tmp);
	   _utf8_on($tmp);
	   $catdirs{$k->{ID}}=++$num;
	   print '<category id="'.$num.'" parentId="1">'.$tmp.'</category>';
	}
	print'</categories>
	<offers>';
	
	for (@wares)
	{
		$tmp=utf2win('<offer id="' . $_->{ID} . '" available="' . ($_->{insight} ? 'true' : 'false' ) . '"'.($_->{bid}?' bid="' . $_->{bid} . '"':'') . ($_->{cbid} ? ' cbid="' . $_->{cbid} . '"' : '') .'>
		  <url>' . modMarket->new(1)->{address} . $_->site_href . '</url>

		  <price>' . $_->{price} . '</price>
		  <currencyId>RUR</currencyId>
		  <categoryId>'.$catdirs{$_->papa->{ID}}.'</categoryId>
		  <picture>' . modMarket->new(1)->{address} . $_->{photo}->href . '</picture>
		  <delivery>true</delivery>
		  <name>' . $_->name . '</name>
		  <vendorCode>' . $_->{artikul} . '</vendorCode>
		  <description>' . $_->site_props . '</description>
		</offer>');
		_utf8_on($tmp);
		print $tmp;
	}
	
	print '</offers>
	</shop>
	</yml_catalog>';
	
	return;
}

sub admin_view
{
	my $o = shift;
	
	$o->admin_tags();
	
	$o->SUPER::admin_view(@_);
}

sub admin_tags
{
	my $o = shift;
	my $r = shift;

	unless($o->access('r')){ return; }

	my $dsp = {CGI::cookie('aview_tags')}->{'s'} eq '0'?0:1;

	print
	'
	<fieldset>
	<legend onmousedown="ShowHide(aview_tags,treenode_aview_tags)"><span class="objtbl"><img class="ticon" id="treenode_aview_tags" src="img/'.($dsp?'minus':'plus').'.gif"><span class="subsel">Список товаров</span></span></legend>
	<div class="padd" id="aview_tags" style="display:'.($dsp?'block':'none').'">
	';

	print '<script language="javascript" src="/jquery.js"></script>
	
	<input type="text" class="winput" id="search"></input>
	<select style="display: none; margin-top: 10px" size="20" class="winput" multiple="multiple" id="wares"></select>
	<button class="btn" onclick="addWares()">Добавить выделенные товары в список</button>
	<button class="btn" onclick="removeWares()">Удалить выбранные товары из списка</button>
	
	<script>
	
			var i;
			var str = "";
			
			function addWares()
			{
				if (!str) {return false}
				$("button.btn").removeAttr("disabled")
				$.get("/srpc/' . $o->myurl . '/addwares", { q: str },
				function(data)
				{
						parent.admin_right.location.reload()
				}
				)
			}
			
			function removeWares(what)
			{
				if (what) {str = what}
				if (!str) {return false}
				$("button.btn").removeAttr("disabled")
				$.get("/srpc/' . $o->myurl . '/removewares", { q: str },
				function(data)
				{
						parent.admin_right.location.reload()
				}
				)
			}
			
			function load()
			{
				clearInterval(i)
				$("input#search").addClass("loading")
				$.get("/srpc/' . $o->myurl . '/modsearch_search", { q: $("input#search").val() },
					function(data)
					{
						
						$("input#search").removeClass("loading")
						$("select#wares").html(data)
						if (data) { $("select#wares").slideDown(500); $("button.btn").removeAttr("disabled") }
					}
				 )
			}
			
			$(document).ready(function()
			{
				$("button.btn").attr("disabled","disabled")
				$("input#search").val("")
				$("input#search").keypress(
					function()
					{
						clearInterval(i)
						i = setInterval("load()",1000)
					}
				);
				
				$("select#wares").change(function () {
					str = "";
					$("select#wares option:selected").each(
						function ()
						{
							str += $(this).val() + " ";
						}
					);
				})
			});
	  </script>
	';
	
	my @pagea = $o->get_relation_interval(1,$o->len_relation('tag'),'tag');

	print 'Товаров в списке: ' . $o->len_relation('tag');

	if(@pagea)
	{
		print '<script language="JavaScript" src="/jquery.js"></script>
		<script language="JavaScript" src="/script.js"></script>
		<table class="admin_array_view mytable"><tr><td>&nbsp;</td><td>&nbsp;</td></tr>';

		for my $e (@pagea)
		{
			unless($o->access('r')){ next; }

			print '<tr><form id="' . $e->myurl . '"><td>';

			print '	<a href="' . $e->admin_right_href() . '">' . $e->name . '</a>';

			print '</td>
			<td align="right"><a href="#" style="color:red;" onclick="removeWares(\'' . $e->myurl . '\'); return false">' . ($e->{insight} ? 'Удалить' : '<strong>Нет в продаже</strong>, удалить?') . '&nbsp;</a>Цена: 
			' . $e->show_prop($r, qw/price/) . '
			 Bid: ' . $e->show_prop($r, qw/bid/) . ' CBid: ' . $e->show_prop($r, qw/cbid/) . '
			<input type="hidden" name="notags" value="1" />
			<button onclick="saveWare(\'' . $e->myurl . '\'); return false;">Сохранить</button></td></form></tr>';
			print "\n";
		}

		print '</table>';
	}
	else
	{
		print '<p align="center">Нет элементов.</p>';
	}

	print '</fieldset>';
}


1;
