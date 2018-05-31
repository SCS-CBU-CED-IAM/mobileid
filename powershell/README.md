mobileid: powershell
============

Powershell C# sample script.

## Usage

To start, run the Powershell Terminal and run the `mobileid_sharp.ps1`
```
PS> .\mobileid_sharp.ps1 -Verbose -PhoneNumber +41791234567 -Message "Do you want to login?" -Language en
OK with following details and checks:
 1) Transaction ID : [AP.TEST.82305.8627] -> same as in request
 2) Signed by      : [+41791234567]
 3) Signer subject : [C=CH, CN=MIDCHETEE9YMG3I5:PN, SERIALNUMBER=MIDCHETEE9YMG3I5]
 4) Signed message : [Do you want to login?]
 5) Status code    : [500]
    Status details : [SIGNATURE]
```
