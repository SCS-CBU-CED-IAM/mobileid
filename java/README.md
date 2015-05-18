mobileid: java
========

Mobile ID client code examples and tools written in Java.

## client-cxf-jaxws

A sample JAX-WS based client implementation that is using the Swisscom Mobile ID SOAP interface. 
Stubs were generated with Apache CXF 3.0 using the official Swisscom WSDL `mobileid.wsdl` (see details in `generateStub.bat`).

## client-saaj

A very simple SAAJ based client implementation to invoke a MSS Signature using the Swisscom Mobile ID SOAP interface. 

## mobileid-signature-verifier

A sample implementation how to verify a CMS/PKCS7 signature, i.e. from a Swisscom Mobile ID signature response.
For simplicity, only basic validation is done. You may use the code as a basis to further improve the signature validation.
Note: In order to use this tool as a single (independent) project, it has been moved to its own repository at http://git.io/NF1w.

