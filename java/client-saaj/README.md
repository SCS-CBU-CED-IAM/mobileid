# client-saaj
A very simple SAAJ based client implementation to invoke a MSS Signature using the Swisscom Mobile ID SOAP interface. 

More GitHub samples on Mobile ID can be found at https://github.com/SCS-CBU-CED-IAM
Futher information about the Swisscom Mobile ID Service can be found at http://swisscom.com/mid, i.e. you should read the Mobile ID Client Reference Guide.

##### Configuration
In order to use this sample client you must be a registered customer of the Swisscom Mobile ID service. 
You will need your own AP_ID, DTBS-Prefix and SSL Key.

- Refer to `mobileid.properties` configuration file and modify the configuration properties accordingly.
- The `keystore.jks` must contain your SSL Key for the Swisscom Mobile ID service.

##### Usage

The client will invoke an MSS Signature requests and parse the response. To keep the implementation simple,
it does only very little parsing of the response content, i.e. it does not further validate the CMS Signature object.

```
Usage: com.swisscom.mid.client.MobileidSign [OPTIONS]

Options:
  -v              - verbose output, parse response content
  -d              - debug output, output raw message content
  -config=VALUE   - path to properties file
  -msisdn=VALUE   - mobile number
  -message=VALUE  - message to be signed
                    A placeholder #TRANSID# may be used anywhere in the message to include a unique transaction id.
  -language=VALUE - language of the message (one of en, de, fr, it)

Examples:
  java com.swisscom.mid.client.MobileidSign -v -d -config=mobileid.properties -msisdn=41791234567 -message="Test: Do you want to login? (#TRANSID#)" -language=en
  java -DproxySet=true -DproxyHost=10.185.32.54 -DproxyPort=8079 com.swisscom.mid.client.MobileidSign -v -d -config=mobileid.properties -msisdn=41791234567 -message="Test: Do you want to login? (#TRANSID#)" -language=en
  java -Djavax.net.debug=all -Djava.security.debug=certpath com.swisscom.mid.client.MobileidSign -v -d -config=mobileid.properties -msisdn=41791234567 -message="Test: Do you want to login? (#TRANSID#)" -language=en
```

##### Example Output

###### Verbose (option -v)

```
VERBOSE OUTPUT
StatusCode    : 500
StatusMessage : SIGNATURE
```

###### Debug (option -d)

```
Request SOAP Message:
<?xml version="1.0" encoding="UTF-8" ?><env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#" xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#"><env:Header/><env:Body><MSS_Signature><mss:MSS_SignatureReq MajorVersion="1" MessagingMode="synch" MinorVersion="1" TimeOut="80"><mss:AP_Info AP_ID="mid://dev.swisscom.ch" AP_PWD="" AP_TransID="TEST.1423646241904" Instant="2015-02-11T09:17:21Z"/><mss:MSSP_Info><mss:MSSP_ID><mss:URI>http://mid.swisscom.ch/</mss:URI></mss:MSSP_ID></mss:MSSP_Info><mss:MobileUser><mss:MSISDN>41794706146</mss:MSISDN></mss:MobileUser><mss:DataToBeSigned Encoding="UTF-8" MimeType="text/plain">Test: Do you want to login? (ptp2cn)</mss:DataToBeSigned><mss:SignatureProfile><mss:mssURI>http://mid.swisscom.ch/MID/v1/AuthProfile1</mss:mssURI></mss:SignatureProfile><mss:AdditionalServices><mss:Service><mss:Description><mss:mssURI>http://mss.ficom.fi/TS102204/v1.0.0#userLang</mss:mssURI></mss:Description><fi:UserLang>en</fi:UserLang></mss:Service><mss:Service><mss:Description><mss:mssURI>http://mid.swisscom.ch/as#subscriberInfo</mss:mssURI></mss:Description></mss:Service></mss:AdditionalServices></mss:MSS_SignatureReq></MSS_Signature></env:Body></env:Envelope>

Response SOAP Message:
<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><MSS_SignatureResponse xmlns=""><mss:MSS_SignatureResp xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#" MajorVersion="1" MinorVersion="1" MSSP_TransID="hf5qit"><mss:AP_Info AP_ID="mid://dev.swisscom.ch" AP_TransID="TEST.1423646241904" AP_PWD="" Instant="2015-02-11T10:17:21.000+01:00"/><mss:MSSP_Info Instant="2015-02-11T10:17:33.914+01:00"><mss:MSSP_ID><mss:URI>http://mid.swisscom.ch/</mss:URI></mss:MSSP_ID></mss:MSSP_Info><mss:MobileUser><mss:MSISDN>41794706146</mss:MSISDN></mss:MobileUser><mss:MSS_Signature><mss:Base64Signature>MIII...</mss:Base64Signature></mss:MSS_Signature><mss:SignatureProfile><mss:mssURI>http://mid.swisscom.ch/MID/v1/AuthProfile1</mss:mssURI></mss:SignatureProfile><mss:Status><mss:StatusCode Value="500"/><mss:StatusMessage>SIGNATURE</mss:StatusMessage></mss:Status></mss:MSS_SignatureResp></MSS_SignatureResponse></soapenv:Body></soapenv:Envelope>
```

##### Compile & Run

Compile the source file: `javac -d ./class -cp . ./src/com/swisscom/mid/client/*.java`

Note: The class files are generated in a directory hierarchy which reflects the given package structure: `./class/com/swisscom/mid/client/*.class`

Run the application: `java -cp ./class com.swisscom.mid.client.MobileidSign`

As an alternative you may run the JAR archive: `java -cp ".:./jar/*" com.swisscom.mid.client.MobileidSign`

If you're on Windows then use a semicolon ; instead of the colon : (see `MobileidSign.bat`)
