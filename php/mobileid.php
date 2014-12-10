<?php
/**
 * @version        2.0.0
 * @package        mobileid
 * @copyright      Copyright (C) 2014. All rights reserved.
 * @license        GNU General Public License version 2 or later; see LICENSE.md
 * @author         Swisscom (Schweiz AG)
 * Requirements    PHP 5.3.x, php_soap, php_libxml, OpenSSL
 *
 * Open tasks:
 * - Avoid validation at service and use revocation check over OCSP/CRL when PHP will provide it
 */

class mobileid {
    private $ap_id;                        // AP UserID provided by Swisscom
    private $ap_pwd;                       // AP Password provided by Swisscom

    private $client;                       // SOAP client
    const WSDL = 'mobileid.wsdl';          // Mobile ID WSDL file
    const TIMEOUT_CON = 90;                // SOAP client connection timeout
    private $base_url;                     // Base URL of the service
    private $response;                     // SOAP client response

    public $statuscode;                    // Status code
    public $statusmessage;                 // Status message
    public $statusdetail;                  // Status detail
    public $mid_certificate;               // Mobile ID certificate related to signature
    public $mid_serialnumber;              // Mobile ID serial number in the DN of the certificate

    private $mid_signature;                // Mobile ID signature (Base64 encoded)
    private $mid_MSSPtransID;              // Mobile ID MSSP transaction id

    /**
     * Mobile ID class
     * #params     string    AP ID provided by Swisscom
     * #params     string    AP Password provided by Swisscom
     * #params     string    Certificate/key that is allowed to access the service
     * #params     string    Location of Certificate Authority file which should be used to authenticate the identity of the remote peer.
     * #params     array     Additional SOAP client options
     * @return     null
     */
    public function __construct($ap_id, $ap_pwd, $ap_cert, $cafile, $myOpts = null) {
        /* Set the AP Infos */
        $this->ap_id = $ap_id;
        $this->ap_pwd = $ap_pwd;

        /* Set SOAP context and options */
        $context = stream_context_create(array(
            'ssl' => array(
                'verify_peer' => true,
                'allow_self_signed' => false,
                'cafile' => $cafile
                )
            ));
        $options = array(
            'trace' => true,
            'exceptions' => false,
            'encoding' => 'UTF-8',
            'soap_version' => SOAP_1_2,
            'local_cert' => $ap_cert,
            'connection_timeout' => self::TIMEOUT_CON,
            'stream_context' => $context
            );
        if (isSet($myOpts)) $options = array_merge($options, (array)$myOpts);

        /* Check for provided files existence */
        if (!file_exists($ap_cert)) trigger_error('mobileid::construct: file not found ' . $ap_cert, E_USER_WARNING);
        if (!file_exists($cafile))  trigger_error('mobileid::construct: file not found ' . $cafile, E_USER_WARNING);

        /* SOAP client with Mobile ID MSS service */
        $this->setBaseURL('https://mobileid.swisscom.com');
        $this->client = new SoapClient(dirname(__FILE__) . '/' . self::WSDL, $options);
    }

    private function __doCall($request, $params) {
        $this->statuscode = '';
        $this->statusmessage = '';
        $this->statusdetail = '';
        try {
            /* Call the SOAP function */
            $this->response = $this->client->__soapCall($request, array('parameters' => $params));

            /* SOAP fault ? */
            if (is_soap_fault($this->response)) {
                /* Get the fault code */
                if (isset($this->response->faultcode))
                    $this->statuscode = (string)$this->response->faultcode;
                /* Workaround: as the soap_fault does not find the proper subcode error returned by the service */
                if ($this->statuscode == 'soapenv:Receiver' | $this->statuscode == 'soapenv:Sender') {
                    /* SimpleXML does not correctly parse SOAP XML results if the result comes back with colons ‘:’ in a tag, like <soap:Envelope>.
                     * Why? Because SimpleXML treats the colon character ‘:’ as an XML namespace, and places the entire contents of the SOAP XML result
                     * inside a namespace within the SimpleXML object. There is no real way to correct this using SimpleXML, but we can alter the raw XML result
                     * a little before we send it to SimpleXML to parse.
                     */
                    $response_xml = simplexml_load_string(preg_replace("/(<\/?)(\w+):([^>]*>)/", "$1$2$3", $this->getLastResponse()));
                    if (isset($response_xml->soapenvBody->soapenvFault->soapenvCode->soapenvSubcode->soapenvValue))
                        $this->statuscode = (string)$response_xml->soapenvBody->soapenvFault->soapenvCode->soapenvSubcode->soapenvValue;
                }

                /* Get the faultstring */
                if (isset($this->response->faultstring))
                    $this->statusmessage = (string)$this->response->faultstring;

                /* Get the details */
                if (isset($this->response->detail)) {
                    /* If there are several response details, then the 2nd one is the most relevant */
                    if (is_array($this->response->detail->detail))
                        $this->statusdetail = (string)$this->response->detail->detail[1];
                    else
                        $this->statusdetail = (string)$this->response->detail->detail;
                }

                return(false);
            }

            /* Get the status code */
            if (isset($this->response->Status->StatusCode->Value))
                $this->statuscode = (string)$this->response->Status->StatusCode->Value;
            /* Get the status message */
            if (isset($this->response->Status->StatusMessage))
                $this->statusmessage = (string)$this->response->Status->StatusMessage;

            return(true);
        } catch (Exception $e) {
            return(false);
        }
    }

    /**
     * profileQuery request
     * #params     string    phone number
     * @return     boolean   true on success, false on failure
     */
    public function profileQuery($phoneNumber) {
        $params = array(
            'MajorVersion' => 1,
            'MinorVersion' => 1,
            'AP_Info' => array(
                'AP_ID' => $this->ap_id,
                'AP_PWD' => $this->ap_pwd,
                'AP_TransID' => $this->__createAPTransID(),
                'Instant' => $this->__createInstant()
            ),
            'MSSP_Info' => array(
                'MSSP_ID' => array('URI' => 'http://mid.swisscom.ch/')
            ),
            'MobileUser' => array(
                'MSISDN' => $phoneNumber
            )
         );

        $this->client->__setLocation($this->base_url . '/soap/services/MSS_ProfilePort');
        $ok = $this->__doCall('MSS_ProfileQuery', $params);

        return($ok);
    }

    /**
     * signature request
     * #params     string    phone number
     * #params     string    message
     * #params     string    user language
     * #params     string    location of CA file which should be used during verifications
     * @return     boolean   true on success, false on failure
     */
    public function signature($phoneNumber, $message, $userlang, $cafile = '') {
        $this->mid_signature = '';
        $this->mid_MSSPtransID = '';
        $this->mid_certificate = '';
        $this->mid_serialnuber = '';

        $params = array(
            'MajorVersion' => 1,
            'MinorVersion' => 1,
            'TimeOut' => 80,
            'MessagingMode' => 'synch',
            'AP_Info' => array(
                'AP_ID' => $this->ap_id,
                'AP_PWD' => $this->ap_pwd,
                'AP_TransID' => $this->__createAPTransID(),
                'Instant' => $this->__createInstant()
            ),
            'MSSP_Info' => array(
                'MSSP_ID' => array('URI' => 'http://mid.swisscom.ch/')
            ),
            'MobileUser' => array(
                'MSISDN' => $phoneNumber
            ),
            'DataToBeSigned' => array(
                'MimeType' => 'text/plain',
                'Encoding' => 'UTF-8',
                '_' => $message
            ),
            'SignatureProfile' => array('mssURI' => 'http://mid.swisscom.ch/MID/v1/AuthProfile1'),
            'AdditionalServices' => array(
                array(
                    'Description' => array('mssURI' => 'http://uri.etsi.org/TS102204/v1.1.2#validate')
                ),
                array(
                    'Description' => array('mssURI' => 'http://mss.ficom.fi/TS102204/v1.0.0#userLang'),
                    'UserLang' => $userlang,
                ),
            ),
            'MSS_Format' => array('mssURI' => 'http://uri.etsi.org/TS102204/v1.1.2#PKCS7')
        );

        $this->client->__setLocation($this->base_url . '/soap/services/MSS_SignaturePort');
        if (!$this->__doCall('MSS_Signature', $params)) return(false);

        /* Get the signature details and ensure proper base64 encoding */
        $mid_signature = $this->response->MSS_Signature->Base64Signature;
        if (base64_decode($mid_signature, true)) $this->mid_signature = $mid_signature;
        else $this->mid_signature = base64_encode($mid_signature);

        /* Get the MSSP Transaction ID */
        $this->mid_MSSPtransID  = $this->response->MSSP_TransID;

        /* Check the signature and get the signer */
        if (!$this->__checkSignatureAndGetSigner($this->mid_signature, $message, $cafile)) return(false);

        return(true);
    }

    /**
     * receipt request
     * #params     string    phone number
     * #params     string    MSSP TransID
     * #params     string    message
     * #params     string    user language
     * #params     string    optional public certificate of the mobile user to encrypt the message
     * @return     boolean   true on success, false on failure
     */
    public function receipt($phoneNumber, $transID, $message, $userlang, $publicKey = null) {
        $params = array(
            'MajorVersion' => 1,
            'MinorVersion' => 1,
            'MSSP_TransID' => $transID,
            'AP_Info' => array(
                'AP_ID' => $this->ap_id,
                'AP_PWD' => $this->ap_pwd,
                'AP_TransID' => $this->__createAPTransID(),
                'Instant' => $this->__createInstant()
            ),
            'MSSP_Info' => array(
                'MSSP_ID' => array('URI' => 'http://mid.swisscom.ch/')
            ),
            'MobileUser' => array(
                'MSISDN' => $phoneNumber
            ),
            'Status' => array(
                'StatusCode' => array('Value' => '500'),
                'StatusDetail' => array(
                    'ReceiptRequestExtension' => array(
                        'ReceiptMessagingMode' => 'synch',
                        'UserAck' => 'true',
                        'ReceiptProfile' => array(
                            'Language' => $userlang,
                            'ReceiptProfileURI' => 'http://mss.swisscom.ch/synch'
                        ),
                    ),
                ),
            ),
        );
        /* Normal receipt */
        $msg = array(
            'Message' => array(
                'MimeType' => 'text/plain',
                'Encoding' => 'UTF-8',
                '_' => $message
            )
        );
        /* or encrypted receipt ? */
        if (isset($publicKey)) {
            /* Check if special characters are contained in the message */
            if (mb_detect_encoding($message) != 'ASCII') {
                /* Encrypt UCS-2 prefixed with Hex 80 */
                $message = pack('H*', 80) . iconv('UTF-8', 'UCS-2BE', $message);
            }
 
            /* Encrypt message with public key and base64 encoding */
            if (!openssl_public_encrypt($message, $encrypted, $publicKey))
                trigger_error('mobileid::receipt: openssl_public_encrypt ' . openssl_error_string(), E_USER_ERROR);
            $encrypted = base64_encode($encrypted);

            /* Set proper message options */
            $msg = array(
                'Message' => array(
                    'MimeType' => 'application/alauda-rsamessage',
                    'Encoding' => 'BASE64',
                    '_' => $encrypted
                )
            );
        }
        if (isSet($msg)) $params = array_merge($params, (array)$msg);

        $this->client->__setLocation($this->base_url . '/soap/services/MSS_ReceiptPort');
        $ok = $this->__doCall('MSS_Receipt', $params);
        if ($ok) {
            /* Get the receipt response details */
            if (isset($this->response->Status->StatusDetail->ReceiptResponseExtension->UserResponse))
                $this->statusdetail = (string)$this->response->Status->StatusDetail->ReceiptResponseExtension->UserResponse;
        }

        return($ok);
    }

    /**
     * __createAPTransID - Creates a unique AP Transaction ID
     * @return     string
     */
    private function __createAPTransID() {
        $ap_trans_id = 'AP.PHP.'.rand(89999, 10000).'.'.rand(8999, 1000);
        
        return($ap_trans_id);
    }

    /**
     * __createInstant - Creates a unique AP Instant
     * @return     string
     */
    private function __createInstant() {
        date_default_timezone_set(@date_default_timezone_get());
        $timestamp = time();
        $ap_instant = date('Y-m-d', $timestamp).'T'.date('H:i:sP', $timestamp);

        return($ap_instant);
    }

    /**
     * setBaseURL - Sets the base URL for the location of the service
     * #params     string    Base URL
     */
    public function setBaseURL($url) {
        $this->base_url = (string)$url;
    }

    /**
     * getLastRequest - Returns last request to Mobile ID service
     * @return     string
     */
    public function getLastRequest() {
        return($this->client->__getLastRequest());
    }

    /**
     * getLastResponse - Returns last response from Mobile ID service
     * @return     string
     */
    public function getLastResponse() {
        return($this->client->__getLastResponse());
    }

    /**
     * getLastSignature - Returns last signature response
     * @return     string
     */
    public function getLastSignature() {
        return($this->mid_signature);
    }

    /**
     * getLastMSSPtransID - Returns last MSSP Trans ID
     * @return     string
     */
    public function getLastMSSPtransID() {
        return($this->mid_MSSPtransID);
    }

    /**
     * __checkSignatureAndGetSigner - Checks the signature and extracts the signer certificate and it's serialnumber
     * #params     string    Base64 encoded signature
     * #params     string    verification of the message that should have been signed
     * #params     string    location of Certificate Authority file that should be used during verificaton
     * @return     boolean   
     */
    private function __checkSignatureAndGetSigner($signature, $message, $cafile) {
        assert('is_string($signature)');
        assert('is_string($message)');
        assert('is_string($cafile)');

        /* Check for provided file existence */
        if (!file_exists($cafile)) trigger_error('mobileid::__checkSignatureAndGetSigner: file not found ' . $cafile, E_USER_WARNING);

        /* Define temporary files */
        $tmpfile = tempnam(sys_get_temp_dir(), '_mid_');
        $file_sig       = $tmpfile . '.sig';
        $file_sig_cert  = $tmpfile . '.crt';
        $file_sig_msg   = $tmpfile . '.msg';

        /* Chunk spliting the signature */
        $signature = chunk_split($signature, 64, "\n");
        /* This because the openssl_pkcs7_verify() function needs some mime headers to make it work */
        $signature = "MIME-Version: 1.0\nContent-Disposition: attachment;
        filename=\"dummy.p7m\"\nContent-Type: application/x-pkcs7-mime;
        name=\"dummy.p7m\"\nContent-Transfer-Encoding: base64\n\n" . $signature;

        /* Write the signature into temp files */
        file_put_contents($file_sig, $signature);

        /* Signature checks must explicitly succeed */
        $ok = false;
        
        /* Get the signer certificate */
        $status = openssl_pkcs7_verify($file_sig, PKCS7_NOVERIFY, $file_sig_cert);
        if ($status==true && file_exists($file_sig_cert)) {
            /* Get the signer certificate and details */
            $this->mid_certificate = file_get_contents($file_sig_cert);
            $certificate = openssl_x509_parse($this->mid_certificate);
            $this->mid_serialnumber = $certificate['subject']['serialNumber'];

            /* Verify message has been signed */
            $data   = '';
            $status = openssl_pkcs7_verify($file_sig, PKCS7_NOVERIFY, $file_sig_cert, array($cafile), $file_sig_cert, $file_sig_msg);
            if (file_exists($file_sig_msg)) {
                $data = file_get_contents($file_sig_msg);
                if ($data === $message) $ok = true;
            } else trigger_error('mobileid::__checkSignatureAndGetSigner: signed message ' . openssl_error_string(), E_USER_NOTICE);

            /* Verify signer issued by trusted CA */
            $status = openssl_x509_checkpurpose($this->mid_certificate, X509_PURPOSE_SSL_CLIENT, array($cafile));
            if ($status != true) {
                $ok = false;
                trigger_error('mobileid::__checkSignatureAndGetSigner: certificate check ' . openssl_error_string(), E_USER_NOTICE);
            }
        }
        else trigger_error('mobileid::__checkSignatureAndGetSigner: signer certificate ' . openssl_error_string(), E_USER_NOTICE);
       
        /* Cleanup of temporary files */ 
        if (file_exists($tmpfile))        unlink($tmpfile);
        if (file_exists($file_sig))       unlink($file_sig);
        if (file_exists($file_sig_cert))  unlink($file_sig_cert);
        if (file_exists($file_sig_msg))   unlink($file_sig_msg);

        /* Signature checks failed? */
        if (!$ok) {
            $this->statuscode = '503';
            $this->statusmessage = 'INVALID_SIGNATURE';
        }
        
        return($ok);
    }

}

?>
