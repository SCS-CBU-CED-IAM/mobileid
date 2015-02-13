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
import java.net.*;
import java.util.*;

import javax.xml.namespace.QName;
import javax.xml.ws.soap.SOAPFaultException;
import javax.xml.datatype.*;

import org.etsi.uri.ts102204.v1_1.*;
import org.etsi.uri.ts102204.etsi204_kiuru_wsdl.*;

public final class MSSProfile_Client {

	private static final QName SERVICE_NAME = new QName("http://uri.etsi.org/TS102204/etsi204-kiuru.wsdl", "MSS_ProfileService");

	/**
	 * @param apID
	 * @param msisdn
	 * @return MSS Status Code
	 */
	public static String doProfileQuery(String apID, String msisdn) {
		URL wsdlURL = MSSProfileService.WSDL_LOCATION;

		MSSProfileService ss = new MSSProfileService(wsdlURL, SERVICE_NAME);
		MSSProfileType port = ss.getMSSProfilePort();

		ObjectFactory objectFactory = new ObjectFactory();
		org.etsi.uri.ts102204.v1_1.MSSProfileReq _mssProfileQuery_mssProfileReq = objectFactory.createMSSProfileReq();

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
		_mssProfileQuery_mssProfileReq.setMSSPInfo(msspInfo);

		_mssProfileQuery_mssProfileReq.setAPInfo(apInfo);
		_mssProfileQuery_mssProfileReq.setMajorVersion(BigInteger.valueOf(1));
		_mssProfileQuery_mssProfileReq.setMinorVersion(BigInteger.valueOf(1));
		
		org.etsi.uri.ts102204.v1_1.MobileUserType muType = new MobileUserType();
		muType.setMSISDN(msisdn);
		_mssProfileQuery_mssProfileReq.setMobileUser(muType);

		try {
			org.etsi.uri.ts102204.v1_1.MSSProfileResp _mssProfileQuery__return = port.mssProfileQuery(_mssProfileQuery_mssProfileReq);
			System.out.println("MSS_Profile StatusCode: " + _mssProfileQuery__return.getStatus().getStatusCode().getValue());
			return _mssProfileQuery__return.getStatus().getStatusCode().getValue().toString();
		} catch (SOAPFaultException e) {
			System.err.println("MSS_Profile SOAPFaultException: " + e.getMessage());
			return null;
		} catch (MSSFaultMessage e) {
			e.printStackTrace();
			return null;
		}
	}

}
