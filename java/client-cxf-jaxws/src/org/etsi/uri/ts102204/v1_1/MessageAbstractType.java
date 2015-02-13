
package org.etsi.uri.ts102204.v1_1;

import java.math.BigInteger;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlSeeAlso;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.adapters.CollapsedStringAdapter;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;
import javax.xml.datatype.XMLGregorianCalendar;


/**
 * <p>Java-Klasse für MessageAbstractType complex type.
 * 
 * <p>Das folgende Schemafragment gibt den erwarteten Content an, der in dieser Klasse enthalten ist.
 * 
 * <pre>
 * &lt;complexType name="MessageAbstractType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="AP_Info">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;attribute name="AP_ID" use="required" type="{http://www.w3.org/2001/XMLSchema}anyURI" />
 *                 &lt;attribute name="AP_PWD" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                 &lt;attribute name="AP_TransID" use="required" type="{http://www.w3.org/2001/XMLSchema}NCName" />
 *                 &lt;attribute name="Instant" use="required" type="{http://www.w3.org/2001/XMLSchema}dateTime" />
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="MSSP_Info">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element name="MSSP_ID" type="{http://uri.etsi.org/TS102204/v1.1.2#}MeshMemberType"/>
 *                 &lt;/sequence>
 *                 &lt;attribute name="Instant" type="{http://www.w3.org/2001/XMLSchema}dateTime" />
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *       &lt;/sequence>
 *       &lt;attribute name="MajorVersion" use="required" type="{http://www.w3.org/2001/XMLSchema}integer" />
 *       &lt;attribute name="MinorVersion" use="required" type="{http://www.w3.org/2001/XMLSchema}integer" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "MessageAbstractType", propOrder = {
    "apInfo",
    "msspInfo"
})
@XmlSeeAlso({
    MSSReceiptReq.class,
    MSSReceiptResp.class,
    MSSSignatureReq.class,
    MSSProfileReq.class,
    MSSProfileResp.class,
    MSSStatusReq.class,
    MSSStatusResp.class,
    MSSSignatureResp.class
})
public abstract class MessageAbstractType {

    @XmlElement(name = "AP_Info", required = true)
    protected MessageAbstractType.APInfo apInfo;
    @XmlElement(name = "MSSP_Info", required = true)
    protected MessageAbstractType.MSSPInfo msspInfo;
    @XmlAttribute(name = "MajorVersion", required = true)
    protected BigInteger majorVersion;
    @XmlAttribute(name = "MinorVersion", required = true)
    protected BigInteger minorVersion;

    /**
     * Ruft den Wert der apInfo-Eigenschaft ab.
     * 
     * @return
     *     possible object is
     *     {@link MessageAbstractType.APInfo }
     *     
     */
    public MessageAbstractType.APInfo getAPInfo() {
        return apInfo;
    }

    /**
     * Legt den Wert der apInfo-Eigenschaft fest.
     * 
     * @param value
     *     allowed object is
     *     {@link MessageAbstractType.APInfo }
     *     
     */
    public void setAPInfo(MessageAbstractType.APInfo value) {
        this.apInfo = value;
    }

    /**
     * Ruft den Wert der msspInfo-Eigenschaft ab.
     * 
     * @return
     *     possible object is
     *     {@link MessageAbstractType.MSSPInfo }
     *     
     */
    public MessageAbstractType.MSSPInfo getMSSPInfo() {
        return msspInfo;
    }

    /**
     * Legt den Wert der msspInfo-Eigenschaft fest.
     * 
     * @param value
     *     allowed object is
     *     {@link MessageAbstractType.MSSPInfo }
     *     
     */
    public void setMSSPInfo(MessageAbstractType.MSSPInfo value) {
        this.msspInfo = value;
    }

    /**
     * Ruft den Wert der majorVersion-Eigenschaft ab.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getMajorVersion() {
        return majorVersion;
    }

    /**
     * Legt den Wert der majorVersion-Eigenschaft fest.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setMajorVersion(BigInteger value) {
        this.majorVersion = value;
    }

    /**
     * Ruft den Wert der minorVersion-Eigenschaft ab.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getMinorVersion() {
        return minorVersion;
    }

    /**
     * Legt den Wert der minorVersion-Eigenschaft fest.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setMinorVersion(BigInteger value) {
        this.minorVersion = value;
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
     *       &lt;attribute name="AP_ID" use="required" type="{http://www.w3.org/2001/XMLSchema}anyURI" />
     *       &lt;attribute name="AP_PWD" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
     *       &lt;attribute name="AP_TransID" use="required" type="{http://www.w3.org/2001/XMLSchema}NCName" />
     *       &lt;attribute name="Instant" use="required" type="{http://www.w3.org/2001/XMLSchema}dateTime" />
     *     &lt;/restriction>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "")
    public static class APInfo {

        @XmlAttribute(name = "AP_ID", required = true)
        @XmlSchemaType(name = "anyURI")
        protected String apid;
        @XmlAttribute(name = "AP_PWD", required = true)
        protected String appwd;
        @XmlAttribute(name = "AP_TransID", required = true)
        @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
        @XmlSchemaType(name = "NCName")
        protected String apTransID;
        @XmlAttribute(name = "Instant", required = true)
        @XmlSchemaType(name = "dateTime")
        protected XMLGregorianCalendar instant;

        /**
         * Ruft den Wert der apid-Eigenschaft ab.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getAPID() {
            return apid;
        }

        /**
         * Legt den Wert der apid-Eigenschaft fest.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setAPID(String value) {
            this.apid = value;
        }

        /**
         * Ruft den Wert der appwd-Eigenschaft ab.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getAPPWD() {
            return appwd;
        }

        /**
         * Legt den Wert der appwd-Eigenschaft fest.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setAPPWD(String value) {
            this.appwd = value;
        }

        /**
         * Ruft den Wert der apTransID-Eigenschaft ab.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getAPTransID() {
            return apTransID;
        }

        /**
         * Legt den Wert der apTransID-Eigenschaft fest.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setAPTransID(String value) {
            this.apTransID = value;
        }

        /**
         * Ruft den Wert der instant-Eigenschaft ab.
         * 
         * @return
         *     possible object is
         *     {@link XMLGregorianCalendar }
         *     
         */
        public XMLGregorianCalendar getInstant() {
            return instant;
        }

        /**
         * Legt den Wert der instant-Eigenschaft fest.
         * 
         * @param value
         *     allowed object is
         *     {@link XMLGregorianCalendar }
         *     
         */
        public void setInstant(XMLGregorianCalendar value) {
            this.instant = value;
        }

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
     *         &lt;element name="MSSP_ID" type="{http://uri.etsi.org/TS102204/v1.1.2#}MeshMemberType"/>
     *       &lt;/sequence>
     *       &lt;attribute name="Instant" type="{http://www.w3.org/2001/XMLSchema}dateTime" />
     *     &lt;/restriction>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "", propOrder = {
        "msspid"
    })
    public static class MSSPInfo {

        @XmlElement(name = "MSSP_ID", required = true)
        protected MeshMemberType msspid;
        @XmlAttribute(name = "Instant")
        @XmlSchemaType(name = "dateTime")
        protected XMLGregorianCalendar instant;

        /**
         * Ruft den Wert der msspid-Eigenschaft ab.
         * 
         * @return
         *     possible object is
         *     {@link MeshMemberType }
         *     
         */
        public MeshMemberType getMSSPID() {
            return msspid;
        }

        /**
         * Legt den Wert der msspid-Eigenschaft fest.
         * 
         * @param value
         *     allowed object is
         *     {@link MeshMemberType }
         *     
         */
        public void setMSSPID(MeshMemberType value) {
            this.msspid = value;
        }

        /**
         * Ruft den Wert der instant-Eigenschaft ab.
         * 
         * @return
         *     possible object is
         *     {@link XMLGregorianCalendar }
         *     
         */
        public XMLGregorianCalendar getInstant() {
            return instant;
        }

        /**
         * Legt den Wert der instant-Eigenschaft fest.
         * 
         * @param value
         *     allowed object is
         *     {@link XMLGregorianCalendar }
         *     
         */
        public void setInstant(XMLGregorianCalendar value) {
            this.instant = value;
        }

    }

}
