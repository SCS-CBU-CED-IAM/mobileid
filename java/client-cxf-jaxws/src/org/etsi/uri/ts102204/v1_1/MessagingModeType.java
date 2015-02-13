
package org.etsi.uri.ts102204.v1_1;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlEnumValue;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java-Klasse für MessagingModeType.
 * 
 * <p>Das folgende Schemafragment gibt den erwarteten Content an, der in dieser Klasse enthalten ist.
 * <p>
 * <pre>
 * &lt;simpleType name="MessagingModeType">
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *     &lt;enumeration value="synch"/>
 *     &lt;enumeration value="asynchClientServer"/>
 *   &lt;/restriction>
 * &lt;/simpleType>
 * </pre>
 * 
 */
@XmlType(name = "MessagingModeType")
@XmlEnum
public enum MessagingModeType {

    @XmlEnumValue("synch")
    SYNCH("synch"),
    @XmlEnumValue("asynchClientServer")
    ASYNCH_CLIENT_SERVER("asynchClientServer");
    private final String value;

    MessagingModeType(String v) {
        value = v;
    }

    public String value() {
        return value;
    }

    public static MessagingModeType fromValue(String v) {
        for (MessagingModeType c: MessagingModeType.values()) {
            if (c.value.equals(v)) {
                return c;
            }
        }
        throw new IllegalArgumentException(v);
    }

}
