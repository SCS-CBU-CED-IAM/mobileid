
package fi.ficom.mss.ts102204.v1_0;

import javax.xml.bind.JAXBElement;
import javax.xml.bind.annotation.XmlElementDecl;
import javax.xml.bind.annotation.XmlRegistry;
import javax.xml.namespace.QName;


/**
 * This object contains factory methods for each 
 * Java content interface and Java element interface 
 * generated in the fi.ficom.mss.ts102204.v1_0 package. 
 * <p>An ObjectFactory allows you to programatically 
 * construct new instances of the Java representation 
 * for XML content. The Java representation of XML 
 * content can consist of schema derived interfaces 
 * and classes representing the binding of schema 
 * type definitions, element declarations and model 
 * groups.  Factory methods for each of these are 
 * provided in this class.
 * 
 */
@XmlRegistry
public class ObjectFactory {

    private final static QName _UserLang_QNAME = new QName("http://mss.ficom.fi/TS102204/v1.0.0#", "UserLang");

    /**
     * Create a new ObjectFactory that can be used to create new instances of schema derived classes for package: fi.ficom.mss.ts102204.v1_0
     * 
     */
    public ObjectFactory() {
    }

    /**
     * Create an instance of {@link ServiceResponses }
     * 
     */
    public ServiceResponses createServiceResponses() {
        return new ServiceResponses();
    }

    /**
     * Create an instance of {@link ServiceResponses.ServiceResponse }
     * 
     */
    public ServiceResponses.ServiceResponse createServiceResponsesServiceResponse() {
        return new ServiceResponses.ServiceResponse();
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://mss.ficom.fi/TS102204/v1.0.0#", name = "UserLang", defaultValue = "de")
    public JAXBElement<String> createUserLang(String value) {
        return new JAXBElement<String>(_UserLang_QNAME, String.class, null, value);
    }

}
