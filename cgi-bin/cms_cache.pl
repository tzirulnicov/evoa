#!/usr/bin/perl
# Периодически удалять старый кеш по крону
use Compress::Zlib;
BEGIN {
   require '/www/evoo/evoo.ru/cmsbuilder/Config.pm';
#   use CMSBuilder::Config;
   push(@INC,$CMSBuilder::Config::path_cmsb.'/libbot/lib');
}

use IO::Socket::INET;
use CGI::Carp qw/fatalsToBrowser/;
use WWW::GET;
    "$ENV{DOCUMENT_ROOT}/9fc04f10ab06834c258690d413b5a3b4/SAPE.pm" =~ /^(.+)$/;
    require $1;
      $sape = new SAPE(
     user => '9fc04f10ab06834c258690d413b5a3b4',
     #host => '<ИМЯ_ХОСТА>', # необязательно, по умолчанию: $ENV{HTTP_HOST}
     charset => 'utf-8', # необязательно, по умолчанию: windows-1251
    );
   use constant LINKFEED_USER => "3b790774acdad3a09657911888bac34d1d0b3958";
   require "$ENV{DOCUMENT_ROOT}/".LINKFEED_USER."/linkfeed.pm";
   my  $linkfeed = LinkFeed->new('user' => LINKFEED_USER);
   my $html_sape;
print "Content-Encoding: gzip\n";
print "Content-Type: text/html\n\n";
my $file=$ENV{REQUEST_URI};
my $html;
my $sock=WWW::GET->new('qiid.ru');
$file=~s/^\///;
$file=~s/\//_/g;
my $read_from=0;
if (-e $CMSBuilder::Config::path_tmp.'/cache/'.$file){
   open(FILE,$CMSBuilder::Config::path_tmp.'/cache/'.$file);
   $html=join('',<FILE>);
   close(FILE);
}
else {
   $read_from=1;
$ENV{REQUEST_URI}='/catdir49.html' if $ENV{REQUEST_URI}=~/aviamodel/;
$ENV{REQUEST_URI}='/catdir48.html' if $ENV{REQUEST_URI}=~/avtomodel/;
$ENV{REQUEST_URI}='/catdir50.html' if $ENV{REQUEST_URI}=~/vertoleti/;
$ENV{REQUEST_URI}='/catdir52.html' if $ENV{REQUEST_URI}=~/dorogamodel/;
$ENV{REQUEST_URI}='/catdir51.html' if $ENV{REQUEST_URI}=~/sudomodel/;
$ENV{REQUEST_URI}='/modcatalog9.html' if $ENV{REQUEST_URI}=~/radiomodel/;
$ENV{REQUEST_URI}='/catdir1.html' if $ENV{REQUEST_URI}=~/nokia/;
$ENV{REQUEST_URI}='/catdir5.html' if $ENV{REQUEST_URI}=~/lg/;
$ENV{REQUEST_URI}='/catdir10.html' if $ENV{REQUEST_URI}=~/fly/;
$ENV{REQUEST_URI}='/catdir2.html' if $ENV{REQUEST_URI}=~/samsung/;
$ENV{REQUEST_URI}='/catdir6.html' if $ENV{REQUEST_URI}=~/moto/;
$ENV{REQUEST_URI}='/catdir4.html' if $ENV{REQUEST_URI}=~/sony/;
$ENV{REQUEST_URI}='/catdir7.html' if $ENV{REQUEST_URI}=~/philips/;
$ENV{REQUEST_URI}='/catdir8.html' if $ENV{REQUEST_URI}=~/kommunikatori/;
$ENV{REQUEST_URI}='/catdir35.html' if $ENV{REQUEST_URI}=~/aksessuari/;
$ENV{REQUEST_URI}='/catdir9.html' if $ENV{REQUEST_URI}=~/bluetooth/;
$ENV{REQUEST_URI}='/catdir53.html' if $ENV{REQUEST_URI}=~/bukety/;
$ENV{REQUEST_URI}='/catdir54.html' if $ENV{REQUEST_URI}=~/roses/;

#open(FILE,">>/www/evoo/evoo.ru/cmsbuilder/tmp/test2.log") or die $!;
#print FILE $ENV{REQUEST_URI}."\n";
#close(FILE);
   if (!$sock->get($ENV{REQUEST_URI}.'?cache_init',NoEncoding=>1)){
      print Compress::Zlib::memGzip($sock->{errmsg});
      exit;
   }
   $html=$sock->{net_http_content};
   $html=~s/(<div class\="catalog_mini_basket">).*?<\/div>(<\/div>)/\{\.show_basket\}\2/s;
   if ($html=~/<\/html>/i){
      open(FILE,'>'.$CMSBuilder::Config::path_tmp.'/cache/'.$file) or die $!;
      print FILE $html;
      close(FILE);
   }
}
%{$sock->{cookie_hash}}=();
if (!$sock->get('/srpc/modCatalog1/catalog_basket_html?cache_init',NoEncoding=>1,
	AddHeaders=>"Cookie: $ENV{HTTP_COOKIE}\r\n")){
   print Compress::Zlib::memGzip($sock->{errmsg});
   exit;
}
$html=~s/\{\.show_basket\}/$sock->{net_http_content}/;
while ($html=~/<\!\-\-SAPE(\d+)\-(\d+)\-\->.*?<\!\-\-\/\/SAPE\-\->/){
   $html_sape='<p style="margin-top:10px">'.$sape->get_links(count=>$1).$linkfeed->return_links($2);
   $html=~s/<\!\-\-SAPE$1\-$2\-\->.*?<\!\-\-\/\/SAPE\-\->/$html_sape/;
}
#print $html;
print Compress::Zlib::memGzip($html);
#."<br>\nRead from: ".($read_from?'builder':'cache'));

