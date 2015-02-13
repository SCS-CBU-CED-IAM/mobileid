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

import java.net.URL;

import javax.xml.namespace.QName;
import javax.xml.ws.soap.SOAPFaultException;

import java.math.BigInteger;
import java.util.*;

import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.DatatypeFactory;

import org.etsi.uri.ts102204.v1_1.*;
import org.etsi.uri.ts102204.etsi204_kiuru_wsdl.*;

public final class MSSSignature_Client {
	
	private static final QName SERVICE_NAME = new QName("http://uri.etsi.org/TS102204/etsi204-kiuru.wsdl", "MSS_SignatureService");

	/**
	 * @param apID
	 * @param msisdn
	 * @param dtbs
	 * @param userLang
	 * @return MSSP Transaction ID
	 */
	public static String doSignature(String apID, String msisdn, String dtbs, String userLang) {		
		URL wsdlURL = MSSSignatureService.WSDL_LOCATION;

		MSSSignatureService ss = new MSSSignatureService(wsdlURL, SERVICE_NAME);
		MSSSignatureType port = ss.getMSSSignaturePort();

		ObjectFactory objectFactory = new ObjectFactory();
		org.etsi.uri.ts102204.v1_1.MSSSignatureReq _mssSignature_mssSignatureReq = objectFactory.createMSSSignatureReq();

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
		_mssSignature_mssSignatureReq.setMSSPInfo(msspInfo);

		_mssSignature_mssSignatureReq.setAPInfo(apInfo);
		_mssSignature_mssSignatureReq.setMajorVersion(BigInteger.valueOf(1));
		_mssSignature_mssSignatureReq.setMinorVersion(BigInteger.valueOf(1));
		_mssSignature_mssSignatureReq.setTimeOut(BigInteger.valueOf(80));
		_mssSignature_mssSignatureReq.setMessagingMode(org.etsi.uri.ts102204.v1_1.MessagingModeType.ASYNCH_CLIENT_SERVER);

		org.etsi.uri.ts102204.v1_1.MobileUserType muType = new MobileUserType();
		muType.setMSISDN(msisdn);
		_mssSignature_mssSignatureReq.setMobileUser(muType);

		org.etsi.uri.ts102204.v1_1.DataType dtbsType = objectFactory.createDataType();
		dtbsType.setEncoding("UTF-8");
		dtbsType.setMimeType("text/plain");
		dtbsType.setValue(dtbs);
		_mssSignature_mssSignatureReq.setDataToBeSigned(dtbsType);

		org.etsi.uri.ts102204.v1_1.MssURIType sigProfile = new MssURIType();
		sigProfile.setMssURI("http://mid.swisscom.ch/MID/v1/AuthProfile1");
		_mssSignature_mssSignatureReq.setSignatureProfile(sigProfile);

		org.etsi.uri.ts102204.v1_1.MssURIType service = new MssURIType();
		service.setMssURI("http://mss.ficom.fi/TS102204/v1.0.0#userLang");

		org.etsi.uri.ts102204.v1_1.AdditionalServiceType addServiceTypeLang = objectFactory.createAdditionalServiceType();
		addServiceTypeLang.setDescription(service);
		addServiceTypeLang.getUserLangs().add(userLang);
		org.etsi.uri.ts102204.v1_1.MSSSignatureReq.AdditionalServices addService = objectFactory.createMSSSignatureReqAdditionalServices();
		addService.getServices().add(addServiceTypeLang);
		_mssSignature_mssSignatureReq.setAdditionalServices(addService);
		
		// Optional subscriberInfo service. Will return MCCMNC information of the subscriber, if the client (AP) is allowed to use this service
		org.etsi.uri.ts102204.v1_1.MssURIType subscriberInfo = new MssURIType();
		subscriberInfo.setMssURI("http://mid.swisscom.ch/as#subscriberInfo");
		org.etsi.uri.ts102204.v1_1.AdditionalServiceType addServiceTypeSubscriberInfo = objectFactory.createAdditionalServiceType();
		addServiceTypeSubscriberInfo.setDescription(subscriberInfo);
		addService.getServices().add(addServiceTypeSubscriberInfo);
		
		_mssSignature_mssSignatureReq.setAdditionalServices(addService);

		try {
			org.etsi.uri.ts102204.v1_1.MSSSignatureResp _mssSignature__return = port.mssSignature(_mssSignature_mssSignatureReq);		
			System.out.println("MSS_Signature StatusCode: " + _mssSignature__return.getStatus().getStatusCode().getValue());
			System.out.println("MSS_Signature MSSP_TransID: " + _mssSignature__return.getMSSPTransID());
			return _mssSignature__return.getMSSPTransID();
		} catch (SOAPFaultException e) {
			System.err.println("MSS_Signature SOAPFaultException: " + e.getMessage());
			return null;
		} catch (MSSFaultMessage e) {
			e.printStackTrace();
			return null;
		}
	}

}
