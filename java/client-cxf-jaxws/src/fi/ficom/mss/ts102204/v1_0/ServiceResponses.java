
package fi.ficom.mss.ts102204.v1_0;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;
import ch.swisscom.mid.ts102204.as.v1.SubscriberInfo;
import org.etsi.uri.ts102204.v1_1.MssURIType;


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
 *         &lt;element name="ServiceResponse" maxOccurs="unbounded" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element name="Description" type="{http://uri.etsi.org/TS102204/v1.1.2#}mssURIType"/>
 *                   &lt;element ref="{http://mid.swisscom.ch/TS102204/as/v1.0}SubscriberInfo" minOccurs="0"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
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
    "serviceResponses"
})
@XmlRootElement(name = "ServiceResponses")
public class ServiceResponses {

    @XmlElement(name = "ServiceResponse")
    protected List<ServiceResponses.ServiceResponse> serviceResponses;

    /**
     * Gets the value of the serviceResponses property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the serviceResponses property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getServiceResponses().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link ServiceResponses.ServiceResponse }
     * 
     * 
     */
    public List<ServiceResponses.ServiceResponse> getServiceResponses() {
        if (serviceResponses == null) {
            serviceResponses = new ArrayList<ServiceResponses.ServiceResponse>();
        }
        return this.serviceResponses;
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
     *         &lt;element name="Description" type="{http://uri.etsi.org/TS102204/v1.1.2#}mssURIType"/>
     *         &lt;element ref="{http://mid.swisscom.ch/TS102204/as/v1.0}SubscriberInfo" minOccurs="0"/>
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
        "description",
        "subscriberInfo"
    })
    public static class ServiceResponse {

        @XmlElement(name = "Description", required = true)
        protected MssURIType description;
        @XmlElement(name = "SubscriberInfo", namespace = "http://mid.swisscom.ch/TS102204/as/v1.0")
        protected SubscriberInfo subscriberInfo;

        /**
         * Ruft den Wert der description-Eigenschaft ab.
         * 
         * @return
         *     possible object is
         *     {@link MssURIType }
         *     
         */
        public MssURIType getDescription() {
            return description;
        }

        /**
         * Legt den Wert der description-Eigenschaft fest.
         * 
         * @param value
         *     allowed object is
         *     {@link MssURIType }
         *     
         */
        public void setDescription(MssURIType value) {
            this.description = value;
        }

        /**
         * Ruft den Wert der subscriberInfo-Eigenschaft ab.
         * 
         * @return
         *     possible object is
         *     {@link SubscriberInfo }
         *     
         */
        public SubscriberInfo getSubscriberInfo() {
            return subscriberInfo;
        }

        /**
         * Legt den Wert der subscriberInfo-Eigenschaft fest.
         * 
         * @param value
         *     allowed object is
         *     {@link SubscriberInfo }
         *     
         */
        public void setSubscriberInfo(SubscriberInfo value) {
            this.subscriberInfo = value;
        }

    }

}
