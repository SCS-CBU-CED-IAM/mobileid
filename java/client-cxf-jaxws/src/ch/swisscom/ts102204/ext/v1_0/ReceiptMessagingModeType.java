
package ch.swisscom.ts102204.ext.v1_0;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlEnumValue;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java-Klasse für ReceiptMessagingModeType.
 * 
 * <p>Das folgende Schemafragment gibt den erwarteten Content an, der in dieser Klasse enthalten ist.
 * <p>
 * <pre>
 * &lt;simpleType name="ReceiptMessagingModeType">
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *     &lt;enumeration value="synch"/>
 *   &lt;/restriction>
 * &lt;/simpleType>
 * </pre>
 * 
 */
@XmlType(name = "ReceiptMessagingModeType")
@XmlEnum
public enum ReceiptMessagingModeType {

    @XmlEnumValue("synch")
    SYNCH("synch");
    private final String value;

    ReceiptMessagingModeType(String v) {
        value = v;
    }

    public String value() {
        return value;
    }

    public static ReceiptMessagingModeType fromValue(String v) {
        for (ReceiptMessagingModeType c: ReceiptMessagingModeType.values()) {
            if (c.value.equals(v)) {
                return c;
            }
        }
        throw new IllegalArgumentException(v);
    }

}
