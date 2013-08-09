#!/bin/bash
# mobileid-receipt.sh - 1.2
#
# Generic script using curl to invoke Swisscom Mobile ID service.
# Dependencies: curl, openssl, base64, sed, iconv
#
# Change Log:
#  1.0 08.05.2013: Initial version
#  1.1 30.05.2013: Proper encoding for encryted receipts
#  1.2 03.05.2013: Conditional encoding for encrypted receipts based on content

######################################################################
# User configurable options
######################################################################

# AP_ID used to identify to Mobile ID (provided by Swisscom)
AP_ID=http://iam.swisscom.ch

######################################################################
# There should be no need to change anything below
######################################################################

# Error function
error()
{
  [ "$VERBOSE" = "1" ] && echo "$@" >&2         # Verbose details
  exit 1                                        # Exit
}

# Check command line
DEBUG=
VERBOSE=
while getopts "dv" opt; do			# Parse the options
  case $opt in
    d) DEBUG=1 ;;				# Debug
    v) VERBOSE=1 ;;				# Verbose
  esac
done
shift $((OPTIND-1))                             # Remove the options

if [ $# -lt 3 ]; then				# Parse the rest of the arguments
  echo "Usage: $0 <args> mobile transID \"message\" <pubCert>"
  echo "  -v       - verbose output"
  echo "  -d       - debug mode"
  echo "  mobile   - mobile number"
  echo "  transID  - transaction id of the related signature request"
  echo "  message  - message to be displayed"
  echo "  pubCert  - optional public certificate file of the mobile user to encode the message"
  echo
  echo "  Example $0 -v +41792080350 h29ah1 'All fine'"
  echo "          $0 -v +41792080350 h29ah1 'Password: 123456' /tmp/_tmp.8OVlwv.sig.cert"
  echo 
  exit 1
fi

PWD=$(dirname $0)				# Get the Path of the script

# Swisscom Mobile ID credentials
CERT_FILE=$PWD/mycert.crt			# The certificate that is allowed to access the service
CERT_KEY=$PWD/mycert.key			# The related key of the certificate
AP_PWD=disabled					# AP Password must be present but is not validated

# Swisscom SDCS elements
CERT_CA=$PWD/swisscom-ca.crt                    # Bag file with the server/client issuing and root certifiates

# Create temporary SOAP request
RANDOM=$$					# Seeds the random number generator from PID of script
AP_INSTANT=$(date +%Y-%m-%dT%H:%M:%S)		# Define instant and transaction id
AP_TRANSID=AP.TEST.$((RANDOM%89999+10000)).$((RANDOM%8999+1000))
MSSP_TRANSID=$2					# Transaction ID of request
SOAP_REQ=$(mktemp /tmp/_tmp.XXXXXX)		# SOAP Request goes here
SEND_TO=$1					# To who
TIMEOUT_REQ=5					# Timeout of the request itself
TIMEOUT_CON=10					# Timeout of the connection to the server
PUB_CERT=$4					# Public certificate for optional encryption

# Define the message and format
MSG_TYPE='MimeType="text/plain" Encoding="UTF-8"'
MSG_TXT=$3
if [ "$PUB_CERT" != "" ]; then			# Message to be encrypted
  [ -r "${PUB_CERT}" ] || error "Public certificate for encoding the message ($PUB_CERT) missing or not readable"
  MSG_TYPE='MimeType="application/alauda-rsamessage" Encoding="BASE64"'
  MSG_ASCI=$(echo -n $MSG_TXT | iconv -s -f UTF-8 -t US-ASCII//TRANSLIT)
  if [ "$MSG_TXT" == "$MSG_ASCI" ]; then		# Message does not contain special chars
    echo -n $MSG_TXT | openssl rsautl -encrypt -inkey $PUB_CERT -out $SOAP_REQ.msg -certin > /dev/null 2>&1
    [ -f "$SOAP_REQ.msg" ] && MSG_TXT=$(base64 $SOAP_REQ.msg)
   else							# -> GSM11.14 STK commands do not support UTF8, either UCS-2 or GSMDA
    # Encrypt UCS-2 prefixed with Hex 80 over cmd as vars are not properly encoding
    (echo -ne "\x80"; echo -n $MSG_TXT | iconv -s -f UTF-8 -t UCS-2BE) | openssl rsautl -encrypt -inkey $PUB_CERT -out $SOAP_REQ.msg -certin > /dev/null 2>&1
    [ -f "$SOAP_REQ.msg" ] && MSG_TXT=$(base64 $SOAP_REQ.msg)
  fi
fi

cat > $SOAP_REQ <<End
<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
    soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" 
    xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" 
    xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soapenv:Body>
    <MSS_Receipt>
      <mss:MSS_ReceiptReq MinorVersion="1" MajorVersion="1" MSSP_TransID="$MSSP_TRANSID" xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" TimeOut="$TIMEOUT_REQ" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#">
        <mss:AP_Info AP_PWD="$AP_PWD" AP_TransID="$AP_TRANSID" Instant="$AP_INSTANT" AP_ID="$AP_ID" />
        <mss:MSSP_Info>
          <mss:MSSP_ID>
            <mss:URI>http://mid.swisscom.ch/</mss:URI>
          </mss:MSSP_ID>
        </mss:MSSP_Info>
        <mss:MobileUser>
          <mss:MSISDN>$SEND_TO</mss:MSISDN>
        </mss:MobileUser>
        <mss:Message $MSG_TYPE>$MSG_TXT</mss:Message>
      </mss:MSS_ReceiptReq>
    </MSS_Receipt>
  </soapenv:Body>
</soapenv:Envelope>
End

# Check existence of needed files
[ -r "${CERT_CA}" ]   || error "CA certificate/chain file ($CERT_CA) missing or not readable"
[ -r "${CERT_KEY}" ]  || error "SSL key file ($CERT_KEY) missing or not readable"
[ -r "${CERT_FILE}" ] || error "SSL certificate file ($CERT_FILE) missing or not readable"

# Call the service
SOAP_URL=https://soap.mobileid.swisscom.com/soap/services/MSS_ReceiptPort
SOAP_ACTION=#MSS_Receipt
CURL_OPTIONS="--sslv3 --silent"
http_code=$(curl --write-out '%{http_code}\n' $CURL_OPTIONS \
    --data "@${SOAP_REQ}" --header "Content-Type: text/xml; charset=utf-8" --header "SOAPAction: \"$SOAP_ACTION\"" \
    --cert $CERT_FILE --cacert $CERT_CA --key $CERT_KEY \
    --output $SOAP_REQ.res --trace-ascii $SOAP_REQ.log \
    --connect-timeout $TIMEOUT_CON \
    $SOAP_URL)

# Results
export RC=$?

if [ "$RC" = "0" -a "$http_code" -ne 500 ]; then
  # Parse the response xml
  RES_RC=$(sed -n -e 's/.*<mss:StatusCode Value="\(.*\)"\/>.*/\1/p' $SOAP_REQ.res)
  RES_ST=$(sed -n -e 's/.*<mss:StatusMessage>\(.*\)<\/mss:StatusMessage>.*/\1/p' $SOAP_REQ.res)

  if [ "$VERBOSE" = "1" ]; then				# Verbose details
    echo "$SOAP_ACTION OK with following details and checks:"
    echo    " MSSP TransID   : $MSSP_TRANSID"
    echo    " Status code    : $RES_RC with exit $RC"
    echo    " Status details : $RES_ST"
  fi
 else
  CURL_ERR=$RC                                          # Keep related error
  export RC=2                                           # Force returned error code
  if [ "$VERBOSE" = "1" ]; then				# Verbose details
    [ $CURL_ERR != "0" ] && echo "curl failed with $CURL_ERR"   # Curl error
    if [ -s $SOAP_REQ.res ]; then                               # Response from the service
      RES_VALUE=$(sed -n -e 's/.*<soapenv:Value>\(.*\)<\/soapenv:Value>.*/\1/p' $SOAP_REQ.res)
      RES_DETAIL=$(sed -n -e 's/.*<ns1:detail.*>\(.*\)<\/ns1:detail>.*/\1/p' $SOAP_REQ.res)
      echo "$SOAP_ACTION FAILED with $RES_VALUE ($RES_DETAIL) and exit $RC"
    fi
  fi
fi

# Cleanups if not DEBUG mode
if [ "$DEBUG" = "" ]; then
  [ -f "$SOAP_REQ" ] && rm $SOAP_REQ
  [ -f "$SOAP_REQ.log" ] && rm $SOAP_REQ.log
  [ -f "$SOAP_REQ.res" ] && rm $SOAP_REQ.res
  [ -f "$SOAP_REQ.msg" ] && rm $SOAP_REQ.msg
 else
  [ -f "$SOAP_REQ" ] && echo "\n>>> $SOAP_REQ <<<" && cat $SOAP_REQ
  [ -f "$SOAP_REQ.log" ] && echo "\n>>> $SOAP_REQ.log <<<" && cat $SOAP_REQ.log | grep '==\|error'
  [ -f "$SOAP_REQ.res" ] && echo "\n>>> $SOAP_REQ.res <<<" && cat $SOAP_REQ.res
fi

exit $RC

#==========================================================
