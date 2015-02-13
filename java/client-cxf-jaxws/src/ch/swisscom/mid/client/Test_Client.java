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
 * @author <a href="mailto:philipp.haupt@swisscom.com">Philipp Haupt</a>
 */

package ch.swisscom.mid.client;

import java.io.File;
import java.io.FileInputStream;
import java.math.BigInteger;
import java.security.SecureRandom;
import java.util.Properties;

public class Test_Client {

	public static void main(String[] args) {	
		// Use Proxy
		//System.setProperty("proxyHost", "10.185.32.54");
		//System.setProperty("proxyPort", "8079");

		// Print SSL Debug Output
		//System.setProperty("javax.net.debug", "all");
		//System.setProperty("java.security.debug", "certpath");

		// Print SOAP Raw Message Content
		//System.setProperty("com.sun.xml.internal.ws.transport.http.client.HttpTransportPipe.dump", "true");
		
		String propertyFilePath = "mobileid.properties";
		File propertyFile = new File(propertyFilePath);
		if (!propertyFile.isFile() || !propertyFile.canRead()) {
			System.err.println("The property file does not exist or can not be read.");
			System.exit(1);
		}
		
		Properties prop = null;
		try {
			prop = new Properties();
			prop.load(new FileInputStream(propertyFilePath));
		} catch (Exception e) {
			System.err.println("Error occurred while reading the properties file");
			e.printStackTrace();
			System.exit(1);
		}

		// SSL Key-/TrustStore
		System.setProperty("javax.net.ssl.trustStore", prop.getProperty("Truststore.Filename"));
		System.setProperty("javax.net.ssl.trustStorePassword", prop.getProperty("Truststore.Password"));
		System.setProperty("javax.net.ssl.keyStore", prop.getProperty("Keystore.Filename"));
		System.setProperty("javax.net.ssl.keyStorePassword", prop.getProperty("Keystore.Password"));
		
		// Configuration
		String apID = prop.getProperty("AP_ID");
		String msisdn = "41794706146";
		String dtbsPrefix = "Test: ";
		String dtbsMessage = "Do you want to login?";
		String receiptMessage = "This is a Receipt Message";
		String userLang = "en";
		
		String status = null;
		String msspTransId = null;
		
		// The DataToBeSigned String contains Prefix, Message and a unique/random Transaction ID
		String dtbs = dtbsPrefix + dtbsMessage + " (" + getNewTransactionId() + ")";
		
		// MSS_ProfileQuery: Check the existence of the User (MSISDN)
		status = MSSProfile_Client.doProfileQuery(apID, msisdn);
		
		// MSS_Signature: Invoke asynchronous signature and read MSSP Transaction ID
		if (status != null && status.equals("100"))
			msspTransId = MSSSignature_Client.doSignature(apID, msisdn, dtbs, userLang);
		
		// MSS_StatusQuery: Poll the transaction result of the signature
		if (msspTransId != null) {
			do {
				try {
					Thread.sleep(500); // Poll for final signature response every 500ms
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
				status = MSSStatusQuery_Client.doStatusQuery(apID, msspTransId);
			} while	(status != null && ! status.equals("500")); // 500 = SIGNATURE (contains CMS signature)
		}
			
		// MSS_Receipt: Invoke a receipt message if signature was successful
		if (msspTransId != null && status != null && status.equals("500"))
			status = MSSReceipt_Client.doReceipt(apID, msisdn, receiptMessage, userLang, msspTransId);
	}
	
	/**
     * Return a unique transaction id
     * @return transaction id
     */
    private static String getNewTransactionId() {
    	// secure, easy but a little bit more expensive way to get a random alphanumeric string
        return new BigInteger(30, new SecureRandom()).toString(32);
    }

}
