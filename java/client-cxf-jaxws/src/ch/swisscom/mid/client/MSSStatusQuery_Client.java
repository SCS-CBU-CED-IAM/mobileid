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
import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.DatatypeFactory;

import org.etsi.uri.ts102204.v1_1.*;
import org.etsi.uri.ts102204.etsi204_kiuru_wsdl.*;

public final class MSSStatusQuery_Client {

    private static final QName SERVICE_NAME = new QName("http://uri.etsi.org/TS102204/etsi204-kiuru.wsdl", "MSS_StatusService");

    /**
     * @param apID
     * @param msspTransId
     * @return MSS Status Code
     */
    public static String doStatusQuery(String apID, String msspTransId) {
		URL wsdlURL = MSSStatusService.WSDL_LOCATION;
      
        MSSStatusService ss = new MSSStatusService(wsdlURL, SERVICE_NAME);
        MSSStatusQueryType port = ss.getMSSStatusQueryPort();  
        
        ObjectFactory objectFactory = new ObjectFactory();
        org.etsi.uri.ts102204.v1_1.MSSStatusReq _mssStatusQuery_mssStatusReq = objectFactory.createMSSStatusReq();

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
		_mssStatusQuery_mssStatusReq.setMSSPInfo(msspInfo);

		_mssStatusQuery_mssStatusReq.setAPInfo(apInfo);
		_mssStatusQuery_mssStatusReq.setMajorVersion(BigInteger.valueOf(1));
		_mssStatusQuery_mssStatusReq.setMinorVersion(BigInteger.valueOf(1));
		
		_mssStatusQuery_mssStatusReq.setMSSPTransID(msspTransId);
        
        try {
            org.etsi.uri.ts102204.v1_1.MSSStatusResp _mssStatusQuery__return = port.mssStatusQuery(_mssStatusQuery_mssStatusReq);
            System.out.println("MSS_StatusQuery StatusCode: " + _mssStatusQuery__return.getStatus().getStatusCode().getValue());
            return _mssStatusQuery__return.getStatus().getStatusCode().getValue().toString();
        } catch (SOAPFaultException e) { 
            System.err.println("MSS_StatusQuery SOAPFaultException: " + e.getMessage());
			return null;
		} catch (MSSFaultMessage e) {
			e.printStackTrace();
			return null;
		}
	}

}
