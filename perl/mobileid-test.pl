#!/usr/bin/perl

use utf8;
use mobileid;

#mobileid::trace_on();
mobileid::trace_request_on();

select STDERR; $| = 1;
select STDOUT; $| = 1;

$CERT_FILE = 'mycert.crt';
$KEY_FILE  = 'mycert.key';
$CA_FILE   = 'swisscom-ca.crt';

$APID      = 'mid://dev.swisscom.ch';
$APPASS    = 'disabled';

$MSISDN    = '+41000092401';
$MESSAGE   = 'Login?';
$LANG      = 'en';

$mssapi = new mobileid;
$mssapi->setssl($CERT_FILE, $KEY_FILE, $CA_FILE);
$mssapi->setapinfo($APID, $APPASS);

my $rc = $mssapi->MSS_Signature($MSISDN, $MESSAGE, $LANG, 70);
print("\nResult: $rc \n");
$mssapi = undef;

exit 0;