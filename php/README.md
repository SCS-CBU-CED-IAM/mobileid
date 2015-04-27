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
* mobileid.wsdl

## Client based certificate authentication

The file that must be specified in the initialisation refers to the local_cert and must contain both certificates, privateKey and publicKey in the same file (`cat mycert.crt mycert.key > mycertandkey.crt`).

Example of content:
````
-----BEGIN CERTIFICATE-----
...
-----END CERTIFICATE-----
-----BEGIN PRIVATE KEY-----
...
-----END PRIVATE KEY-----
````

Important notice: please review the content of your `mycertandkey.crt` file and be sure that the `-----BEGIN PRIVATE KEY-----` is starting on a new line.

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
$apid       = 'mid://myid';
$appwd      = 'disabled';

/* New instance of the Mobile ID class */
$mobileID = new mobileid($apid, $appwd, $certandkey, $ca_ssl);

$msisdn = '+41791234567';
$message = 'Login?';
$language = 'en';

/* MSS_ProfileQuery */ 
echo('== MSS_ProfileQuery ==' . PHP_EOL);
$status = $mobileID->profileQuery($msisdn);
echo('Status Code: ' . $mobileID->statuscode . PHP_EOL);
echo('Status Message: ' . $mobileID->statusmessage . PHP_EOL);
if (! $status) {
  echo('Status detail: ' . $mobileID->statusdetail . PHP_EOL);
  echo('User assistance: ' . $mobileID->getUserAssistance('', false) . PHP_EOL);
}

/* MSS_Signature */
echo('== MSS_Signature ==' . PHP_EOL);
$status = $mobileID->signature($msisdn, $message, $language, $ca_mid);
echo('Status Code: ' . $mobileID->statuscode . PHP_EOL);
echo('Status Message: ' . $mobileID->statusmessage . PHP_EOL);
if ($status) {
  echo('Signer certificate: ' . PHP_EOL . $mobileID->mid_certificate);
  echo('MID serial number: ' . $mobileID->mid_serialnumber . PHP_EOL);
} else {
  echo('Status detail: ' . $mobileID->statusdetail . PHP_EOL);
  echo('User assistance: ' . $mobileID->getUserAssistance('', false) . PHP_EOL);
  echo('Subscriber Info: 1901=' . $mobileID->getSubscriberInfo('1901'));
}

/* MSS_Receipt */ 
if ($status) {
  echo('== MSS_Receipt ==' . PHP_EOL);
  $status = $mobileID->receipt($msisdn, $mobileID->getLastMSSPtransID(), 'Temporary Password: ZX67!', $language, $mobileID->mid_certificate);
  echo('Status Code: ' . $mobileID->statuscode . PHP_EOL);
  echo('Status Message: ' . $mobileID->statusmessage . PHP_EOL);
  if (! $status) {
    echo('Status detail: ' . $mobileID->statusdetail . PHP_EOL);
  }
}

?>
````
