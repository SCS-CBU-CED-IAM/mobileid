
package ch.swisscom.ts102204.ext.v1_0;

import java.math.BigInteger;
import java.util.HashMap;
import java.util.Map;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAnyAttribute;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.namespace.QName;


/**
 * <p>Java-Klasse für ReceiptExtensionType complex type.
 * 
 * <p>Das folgende Schemafragment gibt den erwarteten Content an, der in dieser Klasse enthalten ist.
 * 
 * <pre>
 * &lt;complexType name="ReceiptExtensionType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="ReceiptProfile" type="{http://www.swisscom.ch/TS102204/ext/v1.0.0}ReceiptProfileType" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attribute name="ReceiptMessagingMode" use="required" type="{http://www.swisscom.ch/TS102204/ext/v1.0.0}ReceiptMessagingModeType" />
 *       &lt;attribute name="TimeOut" type="{http://www.w3.org/2001/XMLSchema}positiveInteger" />
 *       &lt;attribute name="RetryTimeOut" type="{http://www.w3.org/2001/XMLSchema}positiveInteger" />
 *       &lt;attribute name="NextRetry" type="{http://www.w3.org/2001/XMLSchema}positiveInteger" />
 *       &lt;attribute name="UserAck" type="{http://www.w3.org/2001/XMLSchema}boolean" />
 *       &lt;attribute name="UserResponse" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="FaultMessage" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;anyAttribute processContents='lax' namespace='##other'/>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "ReceiptExtensionType", propOrder = {
    "receiptProfile"
})
public class ReceiptExtensionType {

    @XmlElement(name = "ReceiptProfile")
    protected ReceiptProfileType receiptProfile;
    @XmlAttribute(name = "ReceiptMessagingMode", required = true)
    protected ReceiptMessagingModeType receiptMessagingMode;
    @XmlAttribute(name = "TimeOut")
    @XmlSchemaType(name = "positiveInteger")
    protected BigInteger timeOut;
    @XmlAttribute(name = "RetryTimeOut")
    @XmlSchemaType(name = "positiveInteger")
    protected BigInteger retryTimeOut;
    @XmlAttribute(name = "NextRetry")
    @XmlSchemaType(name = "positiveInteger")
    protected BigInteger nextRetry;
    @XmlAttribute(name = "UserAck")
    protected Boolean userAck;
    @XmlAttribute(name = "UserResponse")
    protected String userResponse;
    @XmlAttribute(name = "FaultMessage")
    protected String faultMessage;
    @XmlAnyAttribute
    private Map<QName, String> otherAttributes = new HashMap<QName, String>();

    /**
     * Ruft den Wert der receiptProfile-Eigenschaft ab.
     * 
     * @return
     *     possible object is
     *     {@link ReceiptProfileType }
     *     
     */
    public ReceiptProfileType getReceiptProfile() {
        return receiptProfile;
    }

    /**
     * Legt den Wert der receiptProfile-Eigenschaft fest.
     * 
     * @param value
     *     allowed object is
     *     {@link ReceiptProfileType }
     *     
     */
    public void setReceiptProfile(ReceiptProfileType value) {
        this.receiptProfile = value;
    }

    /**
     * Ruft den Wert der receiptMessagingMode-Eigenschaft ab.
     * 
     * @return
     *     possible object is
     *     {@link ReceiptMessagingModeType }
     *     
     */
    public ReceiptMessagingModeType getReceiptMessagingMode() {
        return receiptMessagingMode;
    }

    /**
     * Legt den Wert der receiptMessagingMode-Eigenschaft fest.
     * 
     * @param value
     *     allowed object is
     *     {@link ReceiptMessagingModeType }
     *     
     */
    public void setReceiptMessagingMode(ReceiptMessagingModeType value) {
        this.receiptMessagingMode = value;
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
     * Ruft den Wert der retryTimeOut-Eigenschaft ab.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getRetryTimeOut() {
        return retryTimeOut;
    }

    /**
     * Legt den Wert der retryTimeOut-Eigenschaft fest.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setRetryTimeOut(BigInteger value) {
        this.retryTimeOut = value;
    }

    /**
     * Ruft den Wert der nextRetry-Eigenschaft ab.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getNextRetry() {
        return nextRetry;
    }

    /**
     * Legt den Wert der nextRetry-Eigenschaft fest.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setNextRetry(BigInteger value) {
        this.nextRetry = value;
    }

    /**
     * Ruft den Wert der userAck-Eigenschaft ab.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isUserAck() {
        return userAck;
    }

    /**
     * Legt den Wert der userAck-Eigenschaft fest.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setUserAck(Boolean value) {
        this.userAck = value;
    }

    /**
     * Ruft den Wert der userResponse-Eigenschaft ab.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUserResponse() {
        return userResponse;
    }

    /**
     * Legt den Wert der userResponse-Eigenschaft fest.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUserResponse(String value) {
        this.userResponse = value;
    }

    /**
     * Ruft den Wert der faultMessage-Eigenschaft ab.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFaultMessage() {
        return faultMessage;
    }

    /**
     * Legt den Wert der faultMessage-Eigenschaft fest.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFaultMessage(String value) {
        this.faultMessage = value;
    }

    /**
     * Gets a map that contains attributes that aren't bound to any typed property on this class.
     * 
     * <p>
     * the map is keyed by the name of the attribute and 
     * the value is the string value of the attribute.
     * 
     * the map returned by this method is live, and you can add new attribute
     * by updating the map directly. Because of this design, there's no setter.
     * 
     * 
     * @return
     *     always non-null
     */
    public Map<QName, String> getOtherAttributes() {
        return otherAttributes;
    }

}
