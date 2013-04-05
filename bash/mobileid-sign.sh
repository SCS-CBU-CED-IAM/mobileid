#!/bin/sh
# mobileid-sign.sh - 1.5
#
# Generic script using wget to invoke Swisscom Mobile ID service.
# Dependencies: curl, openssl, base64, sed
#
# Change Log:
#  1.0 13.09.2012: Initial version with signature validation
#  1.1 27.09.2012: Revocation checks of the signers certificate
#                  Signed message verification
#                  Best practice response handling in the status details
#  1.2 10.10.2012: Cleanup and correction for TRANSID
#                  Optional parameters for language, debugging and verbose
#  1.3 17.10.2012: Timeout settings for process and request
#                  Mandatory language
#  1.4 21.2.2013:  Removal of the optional backend signature validation
#  1.5 5.4.2013:   Switching from wegt to curl
#                  Better error handling

######################################################################
# User configurable options
######################################################################

# AP_ID used to identify to Mobile ID (provided by Swisscom)
AP_ID=http://iam.swisscom.ch

######################################################################
# There should be no need to change anything below
######################################################################

error()
{
  echo "$@" >&2
  exit 1
}

# Check command line
DEBUG=
VERBOSE=
while getopts "dv" opt; do			# Parse the options
  case $opt in
    d) DEBUG=1 ;;				# Debug
    v) VERBOSE=1 ;;				# Verbose
  esac
  shift
done

if [ $# -lt 3 ]					# Parse the rest of the arguments
then
  echo "Usage: $0 <args> mobileNumber \"Message to be signed\" userlang"
  echo "  -v       - verbose output"
  echo "  -d       - debug mode"
  echo "  userlang - user language (one of en, de, fr, it)"
  echo
  echo "  Example $0 -v +41792080350 \"Do you want to login to corporate VPN?\" en"
  echo 
  exit 1
fi

PWD=$(dirname $0)				# Get the Path of the script

# Swisscom Mobile ID Credentials
CERT_FILE=$PWD/mycert.crt			# The certificate that is allowed to access the service
CERT_KEY=$PWD/mycert.key			# The related key of the certificate

AP_PWD=disabled					# AP Password must be present but is not validated
CERT_CA=$PWD/swisscom-ca.crt                    # Bag file with the server/client issuing and root certifiates
OCSP_CERT=$PWD/swisscom-ocsp.crt		# OCSP information of the signers certificate
OCSP_URL=http://ocsp.swissdigicert.ch/sdcs-rubin2

# Create temporary SOAP request
#  Synchron with timeout
#  Signature format in PKCS7
RANDOM=$$					# Seeds the random number generator from PID of script
AP_INSTANT=$(date +%Y-%m-%dT%H:%M:%S)		# Define instant and transaction id
AP_TRANSID=AP.TEST.$((RANDOM%89999+10000)).$((RANDOM%8999+1000))
SOAP_REQ=$(mktemp /tmp/_tmp.XXXXXX)		# SOAP Request goes here
SEND_TO=$1					# To who
SEND_MSG=$2					# What DataToBeSigned (DTBS)
USERLANG=$3					# User language
TIMEOUT_REQ=80					# Timeout of the request itself
TIMEOUT_CON=90					# Timeout of the connection to the server

cat > $SOAP_REQ <<End
<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
    soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" 
    xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" 
    xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soapenv:Body>
    <MSS_Signature xmlns="">
      <mss:MSS_SignatureReq MinorVersion="1" MajorVersion="1" xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" MessagingMode="synch" TimeOut="$TIMEOUT_REQ" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#">
        <mss:AP_Info AP_PWD="$AP_PWD" AP_TransID="$AP_TRANSID" Instant="$AP_INSTANT" AP_ID="$AP_ID" />
        <mss:MSSP_Info>
          <mss:MSSP_ID/>
        </mss:MSSP_Info>
        <mss:MobileUser>
          <mss:MSISDN>$SEND_TO</mss:MSISDN>
        </mss:MobileUser>
        <mss:DataToBeSigned MimeType="text/plain" Encoding="UTF-8">$SEND_MSG</mss:DataToBeSigned>
        <mss:SignatureProfile>
          <mss:mssURI>http://mid.swisscom.ch/MID/v1/AuthProfile1</mss:mssURI>
        </mss:SignatureProfile>
        <mss:AdditionalServices>
          <mss:Service>
            <mss:Description>
              <mss:mssURI>http://mss.ficom.fi/TS102204/v1.0.0#userLang</mss:mssURI>
            </mss:Description>
            <fi:UserLang>$USERLANG</fi:UserLang>
          </mss:Service>
        </mss:AdditionalServices>
        <mss:MSS_Format>
          <mss:mssURI>http://uri.etsi.org/TS102204/v1.1.2#PKCS7</mss:mssURI>
        </mss:MSS_Format>
      </mss:MSS_SignatureReq>
    </MSS_Signature>
  </soapenv:Body>
</soapenv:Envelope>
End

# Check existence of needed files
[ -r "${CERT_CA}" ]   || error "CA certificate/chain file ($CERT_CA) missing or not readable"
[ -r "${CERT_KEY}" ]  || error "SSL key file ($CERT_KEY) missing or not readable"
[ -r "${CERT_FILE}" ] || error "SSL certificate file ($CERT_FILE) missing or not readable"
[ -r "${OCSP_CERT}" ] || error "OCSP certificate file ($OCSP_CERT) missing or not readable"

# Call the service
SOAP_URL=https://soap.mobileid.swisscom.com/soap/services/MSS_SignaturePort
SOAP_ACTION=#MSS_Signature

http_code=$(curl --write-out '%{http_code}\n' --sslv3 --silent --data "@${SOAP_REQ}" --header "Content-Type: text/xml" --header "SOAPAction: \"$SOAP_ACTION\"" \
    --cert $CERT_FILE --cacert $CERT_CA --key $CERT_KEY \
    --output $SOAP_REQ.res --trace $SOAP_REQ.log \
    --connect-timeout $TIMEOUT_CON \
    $SOAP_URL

# Results
export RC=$?
if [ "$RC" = "0" -a "$http_code" -ne 500 ]; then
  # Parse the response xml
  RES_TRANSID=$(sed -n -e 's/.*AP_TransID="\(.*\)" AP_.*/\1/p' $SOAP_REQ.res)
  RES_MSISDNID=$(sed -n -e 's/.*<mss:MSISDN>\(.*\)<\/mss:MSISDN>.*/\1/p' $SOAP_REQ.res)
  RES_RC=$(sed -n -e 's/.*<mss:StatusCode Value="\(.*\)"\/>.*/\1/p' $SOAP_REQ.res)
  RES_ST=$(sed -n -e 's/.*<mss:StatusMessage>\(.*\)<\/mss:StatusMessage>.*/\1/p' $SOAP_REQ.res)
           sed -n -e 's/.*<mss:Base64Signature>\(.*\)<\/mss:Base64Signature>.*/\1/p' $SOAP_REQ.res > $SOAP_REQ.sig

  [ -s "${SOAP_REQ}.sig" ] || error "No Base64Signature found"
  # Decode the signature
  base64 --decode  $SOAP_REQ.sig > $SOAP_REQ.sig.decoded
  [ -s "${SOAP_REQ}.sig.decoded" ] || error "Unable to decode Base64Signature"

  # Extract the signers certificate
  openssl pkcs7 -inform der -in $SOAP_REQ.sig.decoded -out $SOAP_REQ.sig.cert -print_certs
  [ -s "${SOAP_REQ}.sig.cert" ] || error "Unable to extract signers certificate from siganture"
  RES_ID_CERT=$(openssl x509 -subject -noout -in $SOAP_REQ.sig.cert)

  # and verify the revocation status over ocsp
  openssl ocsp -CAfile $CERT_CA -issuer $OCSP_CERT -nonce -out $SOAP_REQ.sig.cert.check -url $OCSP_URL -cert $SOAP_REQ.sig.cert > /dev/null 2>&1
  if [ "$?" = "0" ]; then				# Revocation check completed
    RES_ID_CERT_STATUS=$(sed -n -e 's/.*.sig.cert: //p' $SOAP_REQ.sig.cert.check)
    if [ "$RES_ID_CERT_STATUS" = "revoked" ]; then		# Force Revoked certificate
      RES_ID=501
    fi
   else							# -> check not ok
    RES_ID_CERT_STATUS="failed, status $?"
  fi

  # Extract the PKCS7 and validate the signature
  openssl smime -verify -inform DER -in $SOAP_REQ.sig.decoded -out $SOAP_REQ.sig.txt -CAfile $CERT_CA -purpose sslclient > /dev/null 2>&1
  if [ "$?" = "0" ]; then				# Decoding without any error
    RES_MSG=$(cat $SOAP_REQ.sig.txt)                    	# Decoded message is in this file
    RES_MSG_STATUS="sucess"					# Details of verification
   else							# -> error in decoding
    RES_MSG=$(cat $SOAP_REQ.sig.txt)                      	# Decoded message is in this file
    RES_MSG_STATUS="failed, status $?"				# Details of verification
    RES_ID=503							# Force the Invalid signature status
  fi

  # Status codes
  if [ "$RES_ID" = "500" ]; then export RC=0 ; fi	# Signature constructed
  if [ "$RES_ID" = "501" ]; then export RC=1 ; fi	# Revoked certificate
  if [ "$RES_ID" = "502" ]; then export RC=0 ; fi	# Valid signature
  if [ "$RES_ID" = "503" ]; then export RC=1 ; fi	# Invalid signature

  if [ "$VERBOSE" = "1" ]; then				# Verbose details
    echo "OK with following details and checks:"
    echo -n " 1) Transaction ID : $RES_TRANSID"
      if [ "$RES_TRANSID" = "$AP_TRANSID" ] ; then echo " -> same as in request" ; else echo " -> different as in request!" ; fi
    echo -n " 2) Signed by      : $RES_MSISDNID"
      if [ "$RES_MSISDNID" = "$SEND_TO" ] ; then echo " -> same as in request" ; else echo " -> different as in request!" ; fi
    echo    " 3) Time to sign   : <Not verified>"
    echo    " 4) Signer         : $RES_ID_CERT -> OCSP check: $RES_ID_CERT_STATUS"
    echo -n " 5) Signed Data    : $RES_MSG -> Decode and verify: $RES_MSG_STATUS and "
      if [ "$RES_MSG" = "$SEND_MSG" ] ; then echo "same as in request" ; else echo "different as in request!" ; fi
    echo    " 6) Status code    : $RES_RC with exit $RC"
    echo    "    Status details : $RES_ST"
  fi
 else
  export RC=2						# Force error code higher than 1
  if [ "$VERBOSE" = "1" ]; then				# Verbose details
    RES_VALUE=$(sed -n -e 's/.*<soapenv:Value>\(.*\)<\/soapenv:Value>.*/\1/p' $SOAP_REQ.res)
    RES_DETAIL=$(sed -n -e 's/.*<ns1:detail.*>\(.*\)<\/ns1:detail>.*/\1/p' $SOAP_REQ.res)
    echo "FAILED with $RES_VALUE ($RES_DETAIL) and exit $RC"
  fi
fi

# Cleanups if not DEBUG mode
if [ "$DEBUG" = "" ]; then
  [ -f $SOAP_REQ ] && rm $SOAP_REQ
  [ -f $SOAP_REQ.log ] && rm $SOAP_REQ.log
  [ -f $SOAP_REQ.res ] && rm $SOAP_REQ.res
  [ -f $SOAP_REQ.sig ] && rm $SOAP_REQ.sig
  [ -f $SOAP_REQ.sig.decoded ] && rm $SOAP_REQ.sig.decoded
  [ -f $SOAP_REQ.sig.cert ] && rm $SOAP_REQ.sig.cert
  [ -f $SOAP_REQ.sig.cert.check ] && rm $SOAP_REQ.sig.cert.check
  [ -f $SOAP_REQ.sig.txt ] && rm $SOAP_REQ.sig.txt
fi

exit $RC

#==========================================================
