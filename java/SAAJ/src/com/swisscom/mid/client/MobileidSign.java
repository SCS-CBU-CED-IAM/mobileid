/**
 * Copyright (C) 2014 - Swisscom (Schweiz) AG
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the 
 * Free Software Foundation, either version 3 of the License, or (at your 
 * option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but 
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
 * for more details.
 * 
 * You should have received a copy of the GNU General Public License along
 * with this program. If not, see http://www.gnu.org/licenses/.
 * 
 */

package com.swisscom.mid.client;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Properties;
import java.util.TimeZone;
import javax.xml.namespace.QName;
import javax.xml.soap.*;
import javax.xml.transform.*;
import javax.xml.transform.stream.*;

public class MobileidSign {

	Properties prop = null;

	private boolean _debug;
	private boolean _verbose;

	private String propertyFilePath;

	private String msisdn;
	private String message;
	private String userLang;

	/**
	 * SAAJ - Simple Mobile ID SOAP Client Example
	 */
	public static void main(String args[]) {
		new MobileidSign(args);
	}

	public static void printError(String error) {
		System.err.println(error);
	}

	private void parseParameters(String[] args) {
		String param;

		if (args == null || args.length < 3) {
			printUsage();
			System.exit(1);
		}

		for (int i = 0; i < args.length; i++) {
			param = args[i].toLowerCase();

			if (param.contains("-msisdn")) {
				msisdn = args[i].substring(args[i].indexOf("=") + 1).trim();
			} else if (param.contains("-message")) {
				message = args[i].substring(args[i].indexOf("=") + 1).trim();
			} else if (param.contains("-language")) {
				userLang = args[i].substring(args[i].indexOf("=") + 1).trim();
			} else if (param.contains("-config=")) {
				propertyFilePath = args[i].substring(args[i].indexOf("=") + 1).trim();
				File propertyFile = new File(propertyFilePath);
				if (!propertyFile.isFile() || !propertyFile.canRead()) {
					if (_debug || _verbose) {
						printError("The -config argument is set but the file does not exist or can not be read.");
					}
					System.exit(1);
				}
			} else if (args[i].toLowerCase().contains("-v")) {
				_verbose = true;
			} else if (param.contains("-d")) {
				_debug = true;
			}
		}
	}

	public static void printUsage() {
		System.out.println("Usage: com.swisscom.mid.client.MobileidSign [OPTIONS]");
		System.out.println();
		System.out.println("Options:");
		// System.out.println("  -v              - verbose output");
		System.out.println("  -d              - debug mode");
		System.out.println("  -config=VALUE   - custom path to properties file which will overwrite default path");
		System.out.println("  -msisdn=VALUE   - mobile number");
		System.out.println("  -message=VALUE  - message to be signed");
		System.out.println("  -language=VALUE - user language (en, de, fr, it)");
		// System.out.println("  -receipt=VALUE  - optional success receipt message");
		System.out.println();
		System.out.println("Examples:");
		System.out.println("  java com.swisscom.mid.client.MobileidSign -d -msisdn=41792080350 -message='Do you want to login to corporate VPN?' -language=en");
		// System.out.println("  java com.swisscom.mid.client.MobileidSign -v -msisdn=41792080350 -message='Do you want to login to corporate VPN?' -language=en -receipt=\"Successful login into VPN\"");
		// System.out.println("  java com.swisscom.mid.client.MobileidSign -v -e -msisdn=41792080350 -message='Do you need a new password?' -language=en -receipt\"Password: 123456\"");
	}

	private MobileidSign(String[] args) {

		parseParameters(args);

		try {
			prop = new Properties();
			prop.load(new FileInputStream("mobileid.properties"));
		} catch (FileNotFoundException e1) {
			e1.printStackTrace();

		} catch (IOException e1) {
			e1.printStackTrace();
			System.exit(1);
		}

		try {
			// Create SOAP Connection
			SOAPConnectionFactory soapConnectionFactory = SOAPConnectionFactory.newInstance();
			SOAPConnection soapConnection = soapConnectionFactory.createConnection();

			System.setProperty("javax.net.ssl.trustStore", prop.getProperty("Truststore.Filename"));
			System.setProperty("javax.net.ssl.trustStorePassword", prop.getProperty("Truststore.Password"));
			System.setProperty("javax.net.ssl.trustStoreType", prop.getProperty("Truststore.Type"));

			System.setProperty("javax.net.ssl.keyStore", prop.getProperty("Keystore.Filename"));
			System.setProperty("javax.net.ssl.keyStorePassword", prop.getProperty("Keystore.Password"));
			System.setProperty("javax.net.ssl.keyStoreType", prop.getProperty("Keystore.Type"));

			// System.setProperty("javax.net.debug", "all");
			// System.setProperty("java.security.debug", "certpath");

			// System.setProperty("https.proxySet", "true");
			// System.setProperty("https.proxyHost", "10.185.32.54");
			// System.setProperty("https.proxyPort", "8079");

			// Send SOAP Message to SOAP Server
			SOAPMessage soapResponse = soapConnection.call(createSOAPRequest(), prop.getProperty("URL"));

			if (_debug)
				printSOAPResponse(soapResponse);

			soapConnection.close();
		} catch (Exception e) {
			System.err.println("Error occurred while sending SOAP Request to Server");
			e.printStackTrace();
		}
	}

	private SOAPMessage createSOAPRequest() throws Exception {
		MessageFactory messageFactory = MessageFactory.newInstance(SOAPConstants.SOAP_1_2_PROTOCOL);
		SOAPMessage soapMessage = messageFactory.createMessage();

		soapMessage.setProperty(javax.xml.soap.SOAPMessage.CHARACTER_SET_ENCODING, "UTF-8");
		soapMessage.setProperty(javax.xml.soap.SOAPMessage.WRITE_XML_DECLARATION, "true");

		SOAPPart soapPart = soapMessage.getSOAPPart();

		// SOAP Envelope
		SOAPEnvelope envelope = soapPart.getEnvelope();
		envelope.addNamespaceDeclaration("mss", "http://uri.etsi.org/TS102204/v1.1.2#");
		envelope.addNamespaceDeclaration("fi", "http://mss.ficom.fi/TS102204/v1.0.0#");

		// SOAP Body
		SOAPBody soapBody = envelope.getBody();

		SOAPElement MSS_Signature = soapBody.addChildElement("MSS_Signature");

		SOAPElement MSS_SignatureReq = MSS_Signature.addChildElement("MSS_SignatureReq", "mss");
		MSS_SignatureReq.addAttribute(new QName("MajorVersion"), "1");
		MSS_SignatureReq.addAttribute(new QName("MinorVersion"), "1");
		MSS_SignatureReq.addAttribute(new QName("MessagingMode"), "synch");
		MSS_SignatureReq.addAttribute(new QName("TimeOut"), prop.getProperty("Timeout"));
		MSS_SignatureReq.addNamespaceDeclaration("mss", "http://uri.etsi.org/TS102204/v1.1.2#");
		MSS_SignatureReq.addNamespaceDeclaration("fi", "http://mss.ficom.fi/TS102204/v1.0.0#");

		SOAPElement AP_Info = MSS_SignatureReq.addChildElement("AP_Info", "mss");
		AP_Info.addAttribute(new QName("AP_ID"), prop.getProperty("AP_ID"));
		AP_Info.addAttribute(new QName("AP_PWD"), prop.getProperty("AP_PWD"));
		AP_Info.addAttribute(new QName("AP_TransID"), "TEST." + System.currentTimeMillis());
		AP_Info.addAttribute(new QName("Instant"), getInstant());

		SOAPElement MSSP_Info = MSS_SignatureReq.addChildElement("MSSP_Info", "mss");
		SOAPElement MSSP_ID = MSSP_Info.addChildElement("MSSP_ID", "mss");
		SOAPElement URI = MSSP_ID.addChildElement("URI", "mss");
		URI.addTextNode("http://mid.swisscom.ch/");

		SOAPElement MobileUser = MSS_SignatureReq.addChildElement("MobileUser", "mss");
		SOAPElement MSISDN = MobileUser.addChildElement("MSISDN", "mss");
		MSISDN.addTextNode(msisdn);

		SOAPElement DataToBeSigned = MSS_SignatureReq.addChildElement("DataToBeSigned", "mss");
		DataToBeSigned.addAttribute(new QName("MimeType"), "text/plain");
		DataToBeSigned.addAttribute(new QName("Encoding"), "UTF-8");
		DataToBeSigned.addTextNode(message);

		SOAPElement SignatureProfile = MSS_SignatureReq.addChildElement("SignatureProfile", "mss");
		SOAPElement mssURISigProfile = SignatureProfile.addChildElement("mssURI", "mss");
		mssURISigProfile.addTextNode("http://mid.swisscom.ch/MID/v1/AuthProfile1");

		SOAPElement AdditionalServices = MSS_SignatureReq.addChildElement("AdditionalServices", "mss");
		SOAPElement Service = AdditionalServices.addChildElement("Service", "mss");
		SOAPElement Description = Service.addChildElement("Description", "mss");
		SOAPElement mssURIUserLang = Description.addChildElement("mssURI", "mss");
		mssURIUserLang.addTextNode("http://mss.ficom.fi/TS102204/v1.0.0#userLang");
		SOAPElement UserLang = Service.addChildElement("UserLang", "fi");
		UserLang.addTextNode(userLang);

		SOAPElement MSS_Format = MSS_SignatureReq.addChildElement("MSS_Format", "mss");
		SOAPElement mssURIFormat = MSS_Format.addChildElement("mssURI", "mss");
		mssURIFormat.addTextNode("http://uri.etsi.org/TS102204/v1.1.2#PKCS7");

		soapMessage.saveChanges();

		/* Print the request message */
		if (_debug) {
			System.out.print("Request SOAP Message:\n");
			soapMessage.writeTo(System.out);
			System.out.println("\n");
		}

		return soapMessage;
	}

	/**
	 * Method used to print the SOAP Response
	 */
	private void printSOAPResponse(SOAPMessage soapResponse) throws Exception {
		TransformerFactory transformerFactory = TransformerFactory.newInstance();
		Transformer transformer = transformerFactory.newTransformer();
		Source sourceContent = soapResponse.getSOAPPart().getContent();
		System.out.print("Response SOAP Message:\n");
		StreamResult result = new StreamResult(System.out);
		transformer.transform(sourceContent, result);
		System.out.println();
	}

	private String getInstant() {
		DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
		df.setTimeZone(TimeZone.getTimeZone("UTC"));
		return df.format(new Date());
	}

}