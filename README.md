mobileid-cmd
============

Mobile ID command line tools

## bash

Contains a script to invoke the Signature Request and one to invoke the Receipt Request.

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


The files `mycert.crt`and `mycert.key` are placeholders without any valid content. Be sure to adjust them with your client certificate content in order to connect to the Mobile ID service.

Refer to the "Mobile ID - SOAP client reference guide" document from Swisscom for more details.


Example of verbose outputs:
```
./mobileid-sign.sh -v +41792080350 "Hello" en
#MSS_Signature OK with following details and checks:
 1) Transaction ID : AP.TEST.34309.7311 -> same as in request
    MSSP TransID   : h2ecyu
 2) Signed by      : +41792080350 -> same as in request
 3) Time to sign   : <Not verified>
 4) Signer         : subject= /serialNumber=MIDCHE3QWAXYEAA2/CN=MIDCHE3QWAXYEAA2:PN/C=CH -> OCSP check: good
 5) Signed Data    : Hello -> Decode and verify: success and same as in request
 6) Status code    : 500 with exit 0
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
 3) Time to sign   : <Not verified>
 4) Signer         : subject= /serialNumber=MIDCHE3QWAXYEAA2/CN=MIDCHE3QWAXYEAA2:PN/C=CH -> OCSP check: good
 5) Signed Data    : Do you want to login to corporate VPN? -> Decode and verify: success and same as in request
 6) Status code    : 500 with exit 0
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


## freeradius

Wrapper script for rlm_exec module and the Signature Request bash script.

Refer to the "Mobile ID - RADIUS integration guide" document from Swisscom for more details.


## PowerShell

Contains a script to invoke the Signature Request service.

Requires PowerShell 2.0 or higher as it contains an encapsulated C# class.
The code is unsigned and requires the `Set-ExecutionPolicy Unrestricted`.

The file `mycert.pfx ` is a placeholder without any valid content. Be sure to adjust it with your client certificate content in order to connect to the Mobile ID service. The file format is PKCS#12 without any password. For improved security, it is also possible to use a certificate with private key stored in the user certificate store. If you want to use a certificate from the Windows certificate store, please export the certificate as .CER file and configure the script to use the .CER file instead of the .PFX file.

Open tasks:
- Validation of the signature and certificate in the response
- Move from response exception error handling to proper error parsing

## Known issues

**OS X 10.9: Requests always fail with MSS error 104: _Wrong SSL credentials_.**
The `curl` shipped with OS X uses their own Secure Transport engine, which broke the --cert option, see: http://curl.haxx.se/mail/archive-2013-10/0036.html

Install curl from Mac Ports `sudo port install curl` or home-brew: `brew install curl && brew link --force curl`.

