php-mobileid
============

Contains a PHP class for the Mobile ID service to invoke:

* Signature Request
* Receipt Request
* Profile Query Request

## Dependencies

The class is using:

* SoapClient class (http://www.php.net/manual/en/class.soapclient.php) in the WSDL mode
* OpenSSL package and class (http://www.php.net/manual/en/openssl.requirements.php)
* mobileid.wsdl (Version: mobileid-mss-wsdl-reduced_v2.6.wsdl, based on mink-kiuru-mss-wsdl-2014-05-08)

## Client based certificate authentication

The file that must be specified in the initialisation refers to the local_cert and must contain both certificates, privateKey and publicKey in the same file (`cat mycert.crt mycert.key > mycertandkey.crt`).

Example of content:
````
-----BEGIN PRIVATE KEY-----
...
-----END PRIVATE KEY-----
-----BEGIN CERTIFICATE-----
...
-----END CERTIFICATE-----
````


## Connection options

Proxy support by passing additional SoapClient options.

````
$myoptions = array(
    'proxy_host'     => "localhost",
    'proxy_port'     => 8080,
    'proxy_login'    => "some_name",
    'proxy_password' => "some_password"
);
$mobileID = new mobileid($apid, $appwd, $certandkey, $cafile, $myoptions);
````

Refer to the SoapClient::SoapClient options on http://www.php.net/manual/en/soapclient.soapclient.php

## Usage

Sample use of the class:

````
<?php
require_once dirname(__FILE__) . '/mobileid.php';
error_reporting(E_ALL);

/* Environment */
$certandkey = dirname(__FILE__) . '/mycertandkey.crt';
$ca_ssl     = dirname(__FILE__) . '/mobileid-ca-ssl.crt';
$ca_mid     = dirname(__FILE__) . '/mobileid-ca-signature.crt';
$apid       = 'mid://myid";
$appwd      = 'disabled';

/* New instance of the Mobile ID class */
$mobileID = new mobileid($apid, $appwd, $certandkey, $ca_ssl);

$msisdn = '+41791234567';
$message = 'Login?';
$language = 'en';

/* MSS_ProfileQuery */ 
echo('== MSS_ProfileQuery ==' . PHP_EOL);
$status = $mobileID->profileQuery($msisdn);
  var_dump($status, $mobileID->statuscode, $mobileID->statusmessage, $mobileID->statusdetail);

/* MSS_Signature */
echo('== MSS_Signature ==' . PHP_EOL);
$status = $mobileID->signature($msisdn, $message, $language, $ca_mid);
var_dump($status, $mobileID->statuscode, $mobileID->statusmessage, $mobileID->statusdetail);
if ($status)
  var_dump($mobileID->mid_certificate, $mobileID->mid_serialnumber);

/* MSS_Receipt */ 
if ($status) {
  echo('== MSS_Receipt ==' . PHP_EOL);
  $status = $mobileID->receipt($msisdn, $mobileID->getLastMSSPtransID(), 'Temporary Password', $language, $mobileID->mid_certificate);
  var_dump($status, $mobileID->statuscode, $mobileID->statusmessage, $mobileID->statusdetail);
}

?>
````
