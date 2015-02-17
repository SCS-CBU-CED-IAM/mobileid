# client-cxf-jaxws
A sample JAX-WS based client implementation that is using the Swisscom Mobile ID SOAP interface. 
Stubs were generated with Apache CXF 3.0 using the official Swisscom WSDL `mobileid.wsdl` (see details in `generateStub.bat`).

More GitHub samples on Mobile ID can be found at https://github.com/SCS-CBU-CED-IAM
Futher information about the Swisscom Mobile ID Service can be found at http://swisscom.com/mid, i.e. you should read the Mobile ID Client Reference Guide.

##### Configuration
In order to use this sample client you must be a registered customer of the Swisscom Mobile ID service. 
You will need your own AP_ID, DTBS-Prefix and SSL Key.

- Refer to `mobileid.properties` configuration file and modify the configuration properties accordingly.
- Refer to the class `ch.swisscom.mid.client.Test_Client` and modify the variables accordingly
- The `keystore.jks` must contain your SSL Key for the Swisscom Mobile ID service.

##### Usage

Run the class `ch.swisscom.mid.client.Test_Client`. 
The class will invoke all the basic Mobile ID requests and parse the response. To keep the implementation simple,
it does only very little parsing of the response content, i.e. it does not further validate the CMS Signature content.
You may refer to the GitHub signature verifier sample at http://git.io/NF1w how to verify the CMS Signature content.

1. **MSS_ProfileQuery** Check the existence of the User (MSISDN)

2. **MSS_Signature** Invoke an asynchronous signature and get the MSSP Transaction ID

3. **MSS_StatusQuery** Poll the for the final signature transaction result

4. **MSS_Receipt** Invoke a receipt message in case the signature transaction was successful

##### Debug

The class `ch.swisscom.mid.client.Test_Client` contains system property examples to enable different debug options, i.e. SSL Debug Output or SOAP Raw Message Content Output.
Just uncomment those lines according to your need.

##### Example Output

###### Default

```
MSS_Profile StatusCode: 100
MSS_Signature StatusCode: 100
MSS_Signature MSSP_TransID: hf5gpq
MSS_StatusQuery StatusCode: 504
MSS_StatusQuery StatusCode: 500
MSS_Receipt StatusCode: 100
MSS_Receipt UserResponse: {"status":"OK"}
```

###### With SOAP Raw Message Content Output

```
---[HTTP request - https://mobileid.swisscom.com/soap/services/MSS_ProfilePort]---
Accept: [application/soap+xml, multipart/related]
Content-Type: [application/soap+xml; charset=utf-8;action=""]
User-Agent: [JAX-WS RI 2.2.4-b01]
<?xml version="1.0" ?><S:Envelope xmlns:S="http://www.w3.org/2003/05/soap-envelope"><S:Body><ns9:MSS_ProfileQuery xmlns:ns3="http://www.w3.org/2000/09/xmldsig#" xmlns:ns4="http://mid.swisscom.ch/TS102204/as/v1.0" xmlns:ns5="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:ns6="http://mss.ficom.fi/TS102204/v1.0.0#" xmlns:ns7="http://www.swisscom.ch/TS102204/ext/v1.0.0" xmlns:ns8="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" xmlns:ns9="http://uri.etsi.org/TS102204/etsi204-kiuru.wsdl"><MSS_ProfileReq MajorVersion="1" MinorVersion="1"><ns5:AP_Info AP_ID="mid://dev.swisscom.ch" AP_PWD="" AP_TransID="ID-27bea0bb-670f-4fc2-8ac0-bf552fea7ed0" Instant="2015-02-11T08:57:01.169+01:00"/><ns5:MSSP_Info><ns5:MSSP_ID><ns5:URI>http://mid.swisscom.ch/</ns5:URI></ns5:MSSP_ID></ns5:MSSP_Info><ns5:MobileUser><ns5:MSISDN>41794706146</ns5:MSISDN></ns5:MobileUser></MSS_ProfileReq></ns9:MSS_ProfileQuery></S:Body></S:Envelope>--------------------

---[HTTP response - https://mobileid.swisscom.com/soap/services/MSS_ProfilePort - 200]---
null: [HTTP/1.1 200 OK]
Connection: [close]
Content-Type: [application/soap+xml;charset=utf-8]
Date: [Wed, 11 Feb 2015 07:57:01 GMT]
Transfer-Encoding: [chunked]
<?xml version="1.0" encoding="utf-8"?><soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><MSS_ProfileQueryResponse xmlns="http://uri.etsi.org/TS102204/etsi204-kiuru.wsdl"><MSS_ProfileResp MajorVersion="1" MinorVersion="1" xmlns=""><mss:AP_Info AP_ID="mid://dev.swisscom.ch" AP_TransID="ID-27bea0bb-670f-4fc2-8ac0-bf552fea7ed0" AP_PWD="" Instant="2015-02-11T08:57:01.169+01:00" xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#"/><mss:MSSP_Info Instant="2015-02-11T08:57:01.897+01:00" xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#"><mss:MSSP_ID><mss:URI>http://mid.swisscom.ch/</mss:URI></mss:MSSP_ID></mss:MSSP_Info><mss:SignatureProfile xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#"><mss:mssURI>http://mid.swisscom.ch/MID/v1/AuthProfile1</mss:mssURI></mss:SignatureProfile><mss:SignatureProfile xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#"><mss:mssURI>http://mid.swisscom.ch/MID/v1/SignProfileHash1</mss:mssURI></mss:SignatureProfile><mss:SignatureProfile xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#"><mss:mssURI>http://mid.swisscom.ch/MID/v1/SignProfileSign1</mss:mssURI></mss:SignatureProfile><mss:Status xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#"><mss:StatusCode Value="100"/><mss:StatusMessage>REQUEST_OK</mss:StatusMessage></mss:Status></MSS_ProfileResp></MSS_ProfileQueryResponse></soapenv:Body></soapenv:Envelope>--------------------
MSS_Profile StatusCode: 100

---[HTTP request - https://mobileid.swisscom.com/soap/services/MSS_SignaturePort]---
Accept: [application/soap+xml, multipart/related]
Content-Type: [application/soap+xml; charset=utf-8;action=""]
User-Agent: [JAX-WS RI 2.2.4-b01]
<?xml version="1.0" ?><S:Envelope xmlns:S="http://www.w3.org/2003/05/soap-envelope"><S:Body><ns9:MSS_Signature xmlns:ns3="http://www.w3.org/2000/09/xmldsig#" xmlns:ns4="http://mid.swisscom.ch/TS102204/as/v1.0" xmlns:ns5="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:ns6="http://mss.ficom.fi/TS102204/v1.0.0#" xmlns:ns7="http://www.swisscom.ch/TS102204/ext/v1.0.0" xmlns:ns8="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" xmlns:ns9="http://uri.etsi.org/TS102204/etsi204-kiuru.wsdl"><MSS_SignatureReq TimeOut="80" MessagingMode="asynchClientServer" MajorVersion="1" MinorVersion="1"><ns5:AP_Info AP_ID="mid://dev.swisscom.ch" AP_PWD="" AP_TransID="ID-29ce5d91-6557-4a3f-9d36-7ae5b0787a22" Instant="2015-02-11T08:57:01.888+01:00"/><ns5:MSSP_Info><ns5:MSSP_ID><ns5:URI>http://mid.swisscom.ch/</ns5:URI></ns5:MSSP_ID></ns5:MSSP_Info><ns5:MobileUser><ns5:MSISDN>41794706146</ns5:MSISDN></ns5:MobileUser><ns5:DataToBeSigned MimeType="text/plain" Encoding="UTF-8">Test: Do you want to login? (trp4r)</ns5:DataToBeSigned><ns5:SignatureProfile><ns5:mssURI>http://mid.swisscom.ch/MID/v1/AuthProfile1</ns5:mssURI></ns5:SignatureProfile><ns5:AdditionalServices><ns5:Service><ns5:Description><ns5:mssURI>http://mss.ficom.fi/TS102204/v1.0.0#userLang</ns5:mssURI></ns5:Description><ns6:UserLang>en</ns6:UserLang></ns5:Service><ns5:Service><ns5:Description><ns5:mssURI>http://mid.swisscom.ch/as#subscriberInfo</ns5:mssURI></ns5:Description></ns5:Service></ns5:AdditionalServices></MSS_SignatureReq></ns9:MSS_Signature></S:Body></S:Envelope>--------------------

---[HTTP response - https://mobileid.swisscom.com/soap/services/MSS_SignaturePort - 200]---
null: [HTTP/1.1 200 OK]
Connection: [close]
Content-Type: [application/soap+xml;charset=utf-8]
Date: [Wed, 11 Feb 2015 07:57:02 GMT]
Transfer-Encoding: [chunked]
<?xml version="1.0" encoding="utf-8"?><soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><MSS_SignatureResponse xmlns="http://uri.etsi.org/TS102204/etsi204-kiuru.wsdl"><MSS_SignatureResp MajorVersion="1" MinorVersion="1" MSSP_TransID="hf5h3o" xmlns=""><mss:AP_Info AP_ID="mid://dev.swisscom.ch" AP_TransID="ID-29ce5d91-6557-4a3f-9d36-7ae5b0787a22" AP_PWD="" Instant="2015-02-11T08:57:01.888+01:00" xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#"/><mss:MSSP_Info Instant="2015-02-11T08:57:02.465+01:00" xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#"><mss:MSSP_ID><mss:URI>http://mid.swisscom.ch/</mss:URI></mss:MSSP_ID></mss:MSSP_Info><mss:MobileUser xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#"><mss:MSISDN>41794706146</mss:MSISDN></mss:MobileUser><mss:SignatureProfile xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#"><mss:mssURI>http://mid.swisscom.ch/MID/v1/AuthProfile1</mss:mssURI></mss:SignatureProfile><mss:Status xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#"><mss:StatusCode Value="100"/><mss:StatusMessage>REQUEST_OK</mss:StatusMessage></mss:Status></MSS_SignatureResp></MSS_SignatureResponse></soapenv:Body></soapenv:Envelope>--------------------
MSS_Signature StatusCode: 100
MSS_Signature MSSP_TransID: hf5h3o

---[HTTP request - https://mobileid.swisscom.com/soap/services/MSS_StatusQueryPort]---
Accept: [application/soap+xml, multipart/related]
Content-Type: [application/soap+xml; charset=utf-8;action=""]
User-Agent: [JAX-WS RI 2.2.4-b01]
<?xml version="1.0" ?><S:Envelope xmlns:S="http://www.w3.org/2003/05/soap-envelope"><S:Body><ns9:MSS_StatusQuery xmlns:ns3="http://www.w3.org/2000/09/xmldsig#" xmlns:ns4="http://mid.swisscom.ch/TS102204/as/v1.0" xmlns:ns5="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:ns6="http://mss.ficom.fi/TS102204/v1.0.0#" xmlns:ns7="http://www.swisscom.ch/TS102204/ext/v1.0.0" xmlns:ns8="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" xmlns:ns9="http://uri.etsi.org/TS102204/etsi204-kiuru.wsdl"><MSS_StatusReq MSSP_TransID="hf5h3o" MajorVersion="1" MinorVersion="1"><ns5:AP_Info AP_ID="mid://dev.swisscom.ch" AP_PWD="" AP_TransID="ID-5721601d-e22a-4bc1-901c-bb6702d6dd7e" Instant="2015-02-11T08:57:07.439+01:00"/><ns5:MSSP_Info><ns5:MSSP_ID><ns5:URI>http://mid.swisscom.ch/</ns5:URI></ns5:MSSP_ID></ns5:MSSP_Info></MSS_StatusReq></ns9:MSS_StatusQuery></S:Body></S:Envelope>--------------------

---[HTTP response - https://mobileid.swisscom.com/soap/services/MSS_StatusQueryPort - 200]---
null: [HTTP/1.1 200 OK]
Connection: [close]
Content-Type: [application/soap+xml;charset=utf-8]
Date: [Wed, 11 Feb 2015 07:57:07 GMT]
Transfer-Encoding: [chunked]
<?xml version="1.0" encoding="utf-8"?><soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><MSS_StatusQueryResponse xmlns="http://uri.etsi.org/TS102204/etsi204-kiuru.wsdl"><MSS_StatusResp MajorVersion="1" MinorVersion="1" xmlns=""><mss:AP_Info AP_ID="mid://dev.swisscom.ch" AP_TransID="ID-5721601d-e22a-4bc1-901c-bb6702d6dd7e" AP_PWD="" Instant="2015-02-11T08:57:07.439+01:00" xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#"/><mss:MSSP_Info Instant="2015-02-11T08:57:07.835+01:00" xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#"><mss:MSSP_ID><mss:URI>http://mid.swisscom.ch/</mss:URI></mss:MSSP_ID></mss:MSSP_Info><mss:MobileUser xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#"><mss:MSISDN>41794706146</mss:MSISDN></mss:MobileUser><mss:Status xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#"><mss:StatusCode Value="504"/><mss:StatusMessage>OUTSTANDING_TRANSACTION</mss:StatusMessage></mss:Status></MSS_StatusResp></MSS_StatusQueryResponse></soapenv:Body></soapenv:Envelope>--------------------
MSS_StatusQuery StatusCode: 504

---[HTTP request - https://mobileid.swisscom.com/soap/services/MSS_StatusQueryPort]---
Accept: [application/soap+xml, multipart/related]
Content-Type: [application/soap+xml; charset=utf-8;action=""]
User-Agent: [JAX-WS RI 2.2.4-b01]
<?xml version="1.0" ?><S:Envelope xmlns:S="http://www.w3.org/2003/05/soap-envelope"><S:Body><ns9:MSS_StatusQuery xmlns:ns3="http://www.w3.org/2000/09/xmldsig#" xmlns:ns4="http://mid.swisscom.ch/TS102204/as/v1.0" xmlns:ns5="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:ns6="http://mss.ficom.fi/TS102204/v1.0.0#" xmlns:ns7="http://www.swisscom.ch/TS102204/ext/v1.0.0" xmlns:ns8="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" xmlns:ns9="http://uri.etsi.org/TS102204/etsi204-kiuru.wsdl"><MSS_StatusReq MSSP_TransID="hf5h3o" MajorVersion="1" MinorVersion="1"><ns5:AP_Info AP_ID="mid://dev.swisscom.ch" AP_PWD="" AP_TransID="ID-15df4e04-859a-4db2-8c18-1796e4af98ac" Instant="2015-02-11T08:57:18.104+01:00"/><ns5:MSSP_Info><ns5:MSSP_ID><ns5:URI>http://mid.swisscom.ch/</ns5:URI></ns5:MSSP_ID></ns5:MSSP_Info></MSS_StatusReq></ns9:MSS_StatusQuery></S:Body></S:Envelope>--------------------

---[HTTP response - https://mobileid.swisscom.com/soap/services/MSS_StatusQueryPort - 200]---
null: [HTTP/1.1 200 OK]
Connection: [close]
Content-Type: [application/soap+xml;charset=utf-8]
Date: [Wed, 11 Feb 2015 07:57:18 GMT]
Transfer-Encoding: [chunked]
<?xml version="1.0" encoding="utf-8"?><soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><MSS_StatusQueryResponse xmlns="http://uri.etsi.org/TS102204/etsi204-kiuru.wsdl"><MSS_StatusResp MajorVersion="1" MinorVersion="1" xmlns=""><mss:AP_Info AP_ID="mid://dev.swisscom.ch" AP_TransID="ID-15df4e04-859a-4db2-8c18-1796e4af98ac" AP_PWD="" Instant="2015-02-11T08:57:18.104+01:00" xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#"/><mss:MSSP_Info Instant="2015-02-11T08:57:18.479+01:00" xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#"><mss:MSSP_ID><mss:URI>http://mid.swisscom.ch/</mss:URI></mss:MSSP_ID></mss:MSSP_Info><mss:MobileUser xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#"><mss:MSISDN>41794706146</mss:MSISDN></mss:MobileUser><mss:MSS_Signature xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#"><mss:Base64Signature>MIII...</mss:Base64Signature></mss:MSS_Signature><mss:Status xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#"><mss:StatusCode Value="500"/><mss:StatusMessage>SIGNATURE</mss:StatusMessage></mss:Status></MSS_StatusResp></MSS_StatusQueryResponse></soapenv:Body></soapenv:Envelope>--------------------
MSS_StatusQuery StatusCode: 500

---[HTTP request - https://mobileid.swisscom.com/soap/services/MSS_ReceiptPort]---
Accept: [application/soap+xml, multipart/related]
Content-Type: [application/soap+xml; charset=utf-8;action=""]
User-Agent: [JAX-WS RI 2.2.4-b01]
<?xml version="1.0" ?><S:Envelope xmlns:S="http://www.w3.org/2003/05/soap-envelope"><S:Body><ns9:MSS_Receipt xmlns:ns3="http://www.w3.org/2000/09/xmldsig#" xmlns:ns4="http://mid.swisscom.ch/TS102204/as/v1.0" xmlns:ns5="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:ns6="http://mss.ficom.fi/TS102204/v1.0.0#" xmlns:ns7="http://www.swisscom.ch/TS102204/ext/v1.0.0" xmlns:ns8="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" xmlns:ns9="http://uri.etsi.org/TS102204/etsi204-kiuru.wsdl"><MSS_ReceiptReq MSSP_TransID="hf5h3o" MajorVersion="1" MinorVersion="1"><ns5:AP_Info AP_ID="mid://dev.swisscom.ch" AP_PWD="" AP_TransID="ID-aae582b1-2ed7-4b7a-8c8c-fa2d1dc1c55c" Instant="2015-02-11T08:57:18.434+01:00"/><ns5:MSSP_Info><ns5:MSSP_ID><ns5:URI>http://mid.swisscom.ch/</ns5:URI></ns5:MSSP_ID></ns5:MSSP_Info><ns5:MobileUser><ns5:MSISDN>41794706146</ns5:MSISDN></ns5:MobileUser><ns5:Status><ns5:StatusCode Value="100"/><ns5:StatusDetail><ns7:ReceiptRequestExtension ReceiptMessagingMode="synch" UserAck="true"><ns7:ReceiptProfile Language="en"><ns7:ReceiptProfileURI>http://mss.swisscom.ch/synch</ns7:ReceiptProfileURI></ns7:ReceiptProfile></ns7:ReceiptRequestExtension></ns5:StatusDetail></ns5:Status><ns5:Message MimeType="text/plain" Encoding="UTF-8">This is a Receipt Message</ns5:Message></MSS_ReceiptReq></ns9:MSS_Receipt></S:Body></S:Envelope>--------------------

---[HTTP response - https://mobileid.swisscom.com/soap/services/MSS_ReceiptPort - 200]---
null: [HTTP/1.1 200 OK]
Connection: [close]
Content-Type: [application/soap+xml;charset=utf-8]
Date: [Wed, 11 Feb 2015 07:57:18 GMT]
Transfer-Encoding: [chunked]
<?xml version="1.0" encoding="utf-8"?><soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><MSS_ReceiptResponse xmlns="http://uri.etsi.org/TS102204/etsi204-kiuru.wsdl"><MSS_ReceiptResp MajorVersion="1" MinorVersion="1" xmlns=""><mss:AP_Info AP_ID="mid://dev.swisscom.ch" AP_TransID="ID-aae582b1-2ed7-4b7a-8c8c-fa2d1dc1c55c" AP_PWD="" Instant="2015-02-11T08:57:18.434+01:00" xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#"/><mss:MSSP_Info Instant="2015-02-11T08:57:24.905+01:00" xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#"><mss:MSSP_ID><mss:URI>http://mid.swisscom.ch/</mss:URI></mss:MSSP_ID></mss:MSSP_Info><mss:Status xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#"><mss:StatusCode Value="100"/><mss:StatusMessage>REQUEST_OK</mss:StatusMessage><mss:StatusDetail><ns1:ReceiptResponseExtension ReceiptMessagingMode="synch" UserAck="true" UserResponse="{&quot;status&quot;:&quot;OK&quot;}" xmlns:ns1="http://www.swisscom.ch/TS102204/ext/v1.0.0"/></mss:StatusDetail></mss:Status></MSS_ReceiptResp></MSS_ReceiptResponse></soapenv:Body></soapenv:Envelope>--------------------
MSS_Receipt StatusCode: 100
MSS_Receipt UserResponse: {"status":"OK"}
```
