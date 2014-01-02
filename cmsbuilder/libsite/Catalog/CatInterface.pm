# (с) Леонов П.А., 2005

package plgnCatalog::Interface;
use strict qw(subs vars);
use utf8;
use CMSBuilder;

sub _template_export {qw(cat_content prices)}
sub _rpcs {qw(cat_content)}
#———————————————————————————————————————————————————————————————————————————————

sub catalog_props
{
	my $o = shift;
	my $r = shift;
	
	my $p = $o->props();
	
	return '<div class="props">' . join('', map { '<div class="' . $_ . '">' . $o->{$_} . '</div>' } keys %$p) . '</div>',
}

sub catalog_preview_text
{
	my $o = shift;
	
	my $len = eval { $o->catalog_root->{'ptextlen'} } || 30;
	
	my $desc = $o->{'desc'};
	
	$desc =~ s/<.*?>/ /sg;
	$desc =~ s/&\w+;?/ /g;
	$desc =~ s/^\s+|\s+$//g;
	
	my @words = split /\s+/, $desc;
	
	$desc = join ' ', @words[0 .. $len-1];
	$desc =~ s/([\.\?\!]+$)|([\,\;\:\-]+$)/$1 || '…'/e || ($desc .= '…') if @words > $len;
	
	return $desc;
}

sub site_preview
{
	my $o = shift;
	
	my $photo_href;
	if ($o->{'smallphoto'} && $o->{'smallphoto'}->exists)
	{
		$photo_href = $o->{'smallphoto'}->href
	}
	elsif ((my $cr = $o->catalog_root)->{'shownophoto'})
	{
		$photo_href = $cr->{'nophotoimg'}->href;
	}
	my $photo = $photo_href ? '<a href="' . $o->site_href . '"><img class="photo" src="' . $photo_href . '"></a>' : undef;
	
	print
	'
		<div class="cat_block">
			<a class="cat_img" href="' . $o->site_href . '"><img alt="'.$o->site_name.'" src="'.$photo_href.'"></a>
			<div class="cat_descr">
				<h3><a href="'.$o->site_href.'">' . $o->site_aname . '</a></h3>
				<p>' . $o->catalog_preview_text(@_) . '</p>
				<span class="price">&nbsp;</span>
			</div>
		</div>
	';
	
	return;
}

sub catalog_currency
{
	my $o = shift;
	my $r = shift;
	
	return $o->{'currency'} || ($o->papa ? $o->papa->catalog_currency($r) : undef);
}

sub catalog_root
{
	my $o = shift;
	
	map { return $_ if $_->isa('modCatalog') } reverse $o->papa_path;
	return undef;
}

sub round
{
	my($number) = shift;
	return int($number + .5);
}

sub isTagged
{
	my $o = shift;
	my $tag = shift;
	
	return 1 unless $tag;
	
	my $tags;
	map {$tags .= $_->myurl} @{$o->{tag}};
	if ($tags =~ /$tag/)
	{
		return 1;
	}
	else
	{
		return;
	}
}

sub site_content
{
	my $o = shift;
	my $r = shift;
	my $count = shift;
	my $class = shift;
	$count = $o->len_relation('child') unless $count;
	my $inc = 0;
=head
if ($o->myurl=~/CatDir48/){
print $o->myurl;
my @wares=(cmsb_url('CatWareSimple3280'));
return;
}
else {
=cut
	my @wares; # = grep {!$_->{hidden}} $o->get_relation_interval(1,$count,'child');
#}
	#выводим теги, которые указаны у товаров данного каталога или раздела
 if ($ENV{'SERVER_NAME'} eq $CMSBuilder::Config::server_main){	
	print '<div class="clouds">';
} else {
	print '<ul class="tags">';
}
	my %clouds;
		
	# for my $to (@wares) #обрабатываем средствами билдера
	# {
	# 	my %tags = $to->get_tags;
	# 	for (keys %tags)
	# 	{
	# 		$clouds{$_} += 1;
	# 	}
	# }
	
	%clouds = $o->get_tags; # через SQL
if (0 && $o->myurl=~/CatDir48/){
#!!!
   my $dbh=$CMSBuilder::DBI::dbh->prepare('SELECT ID from dbo_CatWareSimple where PAPA_CLASS="CatDir" and PAPA_ID="48" limit 3');
   $dbh->execute();
   my @to;
   while (@to=$dbh->fetchrow_array()){
      push(@wares,CatWareSimple->new($to[0]));
   }
} else {
	@wares = grep {!$_->{hidden}} sort {$a->name cmp $b->name} $o->get_relation_interval(1,$count,'child');
}
	#рисуем кнопку псевдотег ВСЕ
	my $class;
	my $add;
	$class = 'class="current"' unless $r->{tag};
 if ($ENV{'SERVER_NAME'} eq $CMSBuilder::Config::server_main){
	print '<span style="font-size: ' . $CMSBuilder::Config::cloudFontSizeMax . 'px" ' . $class . '><a href="' . $o->site_href . '">Все</a></span>';
} else {
	$ENV{'REQUEST_URI'}=~/^([^\?]+)/;
	print '<li'.($r->{tag}?'':' class="sel"').'><a href="' . $1 . '"><span>Все</span></a></li>';
}
	for my $t (split(/ /,$r->{tag}))
	{
		@wares = grep {$_->isTagged($t)} @wares;
	}
	
	foreach my $tag (keys %clouds)
	{
		next unless cmsb_url($tag);
		my $min = $clouds{$tag};
		my $max = $clouds{$tag};
		foreach my $mo (keys %clouds)
		{
			if ($clouds{$mo} > $max)
			{
				$max = $clouds{$mo};
			}
			if ($clouds{$mo} < $min)
			{
				$min = $clouds{$mo};
			}
		}
		
		my $minSize = $CMSBuilder::Config::cloudFontSizeMin;
		my $maxSize = $CMSBuilder::Config::cloudFontSizeMax;
		my $fontSize;
		if ($min == $max)
		{
			$fontSize = round(($maxSize - $minSize) / 2 + $minSize);
		}
		else
		{
			$fontSize = round((( $clouds{$tag} - $min)/($max - $min)) * ($maxSize - $minSize) + $minSize);
		}
		$class = '';
		$add = '';
		
		my @tagwares = @wares; #здесь логика как мы показываем плюсики только у тех тегов, комбинация с которыми даст резулльтат not nul;
		@tagwares = grep {$_->isTagged($tag)} @tagwares;
		
		for my $t (split(/ /,$r->{tag}))
		{
			$class = ' class="'.($ENV{'SERVER_NAME'} eq $CMSBuilder::Config::server_main?'current':'sel').'"' if $tag eq $t;
			$add = '<a title="Добавить к условиям поиска" class="plusminus" href="?tag=' . cmsb_url($tag)->myurl . ' ' . $r->{tag} . '">+</a>' if $r->{tag} && scalar(@tagwares) > 0;
			$add = '' if $class;
		}
		
		my $tags = '';
		map { $tags .= ($tags ? ' ' : '' ) . $_ } grep { $_ ne $tag } split(/ /,$r->{tag});
		
		$add = '<a title="Убрать из условий поиска" class="plusminus" href="?tag=' . $tags . '">-</a>' if $r->{tag} && $class && scalar(split(/ /,$r->{tag})) > 1;
if ($ENV{'SERVER_NAME'} eq $CMSBuilder::Config::server_main){
		print '<span style="font-size: ' . $fontSize . 'px" ' . $class . '>' . $add . '<a title="Показать только эту категорию" href="?tag=' . $tag . '">' . cmsb_url($tag)->name . '</a></span>';
} else {
		print '<li'.$class.'><a href="?tag='.$tag.'"><span>'.cmsb_url($tag)->name.'</span></a><li>';
}
	}
	
	print ($ENV{'SERVER_NAME'} eq $CMSBuilder::Config::server_main?'</div>':'</ul>');
	
	#################################

	# for my $t (split(/ /,$r->{tag}))
	# {
	# 	@wares = grep {$_->isTagged($t)} @wares;
	# }
if ($ENV{SERVER_NAME} eq $CMSBuilder::Config::server_main){	
	print '<div class="catalog" id="divCatalog">
							<img src="/i/cat-lt.png" class="cat_corners" style="left: -1px; top: -1px;" alt="" />
							<img src="/i/cat-rt.png" class="cat_corners" style="right: -1px; top: -1px;" alt="" />
							<img src="/i/cat-lb.png" class="cat_corners" style="left: -1px; bottom: -1px;" alt="" />
							<img src="/i/cat-rb.png" class="cat_corners" style="right: -1px; bottom: -1px;" alt="" />
							<h1>' . $o->name . '</h1>';
}	
	for (@wares)
	{
		$inc++;
		if (($inc+2) % 3 == 0)
		{
if ($ENV{'SERVER_NAME'} eq $CMSBuilder::Config::server_main){
			print '<div class="cat_container" ' . ($class ? $class : '') . '>';
} else {
			print '<div class="container">';
}
			print '' . ($wares[$inc-1]) ? $wares[$inc-1]->site_preview : '' . '';
			print '' . ($wares[$inc]) ? $wares[$inc]->site_preview : '' . '';
			print '' . ($wares[$inc+1]) ? $wares[$inc+1]->site_preview : '' . '';
			print '</div>';
if ($ENV{'SERVER_NAME'} eq $CMSBuilder::Config::server_main){
			print '<div class="cat_line"></div>' if ($inc+2) < @wares;
}		}
	}
	
	print ($ENV{'SERVER_NAME'} eq $CMSBuilder::Config::server_main?'</div>':'').'
		<div class="description">' . $o->{desc} . '</div>';
	
	return;
}



1;
