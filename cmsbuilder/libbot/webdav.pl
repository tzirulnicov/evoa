use strict;
use HTTP::DAV;

$HTTP::DAV::DEBUG=3;
my $d = HTTP::DAV->new();
my $url = 'https://webdav.yandex.ru';
$d->credentials(
	-user => 'tzirulnicov',
	-pass => '',
	-url => $url,
#	-realm => 'DAV Realm',
);
warn 2222;
$d->open( -url => $url )
      or die("Couldn't open $url: " .$d->message . "\n");
warn 3333;
   if ( $d->put( -local => "price.xls", -url => $url ) ) {
      print "successfully uploaded multiple files to $url\n";
   } else {
      print "put failed: " . $d->message . "\n";
   }
