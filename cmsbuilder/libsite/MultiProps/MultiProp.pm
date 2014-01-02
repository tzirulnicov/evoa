package MultiProp;
use strict qw(subs vars);
use utf8;

our @ISA = qw(CMSBuilder::DBI::Object);

sub _cname {'Строка'}

sub _props
{
	name		=> { type => 'string', name => 'Имя' },
	value		=> { type => 'string', name => 'Значение'},
	desc		=> { type => 'miniword', 'name' => 'Описание' },
}

sub _aview {qw(name value desc)}

#———————————————————————————————————————————————————————————————————————————————

sub admin_prop_save
{
	my $o = shift;
	my $r = shift;
	
	$o->{value} = $r->{$o->{name}};
	$o->save();
}

sub admin_prop_view
{
	my $o = shift;
	
	return '<input class="winput" type=text name="' . $o->{name} . '" value="' . $o->{value} . '">';
}

sub admin_prop_add
{
	my $c = shift;
	
	return '<input class="winput" type=text name="" value="">';
}


1;