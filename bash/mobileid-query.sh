#!/bin/sh
# mobileid-query.sh - 1.1
#
# Generic script using curl to invoke Swisscom Mobile ID service to
# query details about MSISDN.
# Dependencies: curl, sed, date, xmllint
#
# Change Log:
#  1.0 14.11.2013: Initial version
#  1.1 19.11.2013: Remove of unnecessary exports

######################################################################
# User configurable options
######################################################################

# AP_ID used to identify to Mobile ID (provided by Swisscom)
AP_ID=mid://dev.swisscom.ch

######################################################################
# There should be no need to change anything below
######################################################################

# Error function
error()
{
  [ "$VERBOSE" = "1" -o "$DEBUG" = "1" ] && echo "$@" >&2
  exit 1
}

# Check command line
DEBUG=
VERBOSE=
while getopts "dv" opt; do                      # Parse the options
  case $opt in
    d) DEBUG=1 ;;                               # Debug
    v) VERBOSE=1 ;;                             # Verbose
  esac
done
shift $((OPTIND-1))                             # Remove the options

if [ $# -lt 1 ]; then                           # Parse the rest of the arguments
  echo "Usage: $0 <args> mobile"
  echo "  -v       - verbose output"
  echo "  -d       - debug mode"
  echo "  mobile   - mobile number"
  echo
  echo "  Example $0 -v +41792080350"
  echo
  exit 1
fi

PWD=$(dirname $0)                               # Get the Path of the script

# Check the dependencies
for cmd in curl sed date xmllint; do
  hash $cmd &> /dev/null
  if [ $? -eq 1 ]; then error "Dependency error: '$cmd' not found" ; fi
done

# Swisscom Mobile ID credentials
CERT_FILE=$PWD/mycert.crt                       # The certificate that is allowed to access the service
CERT_KEY=$PWD/mycert.key                        # The related key of the certificate
AP_PWD=disabled                                 # AP Password must be present but is not validated

# Swisscom SDCS elements
CERT_CA=$PWD/swisscom-ca.crt                    # Bag file with the server/client issuing and root certificates

# Create temporary SOAP request
RANDOM=$$                                       # Seeds the random number generator from PID of script
AP_INSTANT=$(date +%Y-%m-%dT%H:%M:%S%:z)        # Define instant and transaction id
AP_TRANSID=AP.TEST.$((RANDOM%89999+10000)).$((RANDOM%8999+1000))
SOAP_REQ=$(mktemp /tmp/_tmp.XXXXXX)             # SOAP Request goes here
SEND_TO=$1                                      # To who
TIMEOUT=80                                      # Value of Timeout
TIMEOUT_CON=90                                  # Timeout of the client connection

cat > $SOAP_REQ <<End
<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"
    xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope"
    xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soapenv:Body>
    <MSS_ProfileQuery>
      <mss:MSS_ProfileReq MajorVersion="1" MinorVersion="1" xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#">
        <mss:AP_Info AP_PWD="$AP_PWD" AP_TransID="$AP_TRANSID" Instant="$AP_INSTANT" AP_ID="$AP_ID" />
        <mss:MSSP_Info>
          <mss:MSSP_ID>
            <mss:URI>http://mid.swisscom.ch/</mss:URI>
          </mss:MSSP_ID>
        </mss:MSSP_Info>
        <mss:MobileUser>
          <mss:MSISDN>$SEND_TO</mss:MSISDN>
        </mss:MobileUser>
      </mss:MSS_ProfileReq>
    </MSS_ProfileQuery>
  </soapenv:Body>
</soapenv:Envelope>
End

# Check existence of needed files
[ -r "${CERT_CA}" ]   || error "CA certificate/chain file ($CERT_CA) missing or not readable"
[ -r "${CERT_KEY}" ]  || error "SSL key file ($CERT_KEY) missing or not readable"
[ -r "${CERT_FILE}" ] || error "SSL certificate file ($CERT_FILE) missing or not readable"

# Call the service
SOAP_URL=https://soap.mobileid.swisscom.com/soap/services/MSS_ProfilePort
SOAP_ACTION=#MSS_ProfileQuery
CURL_OPTIONS="--silent"
http_code=$(curl --write-out '%{http_code}\n' $CURL_OPTIONS \
    --data "@${SOAP_REQ}" --header "Content-Type: text/xml; charset=utf-8" --header "SOAPAction: \"$SOAP_ACTION\"" \
    --cert $CERT_FILE --cacert $CERT_CA --key $CERT_KEY \
    --output $SOAP_REQ.res --trace-ascii $SOAP_REQ.log \
    --connect-timeout $TIMEOUT_CON \
    $SOAP_URL)

# Results
RC=$?
if [ "$RC" = "0" -a "$http_code" -eq 200 ]; then
  # Parse the response xml
  RES_RC=$(sed -n -e 's/.*<mss:StatusCode Value="\(.*\)"\/>.*/\1/p' $SOAP_REQ.res)
  RES_ST=$(sed -n -e 's/.*<mss:StatusMessage>\(.*\)<\/mss:StatusMessage>.*/\1/p' $SOAP_REQ.res)

  # Status codes
  RC=1                                                  # By default not present
  if [ "$RES_RC" = "100" ]; then RC=0 ; fi              # ACTIVE or REGISTERED user

  if [ "$VERBOSE" = "1" ]; then                         # Verbose details
    echo "$SOAP_ACTION OK with following details and checks:"
    echo    " Status code    : $RES_RC with exit $RC"
    echo    " Status details : $RES_ST"
  fi
 else
  CURL_ERR=$RC                                          # Keep related error
  RC=2                                                  # Force returned error code
  if [ "$VERBOSE" = "1" ]; then                         # Verbose details
    [ $CURL_ERR != "0" ] && echo "curl failed with $CURL_ERR"   # Curl error
    if [ -s $SOAP_REQ.res ]; then                               # Response from the service
      RES_VALUE=$(sed -n -e 's/.*<soapenv:Value>\(.*\)<\/soapenv:Value>.*/\1/p' $SOAP_REQ.res)
      RES_REASON=$(sed -n -e 's/.*<soapenv:Text.*>\(.*\)<\/soapenv:Text>.*/\1/p' $SOAP_REQ.res)
      RES_DETAIL=$(sed -n -e 's/.*<ns1:detail.*>\(.*\)<\/ns1:detail>.*/\1/p' $SOAP_REQ.res)
      echo "$SOAP_ACTION FAILED on $SEND_TO with $RES_VALUE ($RES_REASON: $RES_DETAIL) and exit $RC"
    fi
  fi
fi

# Debug details
if [ "$DEBUG" != "" ]; then
  [ -f "$SOAP_REQ" ] && echo ">>> $SOAP_REQ <<<" && cat $SOAP_REQ | xmllint --format -
  [ -f "$SOAP_REQ.log" ] && echo ">>> $SOAP_REQ.log <<<" && cat $SOAP_REQ.log | grep '==\|error'
  [ -f "$SOAP_REQ.res" ] && echo ">>> $SOAP_REQ.res <<<" && cat $SOAP_REQ.res | xmllint --format -
fi

# Cleanups if not DEBUG mode
if [ "$DEBUG" = "" ]; then
  [ -f "$SOAP_REQ" ] && rm $SOAP_REQ
  [ -f "$SOAP_REQ.log" ] && rm $SOAP_REQ.log
  [ -f "$SOAP_REQ.res" ] && rm $SOAP_REQ.res
fi

exit $RC

#==========================================================
