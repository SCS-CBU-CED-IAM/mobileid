mobileid-cmd
============

Mobile ID command line tools

## Bash Scripts

The folder `bash` contains shell scripts to invoke a:
* Signature Request
* Receipt Request
* Profile Query Request

#### Configuration
The file `mobileid.properties` contains the most relevant configuration properties that need to be adjusted before the scripts are used.
Note that you will require the valid SSL certificate files `mycert.crt` and `mycert.key` in order to connect to the Mobile ID service.

For technical details about the Mobile ID Service refer to the "Mobile ID - Client Reference Guide" document from Swisscom (see http://goo.gl/FXIMEa).

#### Usage 
###### Signature Request
```
Usage: ./mobileid-sign.sh <args> mobile 'message' userlang <receipt>
  -t value   - message type (SOAP, JSON); default SOAP
  -v         - verbose output
  -d         - debug mode
  -e         - encrypted receipt
  mobile     - mobile number
  message    - message to be signed
  userlang   - user language (one of en, de, fr, it)
  receipt    - optional success receipt message

  Example ./mobileid-sign.sh -v +41792080350 'Do you want to login to corporate VPN?' en
          ./mobileid-sign.sh -t JSON -v +41792080350 'Do you want to login to corporate VPN?' en
          ./mobileid-sign.sh -v +41792080350 'Do you want to login to corporate VPN?' en 'Successful login into VPN'
          ./mobileid-sign.sh -v -e +41792080350 'Do you need a new password?' en 'Temporary password: 123456'
```

###### Receipt Request
```
Usage: ./mobileid-receipt.sh <args> mobile transID 'message' userlang <pubCert>
  -t value   - message type (SOAP, JSON); default SOAP
  -v         - verbose output
  -d         - debug mode
  mobile     - mobile number
  transID    - transaction id of the related signature request
  message    - message to be displayed
  userlang   - user language (one of en, de, fr, it)
  pubCert    - optional public certificate file of the mobile user to encode the message

  Example ./mobileid-receipt.sh -v +41792080350 h29ah1 'Successful login into VPN' en
          ./mobileid-receipt.sh -t JSON -v +41792080350 h29ah1 'Successful login into VPN' en
          ./mobileid-receipt.sh -v +41792080350 h29ah1 'Temporary password: 123456' en /tmp/_tmp.8OVlwv.sig.cert
```

###### Profile Query Request
```
Usage: ./mobileid-query.sh <args> mobile
  -t value   - message type (SOAP, JSON); default SOAP
  -v         - verbose output
  -d         - debug mode
  mobile     - mobile number

  Example ./mobileid-query.sh -v +41792080350
          ./mobileid-query.sh -t JSON -v +41792080350
````

#### Example Outputs (verbose mode)
###### Successful Signature

```
./mobileid-sign.sh -v +41791234567 'Do you want to login?' en
OK with following details and checks:
 1) Transaction ID : AP.TEST.21920.3921 -> same as in request
    MSSP TransID   : h4n9x
 2) Signed by      : +41791234567 -> same as in request
 3) Signer         : subject= serialNumber=MIDCHE97FQPL3SL3,CN=:PN,C=CH
                     issuer= C=ch,O=Swisscom,OU=Digital Certificate Services,CN=Swisscom Rubin CA 2
                     validity= notBefore=Mar 12 08:23:40 2014 GMT notAfter=Mar 12 08:23:40 2017 GMT
                     CRL check= OK
                     OCSP check= good
 4) Signed Data    : Do you want to login? -> Decode and verify: success and same as in request
 5) Status code    : 500 with exit 0
    Status details : SIGNATURE
```

###### Successful Signature + Receipt
```
./mobileid-sign.sh -v +41791234567 'Do you want to login to corporate VPN?' en 'Successful login into VPN'
OK with following details and checks:
 1) Transaction ID : AP.TEST.21920.3921 -> same as in request
    MSSP TransID   : h4n8o
 2) Signed by      : +41791234567 -> same as in request
 3) Signer         : subject= serialNumber=MIDCHE97FQPL3SL3,CN=:PN,C=CH
                     issuer= C=ch,O=Swisscom,OU=Digital Certificate Services,CN=Swisscom Rubin CA 2
                     validity= notBefore=Mar 12 08:23:40 2014 GMT notAfter=Mar 12 08:23:40 2017 GMT
                     CRL check= OK
                     OCSP check= good
 4) Signed Data    : Do you want to login to corporate VPN? -> Decode and verify: success and same as in request
 5) Status code    : 500 with exit 0
    Status details : SIGNATURE
OK with following details and checks:
 MSSP TransID   : h4n8o
 Status code    : 100 with exit 0
 Status details : REQUEST_OK
 User Response  : "status":"OK"    
```

###### Successful Profile Query
````
 ./mobileid-query.sh -v +41792454029
OK with following details and checks:
 Status code    : 100 with exit 0
 Status details : REQUEST_OK
````

###### Failed Signature
```
./mobileid-sign.sh -v +41792204080 'Hello' en
FAILED with mss:_105 (Unknown user) and exit 2

./mobileid-sign.sh -v +41792204080 'Hello' en
FAILED with mss:_104 (Wrong SSL credentials) and exit 2

./mobileid-sign.sh -v +4179220408012312312 'Hello' en
FAILED with mss:_101 (Illegal msisdn) and exit 2

./mobileid-sign.sh -v +41792080350 'Hello' en
FAILED with mss:_401 (User Cancelled the request) and exit 2
```

###### Failed Receipt
```
./mobileid-receipt.sh -v +41792080350 h2ed05 en 'Successful login into VPN'
FAILED with mss:_101 (Receipt already sent for this transaction. Only one receipt allowed per transaction.) and exit 2

./mobileid-receipt.sh -v +41792080350 h2ed01 en 'Successful login into VPN'
FAILED with mss:_101 (There is no such transaction.) and exit 2
```

###### Failed Profile Query
````
./mobileid-query.sh -v +41798440457
FAILED on +41798440457 with mss:_105 (UNKNOWN_CLIENT: User MSISDN unknown, no such user.) and exit 2
````

## FreeRADIUS

`mobileid-radius.sh` wrapper script for rlm_exec module and the Signature Request bash script.

Refer to the "Mobile ID - RADIUS integration guide" document from Swisscom for more details.


## PowerShell

Contains a script to invoke the Signature Request service.

Requires PowerShell 2.0 or higher as it contains an encapsulated C# class.
The code is unsigned and requires the `Set-ExecutionPolicy Unrestricted`.

The file `mycert.pfx ` is a placeholder without any valid content. Be sure to adjust it with your client certificate content in order to connect to the Mobile ID service. The file format is PKCS#12 without any password. For improved security, it is also possible to use a certificate with private key stored in the user certificate store. If you want to use a certificate from the Windows certificate store, please export the certificate as .CER file and configure the script to use the .CER file instead of the .PFX file.

Open tasks:
- Validation of the signature and certificate in the response
- Move from response exception error handling to proper error parsing

## Known Issues

**OS X 10.x: Requests always fail with MSS error 104: _Wrong SSL credentials_.**

The `curl` shipped with OS X uses their own Secure Transport engine, which broke the --cert option, see: http://curl.haxx.se/mail/archive-2013-10/0036.html

Install curl from Mac Ports `sudo port install curl` or home-brew: `brew install curl && brew link --force curl`.

