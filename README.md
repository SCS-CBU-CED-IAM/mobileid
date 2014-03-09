mobileid-cmd
============

Mobile ID command line tools

## bash

Contains a script to invoke the:
* Signature Request
* Receipt Request
* Profile Query Request

```
Usage: ./mobileid-sign.sh <args> mobile "message" userlang <receipt>
  -v       - verbose output
  -d       - debug mode
  -e       - encrypted receipt
  mobile   - mobile number
  message  - message to be signed
  userlang - user language (one of en, de, fr, it)
  receipt  - optional success receipt message

  Example ./mobileid-sign.sh -v +41792080350 "Do you want to login to corporate VPN?" en
          ./mobileid-sign.sh -v +41792080350 "Do you want to login to corporate VPN?" en "Successful login into VPN"
          ./mobileid-sign.sh -v -e +41792080350 "Do you need a new password?" en "Password: 123456"
```

```
Usage: ./mobileid-receipt.sh <args> mobile transID "message" <pubCert>
  -v       - verbose output
  -d       - debug mode
  mobile   - mobile number
  transID  - transaction id of the related signature request
  message  - message to be displayed
  pubCert  - optional public certificate file of the Mobile ID user to encode the message

  Example ./mobileid-receipt.sh -v +41792080350 h29ah1 "All fine"
          ./mobileid-receipt.sh -v +41792080350 h29ah1 "Password: 123456" /tmp/_tmp.8OVlwv.sig.cert

```

```
Usage: ./mobileid-query.sh <args> mobile
  -v       - verbose output
  -d       - debug mode
  mobile   - mobile number

  Example ./mobileid-query.sh -v +41792080350
````


The files `mycert.crt`and `mycert.key` are placeholders without any valid content. Be sure to adjust them with your client certificate content in order to connect to the Mobile ID service.

Refer to the "Mobile ID - SOAP client reference guide" document from Swisscom for more details.


Example of verbose outputs:
```
./mobileid-sign.sh -v +41792080350 "Hello" en
#MSS_Signature OK with following details and checks:
 1) Transaction ID : AP.TEST.34309.7311 -> same as in request
    MSSP TransID   : h2ecyu
 2) Signed by      : +41792080350 -> same as in request
 3) Signer         : subject= serialNumber=MIDCHE8Y440USXZ0,CN=MIDCHE3QWAXYEAA2:PN,C=CH
                     issuer= C=ch,O=Swisscom,OU=Digital Certificate Services,CN=Swisscom Rubin CA 2
                     validity= notBefore=Jan 22 20:41:19 2014 GMT notAfter=Jan 22 20:41:19 2017 GMT
                     CRL check= OK
                     OCSP check= good
 4) Signed Data    : Hello -> Decode and verify: success and same as in request
 5) Status code    : 500 with exit 0
    Status details : SIGNATURE
```

```
./mobileid-sign.sh -v +41792204080 "Hello" en
#MSS_Signature FAILED with mss:_105 (Unknown user) and exit 2

./mobileid-sign.sh -v +4179220408012312312 "Hello" en
#MSS_Signature FAILED with mss:_104 (Wrong SSL credentials) and exit 2

./mobileid-sign.sh -v +4179220408012312312 "Hello" en
#MSS_Signature FAILED with mss:_101 (Illegal msisdn) and exit 2

./mobileid-sign.sh -v +41792080350 "Hello" en
#MSS_Signature FAILED with mss:_401 (User Cancelled the request) and exit 2
```

```
./mobileid-sign.sh -v +41792080350 "Do you want to login to corporate VPN?" en "Successful login into VPN"
#MSS_Signature OK with following details and checks:
 1) Transaction ID : AP.TEST.13428.4428 -> same as in request
    MSSP TransID   : h2ed05
 2) Signed by      : +41792080350 -> same as in request
 3) Signer         : subject= serialNumber=MIDCHE8Y440USXZ0,CN=MIDCHE3QWAXYEAA2:PN,C=CH
                     issuer= C=ch,O=Swisscom,OU=Digital Certificate Services,CN=Swisscom Rubin CA 2
                     validity= notBefore=Jan 22 20:41:19 2014 GMT notAfter=Jan 22 20:41:19 2017 GMT
                     CRL check= OK
                     OCSP check= good
 4) Signed Data    : Do you want to login to corporate VPN? -> Decode and verify: success and same as in request
 5) Status code    : 500 with exit 0
    Status details : SIGNATURE
#MSS_Receipt OK with following details and checks:
 MSSP TransID   : h2ed05
 Status code    : 100 with exit 0
 Status details : REQUEST_OK
```

```
./mobileid-receipt.sh -v +41792080350 h2ed05 "Successful login into VPN"
#MSS_Receipt FAILED with mss:_101 (Receipt already sent for this transaction. Only one receipt allowed per transaction.) and exit 2

./mobileid-receipt.sh -v +41792080350 h2ed01 "Successful login into VPN"
#MSS_Receipt FAILED with mss:_101 (There is no such transaction.) and exit 2
```

````
 ./mobileid-query.sh -v +41792454029
#MSS_ProfileQuery OK with following details and checks:
 Status code    : 100 with exit 0
 Status details : REQUEST_OK
````

````
./mobileid-query.sh -v +41798440457
#MSS_ProfileQuery FAILED on +41798440457 with mss:_105 (UNKNOWN_CLIENT: User MSISDN unknown, no such user.) and exit 2
````

## freeradius

`mobileid-radius.sh` wrapper script for rlm_exec module and the Signature Request bash script.

Refer to the "Mobile ID - RADIUS integration guide" document from Swisscom for more details.


## powershell

Contains a script to invoke the Signature Request service.

Requires PowerShell 2.0 or higher as it contains an encapsulated C# class.
The code is unsigned and requires the `Set-ExecutionPolicy Unrestricted`.

The file `mycert.pfx ` is a placeholder without any valid content. Be sure to adjust it with your client certificate content in order to connect to the Mobile ID service. The file format is PKCS#12 without any password. For improved security, it is also possible to use a certificate with private key stored in the user certificate store. If you want to use a certificate from the Windows certificate store, please export the certificate as .CER file and configure the script to use the .CER file instead of the .PFX file.

Open tasks:
- Validation of the signature and certificate in the response
- Move from response exception error handling to proper error parsing

## java

Contains Java source code example based on SAAJ to invoke the Signature Request service.

The keystore file `keystore.jks` does not contain any keys. Be sure to adjust it with your client certificate content in order to connect to the Mobile ID service.

```
Usage: com.swisscom.mid.client.MobileidSign [OPTIONS]

Options:
  -v              - verbose output, parses response
  -d              - debug output, prints full request and response
  -config=VALUE   - custom path to properties file which will overwrite default path
  -msisdn=VALUE   - mobile number
  -message=VALUE  - message to be signed
  -language=VALUE - user language (en, de, fr, it)

Examples:
  java com.swisscom.mid.client.MobileidSign -v -d -msisdn=41791234567 -message="Do you want to login?" -language=en
  java -DproxySet=true -DproxyHost=10.185.32.54 -DproxyPort=8079 com.swisscom.mid.client.MobileidSign -v -d -msisdn=41791234567 -message="Do you want to login?" -language=en
  java -Djavax.net.debug=all -Djava.security.debug=certpath com.swisscom.mid.client.MobileidSign -v -d -msisdn=41791234567 -message="Do you want to login?" -language=en
  java com.swisscom.mid.client.MobileidSign -v -d -config=c:/mobileid.properties -msisdn=41791234567 -message="Do you want to login?" -language=en
```

Open tasks:
- Add JAX-WS example client

## Known issues

**OS X 10.x: Requests always fail with MSS error 104: _Wrong SSL credentials_.**

The `curl` shipped with OS X uses their own Secure Transport engine, which broke the --cert option, see: http://curl.haxx.se/mail/archive-2013-10/0036.html

Install curl from Mac Ports `sudo port install curl` or home-brew: `brew install curl && brew link --force curl`.

