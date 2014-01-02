$start=$$;
print "now start $$...\n";
#`perl 123.pl&`;
close(STDOUT);
`perl 123.pl`;
=head
print "non-flying weather" unless defined($fpid=fork);
print "ok $$&$fpid\n";
if ($start!=$$){
print "new process\n";
`perl 123.pl`;
print "lala\n";
} else {print "current process\n";}
exit;
=cut
