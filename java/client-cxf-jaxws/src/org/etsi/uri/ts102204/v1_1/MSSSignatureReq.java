
package org.etsi.uri.ts102204.v1_1;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java-Klasse für MSS_SignatureReqType complex type.
 * 
 * <p>Das folgende Schemafragment gibt den erwarteten Content an, der in dieser Klasse enthalten ist.
 * 
 * <pre>
 * &lt;complexType name="MSS_SignatureReqType">
 *   &lt;complexContent>
 *     &lt;extension base="{http://uri.etsi.org/TS102204/v1.1.2#}MessageAbstractType">
 *       &lt;sequence>
 *         &lt;element name="MobileUser" type="{http://uri.etsi.org/TS102204/v1.1.2#}MobileUserType"/>
 *         &lt;element name="DataToBeSigned" type="{http://uri.etsi.org/TS102204/v1.1.2#}DataType"/>
 *         &lt;element name="SignatureProfile" type="{http://uri.etsi.org/TS102204/v1.1.2#}mssURIType" minOccurs="0"/>
 *         &lt;element name="AdditionalServices" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element name="Service" type="{http://uri.etsi.org/TS102204/v1.1.2#}AdditionalServiceType" maxOccurs="unbounded"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *       &lt;/sequence>
 *       &lt;attribute name="TimeOut" type="{http://www.w3.org/2001/XMLSchema}positiveInteger" />
 *       &lt;attribute name="MessagingMode" use="required" type="{http://uri.etsi.org/TS102204/v1.1.2#}MessagingModeType" />
 *     &lt;/extension>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "MSS_SignatureReqType", propOrder = {
    "mobileUser",
    "dataToBeSigned",
    "signatureProfile",
    "additionalServices"
})
@XmlRootElement(name = "MSS_SignatureReq")
public class MSSSignatureReq
    extends MessageAbstractType
{

    @XmlElement(name = "MobileUser", required = true)
    protected MobileUserType mobileUser;
    @XmlElement(name = "DataToBeSigned", required = true)
    protected DataType dataToBeSigned;
    @XmlElement(name = "SignatureProfile")
    protected MssURIType signatureProfile;
    @XmlElement(name = "AdditionalServices")
    protected MSSSignatureReq.AdditionalServices additionalServices;
    @XmlAttribute(name = "TimeOut")
    @XmlSchemaType(name = "positiveInteger")
    protected BigInteger timeOut;
    @XmlAttribute(name = "MessagingMode", required = true)
    protected MessagingModeType messagingMode;

    /**
     * Ruft den Wert der mobileUser-Eigenschaft ab.
     * 
     * @return
     *     possible object is
     *     {@link MobileUserType }
     *     
     */
    public MobileUserType getMobileUser() {
        return mobileUser;
    }

    /**
     * Legt den Wert der mobileUser-Eigenschaft fest.
     * 
     * @param value
     *     allowed object is
     *     {@link MobileUserType }
     *     
     */
    public void setMobileUser(MobileUserType value) {
        this.mobileUser = value;
    }

    /**
     * Ruft den Wert der dataToBeSigned-Eigenschaft ab.
     * 
     * @return
     *     possible object is
     *     {@link DataType }
     *     
     */
    public DataType getDataToBeSigned() {
        return dataToBeSigned;
    }

    /**
     * Legt den Wert der dataToBeSigned-Eigenschaft fest.
     * 
     * @param value
     *     allowed object is
     *     {@link DataType }
     *     
     */
    public void setDataToBeSigned(DataType value) {
        this.dataToBeSigned = value;
    }

    /**
     * Ruft den Wert der signatureProfile-Eigenschaft ab.
     * 
     * @return
     *     possible object is
     *     {@link MssURIType }
     *     
     */
    public MssURIType getSignatureProfile() {
        return signatureProfile;
    }

    /**
     * Legt den Wert der signatureProfile-Eigenschaft fest.
     * 
     * @param value
     *     allowed object is
     *     {@link MssURIType }
     *     
     */
    public void setSignatureProfile(MssURIType value) {
        this.signatureProfile = value;
    }

    /**
     * Ruft den Wert der additionalServices-Eigenschaft ab.
     * 
     * @return
     *     possible object is
     *     {@link MSSSignatureReq.AdditionalServices }
     *     
     */
    public MSSSignatureReq.AdditionalServices getAdditionalServices() {
        return additionalServices;
    }

    /**
     * Legt den Wert der additionalServices-Eigenschaft fest.
     * 
     * @param value
     *     allowed object is
     *     {@link MSSSignatureReq.AdditionalServices }
     *     
     */
    public void setAdditionalServices(MSSSignatureReq.AdditionalServices value) {
        this.additionalServices = value;
    }

    /**
     * Ruft den Wert der timeOut-Eigenschaft ab.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getTimeOut() {
        return timeOut;
    }

    /**
     * Legt den Wert der timeOut-Eigenschaft fest.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setTimeOut(BigInteger value) {
        this.timeOut = value;
    }

    /**
     * Ruft den Wert der messagingMode-Eigenschaft ab.
     * 
     * @return
     *     possible object is
     *     {@link MessagingModeType }
     *     
     */
    public MessagingModeType getMessagingMode() {
        return messagingMode;
    }

    /**
     * Legt den Wert der messagingMode-Eigenschaft fest.
     * 
     * @param value
     *     allowed object is
     *     {@link MessagingModeType }
     *     
     */
    public void setMessagingMode(MessagingModeType value) {
        this.messagingMode = value;
    }


    /**
     * <p>Java-Klasse für anonymous complex type.
     * 
     * <p>Das folgende Schemafragment gibt den erwarteten Content an, der in dieser Klasse enthalten ist.
     * 
     * <pre>
     * &lt;complexType>
     *   &lt;complexContent>
     *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
     *       &lt;sequence>
     *         &lt;element name="Service" type="{http://uri.etsi.org/TS102204/v1.1.2#}AdditionalServiceType" maxOccurs="unbounded"/>
     *       &lt;/sequence>
     *     &lt;/restriction>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "", propOrder = {
        "services"
    })
    public static class AdditionalServices {

        @XmlElement(name = "Service", required = true)
        protected List<AdditionalServiceType> services;

        /**
         * Gets the value of the services property.
         * 
         * <p>
         * This accessor method returns a reference to the live list,
         * not a snapshot. Therefore any modification you make to the
         * returned list will be present inside the JAXB object.
         * This is why there is not a <CODE>set</CODE> method for the services property.
         * 
         * <p>
         * For example, to add a new item, do as follows:
         * <pre>
         *    getServices().add(newItem);
         * </pre>
         * 
         * 
         * <p>
         * Objects of the following type(s) are allowed in the list
         * {@link AdditionalServiceType }
         * 
         * 
         */
        public List<AdditionalServiceType> getServices() {
            if (services == null) {
                services = new ArrayList<AdditionalServiceType>();
            }
            return this.services;
        }

    }

}
