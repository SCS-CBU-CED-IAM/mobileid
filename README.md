mobileid-cmd
============

Mobile ID command line tools

## bash

Contains a script to invoke the Signature Request service.

The files `mycert.crt`and `mycert.key` are placeholders without any valid content. Be sure to adjust them with your client certificate content in order to connect to the Mobile ID service.

Refer to the "Mobile ID - SOAP client reference guide" document from Swisscom for more details.


## freeradius

Wrapper script for rlm_exec module and the Signature Request bash script.

Refer to the "Mobile ID - RADIUS integration guide" document from Swisscom for more details.


## PowerShell

Contains a script to invoke the Signature Request service.

Requires PowerShell 2.0 or higher as it contains an encapsulated C# class.
The code is unsigned and requires the `Set-ExecutionPolicy Unrestricted`.

The file `mycert.pfx ` is a placeholder without any valid content. Be sure to adjust it with your client certificate content in order to connect to the Mobile ID service. The file format is PKCS#12 without any password.

Open tasks:
- Validation of the signature and certificate in the response
- Move from response exception error handling to proper error parsing
