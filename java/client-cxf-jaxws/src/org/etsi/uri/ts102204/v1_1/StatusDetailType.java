
package org.etsi.uri.ts102204.v1_1;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElementRef;
import javax.xml.bind.annotation.XmlElementRefs;
import javax.xml.bind.annotation.XmlType;
import ch.swisscom.ts102204.ext.v1_0.ReceiptExtensionType;
import fi.ficom.mss.ts102204.v1_0.ServiceResponses;


/**
 * <p>Java-Klasse für StatusDetailType complex type.
 * 
 * <p>Das folgende Schemafragment gibt den erwarteten Content an, der in dieser Klasse enthalten ist.
 * 
 * <pre>
 * &lt;complexType name="StatusDetailType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;choice maxOccurs="unbounded" minOccurs="0">
 *         &lt;element ref="{http://mss.ficom.fi/TS102204/v1.0.0#}ServiceResponses"/>
 *         &lt;element ref="{http://www.swisscom.ch/TS102204/ext/v1.0.0}ReceiptRequestExtension"/>
 *         &lt;element ref="{http://www.swisscom.ch/TS102204/ext/v1.0.0}ReceiptResponseExtension"/>
 *       &lt;/choice>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "StatusDetailType", propOrder = {
    "serviceResponsesAndReceiptRequestExtensionsAndReceiptResponseExtensions"
})
public class StatusDetailType {

    @XmlElementRefs({
        @XmlElementRef(name = "ServiceResponses", namespace = "http://mss.ficom.fi/TS102204/v1.0.0#", type = ServiceResponses.class, required = false),
        @XmlElementRef(name = "ReceiptRequestExtension", namespace = "http://www.swisscom.ch/TS102204/ext/v1.0.0", type = JAXBElement.class, required = false),
        @XmlElementRef(name = "ReceiptResponseExtension", namespace = "http://www.swisscom.ch/TS102204/ext/v1.0.0", type = JAXBElement.class, required = false)
    })
    protected List<Object> serviceResponsesAndReceiptRequestExtensionsAndReceiptResponseExtensions;

    /**
     * Gets the value of the serviceResponsesAndReceiptRequestExtensionsAndReceiptResponseExtensions property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the serviceResponsesAndReceiptRequestExtensionsAndReceiptResponseExtensions property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getServiceResponsesAndReceiptRequestExtensionsAndReceiptResponseExtensions().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link ServiceResponses }
     * {@link JAXBElement }{@code <}{@link ReceiptExtensionType }{@code >}
     * {@link JAXBElement }{@code <}{@link ReceiptExtensionType }{@code >}
     * 
     * 
     */
    public List<Object> getServiceResponsesAndReceiptRequestExtensionsAndReceiptResponseExtensions() {
        if (serviceResponsesAndReceiptRequestExtensionsAndReceiptResponseExtensions == null) {
            serviceResponsesAndReceiptRequestExtensionsAndReceiptResponseExtensions = new ArrayList<Object>();
        }
        return this.serviceResponsesAndReceiptRequestExtensionsAndReceiptResponseExtensions;
    }

}
