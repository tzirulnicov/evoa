package Tag;
use strict qw(subs vars);
use utf8;

our @ISA = qw(CMSBuilder::DBI::Object plgnSite::Member);

sub _cname {'Тег'}
sub _aview {qw(name desc days)}
sub _have_icon {1}
use CMSBuilder;
sub _props
{
	name		=> { type => 'string', length => 100, 'name' => 'Название' },
	desc		=> { 'type' => 'miniword', 'name' => 'Описание' },
	days		=> {type => 'int', 'name' => 'На сколько дней присваивается тег (0 — бесконечно)' }
}

sub _template_export {qw(site_title block_content block_content_rand)}

#———————————————————————————————————————————————————————————————————————————————
sub site_title
{
	my $o = shift;
	
	if($o->{'title'}){ print $o->{'title'}; return; }
	
	my $ttl = $o->site_name();
	my $gttl = modSite->new(1)->{'title'};
	
	print $gttl?"$ttl — $gttl":$ttl;
	
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
	<legend onmousedown="ShowHide(aview_tags,treenode_aview_tags)"><span class="objtbl"><img class="ticon" id="treenode_aview_tags" src="img/'.($dsp?'minus':'plus').'.gif"><span class="subsel">Список страниц, использующих тег</span></span></legend>
	<div class="padd" id="aview_tags" style="display:'.($dsp?'block':'none').'">
	';


	my @pagea = $o->get_relation_interval(1,$o->len_relation('tag'),'tag');

	print 'Всего страниц: ' . $o->len_relation('tag');

	if(@pagea)
	{
		print '<table class="admin_array_view"><tr><td>&nbsp;</td></tr>';

		for my $e (@pagea)
		{
			unless($o->access('r')){ next; }

			print '<tr><td>';

			print $e->admin_name;

			print '</td></tr>';
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
=head
#27.12.2009 - old version
sub block_content_rand{
        my $o = shift;
        my $r = shift;
	my $count=2;
	my $group=shift;
        my $inc = 0;
	my @ware;
        my $dbh=$CMSBuilder::DBI::dbh->prepare('SELECT ID from
                dbo_CatWareSimple where name like "'.$group.'%"
                and tag like "%Tag'.$o->{ID}.'%" order by rand() limit 2');
        $dbh->execute();
        while (@ware=$dbh->fetchrow_array)
        {
           $inc++;
	   print '</div>' if (($inc%2) && $inc!=1);
	   print '<div class="container">' if ($inc%2);
	   cmsb_url('CatWareSimple'.$ware[0])->site_preview($count);
        }
        print '</div>';
        return;
}
=cut
sub block_content_rand{
        my $o = shift;
        my $r = shift;
        my $count=shift;
        my $class=shift;
        my $inc = 0;
        my (@ware,@wares);
        my $dbh=$CMSBuilder::DBI::dbh->prepare('SELECT ID from
                dbo_CatWareSimple where tag like "%Tag'.$o->{ID}.'%" order by rand() limit ?');
        $dbh->execute($count);
        while (@ware=$dbh->fetchrow_array)
        {
		push(@wares,cmsb_url('CatWareSimple'.$ware[0]));
	}
	map{
                $inc++;
                if (($inc+2) % 3 == 0)
                {
                        print '<div class="cat_container ' . ($class ? $class : '') . '">';
                        print '' . ($wares[$inc-1]) ? $wares[$inc-1]->site_preview($count) : '' . '';
                        print '' . ($wares[$inc]) ? $wares[$inc]->site_preview($count) : '' . '';
                        print '' . ($wares[$inc+1]) ? $wares[$inc+1]->site_preview($count) : '' . '';
                        print '</div>';
                        print '<div class="cat_line"></div>' if ($inc+2) < @wares;
                }

        } @wares;
        print '</div>';
        return;
}

sub block_content
{
	my $o = shift;
	my $r = shift;
	my $count = shift;
	my $class = shift;
	$count = $o->len_relation('tag') unless $count;
	
	my $inc = 0;
	my @wares = grep {!$_->{hidden}} sort {$a->name cmp $b->name} $o->get_relation_interval(1,$count,'tag');
	for (@wares)
	{
		$inc++;
if ($ENV{'SERVER_NAME'} eq 'qiid.ru'){
		if (($inc+2) % 3 == 0)
		{
			print '<div class="cat_container ' . ($class ? $class : '') . '">';
			print '' . ($wares[$inc-1]) ? $wares[$inc-1]->site_preview($count) : '' . '';
			print '' . ($wares[$inc]) ? $wares[$inc]->site_preview($count) : '' . '';
			print '' . ($wares[$inc+1]) ? $wares[$inc+1]->site_preview($count) : '' . '';
			print '</div>';
			print '<div class="cat_line"></div>' if ($inc+2) < @wares;
		}
} else {
   print '<div class="container">' if $inc==1;
   $wares[$inc-1]->site_preview($count);
   print '</div>' if $inc==@wares;
}
	}
	
	return;
}

sub site_content
{
	my $o = shift;
	my $r = shift;
	my $count = shift;
	my $class = shift;
	
	$count = $o->len_relation('tag') unless $count;
	
	my $inc = 0;
	my @wares = grep {!$_->{hidden}} sort {$a->name cmp $b->name} $o->get_relation_interval(1,$count,'tag');
	
	$o->papa->site_content($r);
	
	print '<div class="catalog">
							<img src="/i/cat-lt.png" class="cat_corners" style="left: -1px; top: -1px;" alt="" />
							<img src="/i/cat-rt.png" class="cat_corners" style="right: -1px; top: -1px;" alt="" />
							<img src="/i/cat-lb.png" class="cat_corners" style="left: -1px; bottom: -1px;" alt="" />
							<img src="/i/cat-rb.png" class="cat_corners" style="right: -1px; bottom: -1px;" alt="" />
							';
	
	for (@wares)
	{
		$inc++;
		if (($inc+2) % 3 == 0)
		{
			print '<div class="cat_container ' . ($class ? $class : '') . '">';
			print '' . ($wares[$inc-1]) ? $wares[$inc-1]->site_preview : '' . '';
			print '' . ($wares[$inc]) ? $wares[$inc]->site_preview : '' . '';
			print '' . ($wares[$inc+1]) ? $wares[$inc+1]->site_preview : '' . '';
			print '</div>';
			print '<div class="cat_line"></div>' if ($inc+2) < @wares;
		}
	}
	
	print '</div>
		<div class="description">' . $o->{desc} . '</div>';
	
	return;
}

sub site_flatlist
{
	my $o = shift;
	my $r = shift;
	my $bullet = shift;

	my $mobj = $r->info->{'main_obj'};
	
	print '<ul>';
	for my $t ($o->get_relation_interval(1,$o->len_relation('tag'),'tag'))
	{
		print '<li class="' . ($mobj->isapapa($t) ? 'selected' : 'important') . '">' . $bullet . ($mobj->isapapa($t) ? $t->site_name : $t->site_aname) . '</li>'
	}
	print '</ul>';
	
	return;
}

1;
