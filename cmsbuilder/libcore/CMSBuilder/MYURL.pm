# (с) Леонов П. А., 2005

package CMSBuilder::MYURL;
use strict qw(subs vars);
use utf8;

use CMSBuilder;
use CMSBuilder::IO;

sub process_request
{
	my $c = shift;
	my $r = shift;
	
	my $ri = $r->info;
	
	$ri->{path} =~ m/.*\/(.+?)\.(\w+)(\/.*)?/;
	my $myurl = $1;
	my $path = $2;
	
	$myurl =~ s#/#::#g;
	#----
	# $myurl = $CMSBuilder::Config::slashobj_myurl[0] if $ri->{path} eq '/';
	
#	if ($ri->{path} eq '/')
#				{ 
#					for my $to (@CMSBuilder::Config::slashobj_myurl)
#					{	
#						if (cmsb_url($to)->{address} eq $ENV{'SERVER_NAME'})
#						{
#							$myurl = $to;
#						}
#					}
#				}

        my ($tmp,$tmp2);

        if ($ri->{path} eq '/')
        {
                for my $to (@CMSBuilder::Config::slashobj_myurl)
                {
                        $tmp=cmsb_url($to)->{address};
                        $tmp=~s/^www\.//;
                        $tmp2=$ENV{'SERVER_NAME'};
                        $tmp2=~s/^www\.//;
                        if ($tmp eq $tmp2)
                        {
													 $myurl = $to;
												}
								}
				}
	
	
	#----
	my $obj = cmsb_url($myurl);

	return unless $obj;

	# Если у страницы есть ЧПУ урл, и по ней обращаются без ЧПУ - редиректим на урл с ЧПУ
  my $obj_url = $obj->site_href;
  if ( $ri->{path} ne $obj_url ){
  	 $headers{Status} = 301;
  	 $headers{Location} = $obj_url;
  	 return 1;
  }
#warn $obj->{my4} if $ENV{REQUEST_URI}=~/catwaresimple4609/i;

	$ri->{path} = $path;
	
	$ri->{'main_obj'} = $obj;

	$obj->site_page($r);
	
	return 1;
}


1;
