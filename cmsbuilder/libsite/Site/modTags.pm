# (с) Леонов П.А., 2006

package modTags;
use strict qw(subs vars);
use utf8;

our @ISA = qw(plgnSite::Object CMSBuilder::DBI::TreeModule);

our $VERSION = 1.0.0.0;

sub _cname {'Теги'}
sub _aview {qw(name)}
sub _add_classes {qw(Tag)}
sub _have_icon {1}


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

sub round
{
	my($number) = shift;
	return int($number + .5);
}

sub site_content
{
	my $o = shift;
	my $r = shift;

	print '<div class="clouds">';
	
	foreach my $to (sort { $a->name cmp  $b->name} $o->get_all)
	{
		my $min = $to->len_relation('tag');
		my $max = $to->len_relation('tag');
		foreach my $mo ($o->get_all)
		{
			if ($mo->len_relation('tag') > $max)
			{
				$max = $mo->len_relation('tag');
			}
			if ($mo->len_relation('tag') < $min)
			{
				$min = $mo->len_relation('tag');
			}
		}
		
		my $minSize = $CMSBuilder::Config::cloudFontSizeMin;
		my $maxSize = $CMSBuilder::Config::cloudFontSizeMax;
		my $fontSize;
		my $class;
		if ($min == $max)
		{
			$fontSize = round(($maxSize - $minSize) / 2 + $minSize);
		}
		else
		{
			$fontSize = round((( $to->len_relation('tag') - $min)/($max - $min)) * ($maxSize - $minSize) + $minSize);
		}
		
		$class = 'class="current"' if $to->myurl eq $r->info->{'main_obj'}->myurl;
		print '<span style="font-size: ' . $fontSize . 'px" ' . $class . '>' . $to->site_aname . '</span>';
	}
	
	print '</div>';
}

1;