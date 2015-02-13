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

import java.math.BigInteger;
import java.net.URL;
import java.util.GregorianCalendar;
import java.util.UUID;

import javax.xml.namespace.QName;
import javax.xml.ws.soap.SOAPFaultException;
import javax.xml.bind.JAXBElement;
import javax.xml.datatype.*;

import org.etsi.uri.ts102204.v1_1.*;
import org.etsi.uri.ts102204.etsi204_kiuru_wsdl.*;

import ch.swisscom.ts102204.ext.v1_0.ReceiptExtensionType;

public final class MSSReceipt_Client {

	private static final QName SERVICE_NAME = new QName("http://uri.etsi.org/TS102204/etsi204-kiuru.wsdl", "MSS_ReceiptService");

	/**
	 * @param apID
	 * @param msisdn
	 * @param receiptMessage
	 * @param userLang
	 * @param msspTransId
	 * @return MSS Status Code
	 */
	public static String doReceipt(String apID, String msisdn, String receiptMessage, String userLang, String msspTransId) {
		URL wsdlURL = MSSReceiptService.WSDL_LOCATION;

		MSSReceiptService ss = new MSSReceiptService(wsdlURL, SERVICE_NAME);
		MSSReceiptType port = ss.getMSSReceiptPort();

		ObjectFactory objectFactory = new ObjectFactory();
		org.etsi.uri.ts102204.v1_1.MSSReceiptReq _mssReceipt_mssReceiptReq = objectFactory.createMSSReceiptReq();

		org.etsi.uri.ts102204.v1_1.MessageAbstractType.APInfo apInfo = objectFactory.createMessageAbstractTypeAPInfo();
		apInfo.setAPID(apID);
		apInfo.setAPPWD("");
		apInfo.setAPTransID("ID-" + UUID.randomUUID());
		try {
			apInfo.setInstant(DatatypeFactory.newInstance().newXMLGregorianCalendar(new GregorianCalendar()));
		} catch (DatatypeConfigurationException e1) {
			e1.printStackTrace();
		}

		org.etsi.uri.ts102204.v1_1.MessageAbstractType.MSSPInfo msspInfo = objectFactory.createMessageAbstractTypeMSSPInfo();
		org.etsi.uri.ts102204.v1_1.MeshMemberType meshMemberType = new MeshMemberType();
		meshMemberType.setURI("http://mid.swisscom.ch/");
		msspInfo.setMSSPID(meshMemberType);
		_mssReceipt_mssReceiptReq.setMSSPInfo(msspInfo);

		_mssReceipt_mssReceiptReq.setAPInfo(apInfo);
		_mssReceipt_mssReceiptReq.setMajorVersion(BigInteger.valueOf(1));
		_mssReceipt_mssReceiptReq.setMinorVersion(BigInteger.valueOf(1));
		_mssReceipt_mssReceiptReq.setMSSPTransID(msspTransId);

		org.etsi.uri.ts102204.v1_1.MobileUserType muType = new MobileUserType();
		muType.setMSISDN(msisdn);
		_mssReceipt_mssReceiptReq.setMobileUser(muType);

		org.etsi.uri.ts102204.v1_1.StatusType statusType = objectFactory.createStatusType();
		org.etsi.uri.ts102204.v1_1.StatusCodeType statusCodeType = objectFactory.createStatusCodeType();
		statusCodeType.setValue(BigInteger.valueOf(100));
		statusType.setStatusCode(statusCodeType);
		org.etsi.uri.ts102204.v1_1.StatusDetailType statusDetailType = objectFactory.createStatusDetailType();
		ch.swisscom.ts102204.ext.v1_0.ObjectFactory extObj = new ch.swisscom.ts102204.ext.v1_0.ObjectFactory();
		ch.swisscom.ts102204.ext.v1_0.ReceiptExtensionType extType = extObj.createReceiptExtensionType();
		ch.swisscom.ts102204.ext.v1_0.ReceiptProfileType profType = extObj.createReceiptProfileType();
		profType.setLanguage(userLang);
		profType.setReceiptProfileURI("http://mss.swisscom.ch/synch");
		extType.setReceiptProfile(profType);
		extType.setReceiptMessagingMode(ch.swisscom.ts102204.ext.v1_0.ReceiptMessagingModeType.SYNCH);
		extType.setUserAck(true);
		statusDetailType.getServiceResponsesAndReceiptRequestExtensionsAndReceiptResponseExtensions().add(extObj.createReceiptRequestExtension(extType));
		statusType.setStatusDetail(statusDetailType);
		_mssReceipt_mssReceiptReq.setStatus(statusType);

		org.etsi.uri.ts102204.v1_1.DataType messageDT = objectFactory.createDataType();
		messageDT.setEncoding("UTF-8");
		messageDT.setMimeType("text/plain");
		messageDT.setValue(receiptMessage);
		_mssReceipt_mssReceiptReq.setMessage(messageDT);
		
		
		try {
			org.etsi.uri.ts102204.v1_1.MSSReceiptResp _mssReceipt__return = port.mssReceipt(_mssReceipt_mssReceiptReq);
			System.out.println("MSS_Receipt StatusCode: " + _mssReceipt__return.getStatus().getStatusCode().getValue());

			@SuppressWarnings("unchecked")
			ReceiptExtensionType status = ((JAXBElement<ReceiptExtensionType>) _mssReceipt__return.getStatus().getStatusDetail().getServiceResponsesAndReceiptRequestExtensionsAndReceiptResponseExtensions().get(0)).getValue();			
			System.out.println("MSS_Receipt UserResponse: " + status.getUserResponse());
			
			return _mssReceipt__return.getStatus().getStatusCode().getValue().toString();
		} catch (SOAPFaultException e) {
			System.err.println("MSS_Receipt SOAPFaultException: " + e.getMessage());
			return null;
		} catch (MSSFaultMessage e) {
			e.printStackTrace();
			return null;
		}
	}

}
