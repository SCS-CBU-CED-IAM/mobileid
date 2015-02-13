
package org.w3._2000._09.xmldsig_;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java-Klasse für SignatureType complex type.
 * 
 * <p>Das folgende Schemafragment gibt den erwarteten Content an, der in dieser Klasse enthalten ist.
 * 
 * <pre>
 * &lt;complexType name="SignatureType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element ref="{http://www.w3.org/2000/09/xmldsig#}SignatureValue"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "SignatureType", propOrder = {
    "signatureValue"
})
@XmlRootElement(name = "Signature")
public class Signature {

    @XmlElement(name = "SignatureValue", required = true)
    protected SignatureValue signatureValue;

    /**
     * Ruft den Wert der signatureValue-Eigenschaft ab.
     * 
     * @return
     *     possible object is
     *     {@link SignatureValue }
     *     
     */
    public SignatureValue getSignatureValue() {
        return signatureValue;
    }

    /**
     * Legt den Wert der signatureValue-Eigenschaft fest.
     * 
     * @param value
     *     allowed object is
     *     {@link SignatureValue }
     *     
     */
    public void setSignatureValue(SignatureValue value) {
        this.signatureValue = value;
    }

}
