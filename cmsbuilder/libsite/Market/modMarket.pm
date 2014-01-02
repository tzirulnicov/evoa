# (с) Леонов П.А., 2006

package modMarket;
use strict qw(subs vars);
use utf8;

our @ISA = qw(CMSBuilder::DBI::TreeModule);

our $VERSION = 1.0.0.0;

sub _cname {'Маркет'}
sub _aview {qw(name namename company address)}
sub _add_classes {qw/ExportList/}
sub _have_icon {0}

sub _props
{
	namename	=> { type => 'string', length => 20, 'name' => 'Название магазина' },
	company		=> { type => 'string', length => 100, 'name' => 'Компания' },
	address		=> { type => 'string', length => 100, 'name' => 'URL-адрес главной страницы магазина' }
}

#———————————————————————————————————————————————————————————————————————————————

sub install_code
{
	my $mod = shift;
	
	my $mr = modRoot->new(1);
	
	my $to = $mod->cre();
	$to->{'name'} = $mod->cname();
	$to->save();
	
	$mr->elem_paste($to);
}

sub admin_view
{
	my $o = shift;
	
	$o->SUPER::admin_view(@_);

# print CatWareSimple->new(1539)->papa->admin_name;	
	$o->admin_tags();
}

sub admin_tags
{
	my $o = shift;
	my $r = shift;
	
	print '<link href="/themes/blue/style.css" rel="stylesheet" type="text/css" />
	<script language="JavaScript" src="/jquery.js"></script>
	<script language="JavaScript" src="/tablesorter.js"></script>
	<script language="JavaScript" src="/metadata.js"></script>
	<script language="JavaScript" src="/script.js"></script>
	';
	
	print '<table class="tablesorter">
				<thead>
			    <tr>
			        <th style="width: 10%">Категория</th>
			        <th>Модель</th>
			        <th>Стоимость</th>
					<th>Bid</th>
					<th>CBid</th>
			        ';
			
			map {print '<th>' . $_->name . '</th>' } $o->get_all;
			
			print	'<th style="width: 30px" class="{sorter: false}"></th>
			    </tr></thead><tbody>';
			
			for my $to (CatWareSimple->sel_where(' 1 '))
			{
				print '<tr>
					<form id="' . $to->myurl . '">
			        <td style="font-size: 9px">' . ($to->papa ? '<a href="' . $to->papa->admin_right_href() . '">' . $to->papa->name . '</a>' : '') . '</td>
			        <td><a href="' . $to->admin_right_href() . '">' . $to->name . '</a></td>
			        <td><span style="display:none">' . $to->{price} . '</span>' . $to->show_prop($r, qw/price/) . '</td>
					<td><span style="display:none">' . $to->{bid} . '</span>' . $to->show_prop($r, qw/bid/) . '</td>
					<td><span style="display:none">' . $to->{cbid} . '</span>' . $to->show_prop($r, qw/cbid/) . '</td>';
		
				map { print '<td><input type="checkbox" name="' . $_->myurl . '" ' . $to->checked($_->myurl) . '/><a style="font-size: 9px" href="' . $_->admin_right_href() . '">' . $_->name . '</a></td>' } $o->get_all;
				
				print	'<td><button onclick="saveWare(\'' . $to->myurl . '\'); return false;">Сохранить</button></td>
					</form>
			    </tr>';
			
			}
	
	print '</tbody></table>';
	print '<script>$("table.tablesorter").tablesorter()</script>';
	
	return;
}

1;