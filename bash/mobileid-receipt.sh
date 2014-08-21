#!/bin/sh
# mobileid-receipt.sh
#
# Generic script using curl to invoke Swisscom Mobile ID service.
# Dependencies: curl, openssl, base64, sed, date, iconv, xmllint, xxd,
#               python
#

# set current working path to the path of the script
cd "$(dirname "$0")"

# Read configuration from property file
. ./mobileid.properties

# Error function
error()
{
  [ "$VERBOSE" = "1" -o "$DEBUG" = "1" ] && echo "$@" >&2
  exit 1
}

# Check command line
MSGTYPE=SOAP                                    # Default is SOAP
DEBUG=
VERBOSE=
while getopts "dvt:" opt; do                    # Parse the options
  case $opt in
    t) MSGTYPE=$OPTARG ;;                       # Message Type
    d) DEBUG=1 ;;                               # Debug
    v) VERBOSE=1 ;;                             # Verbose
  esac
done
shift $((OPTIND-1))                             # Remove the options

if [ $# -lt 4 ]; then                           # Parse the rest of the arguments
  echo "Usage: $0 <args> mobile transID 'message' userlang <pubCert>"
  echo "  -t value   - message type (SOAP, JSON); default SOAP"
  echo "  -v         - verbose output"
  echo "  -d         - debug mode"
  echo "  mobile     - mobile number"
  echo "  transID    - transaction id of the related signature request"
  echo "  message    - message to be displayed"
  echo "  userlang   - user language (one of en, de, fr, it)"
  echo "  pubCert    - optional public certificate file of the mobile user to encode the message"
  echo
  echo "  Example $0 -v +41792080350 h29ah1 'Successful login into VPN' en"
  echo "          $0 -t JSON -v +41792080350 h29ah1 'Successful login into VPN' en"
  echo "          $0 -v +41792080350 h29ah1 'Temporary password: 123456' en /tmp/_tmp.8OVlwv.sig.cert"
  echo 
  exit 1
fi

# Check the dependencies
for cmd in curl openssl base64 sed date iconv xmllint xxd python; do
  hash $cmd &> /dev/null
  if [ $? -eq 1 ]; then error "Dependency error: '$cmd' not found" ; fi
done

# Create temporary request
RANDOM=$$                                       # Seeds the random number generator from PID of script
AP_INSTANT=$(date +%Y-%m-%dT%H:%M:%S%:z)        # Define instant and transaction id
AP_TRANSID=AP.TEST.$((RANDOM%89999+10000)).$((RANDOM%8999+1000))
MSSP_TRANSID=$2                                 # Transaction ID of request
TMP=$(mktemp /tmp/_tmp.XXXXXX)                  # Request goes here
MSISDN=$1                                       # Destination phone number (MSISDN)
TIMEOUT_CON=10                                  # Timeout of the client connection
MSG_TXT=$3                                      # Message Content
USERLANG=$4                                     # User language
PUB_CERT=$5                                     # Public certificate for optional encryption

# Define the message and format
MIME_TYPE="text/plain"
ENCODING="UTF-8"
if [ "$PUB_CERT" != "" ]; then                  # Message to be encrypted
  [ -r "${PUB_CERT}" ] || error "Public certificate for encoding the message ($PUB_CERT) missing or not readable"
  MIME_TYPE="application/alauda-rsamessage"
  ENCODING="BASE64"
  MSG_ASCI=$(printf $MSG_TXT | iconv -s -f UTF-8 -t US-ASCII//TRANSLIT)
  if [ "$MSG_TXT" = "$MSG_ASCI" ]; then         # Message does not contain special chars
    printf "$MSG_TXT" | openssl rsautl -encrypt -inkey $PUB_CERT -out $TMP.msg -certin > /dev/null 2>&1
    [ -f "$TMP.msg" ] && MSG_TXT=$(base64 $TMP.msg)
  else                                          # -> GSM11.14 STK commands do not support UTF8, either UCS-2 or GSMDA
    # Encrypt UCS-2 prefixed with Hex 80 over cmd as vars are not properly encoding
    (echo 80 | xxd -r -p ; printf "$MSG_TXT" | iconv -s -f UTF-8 -t UCS-2BE) | openssl rsautl -encrypt -inkey $PUB_CERT -out $TMP.msg -certin > /dev/null 2>&1
    [ -f "$TMP.msg" ] && MSG_TXT=$(base64 $TMP.msg)
  fi
fi

case "$MSGTYPE" in
  # MessageType is SOAP. Define the Request
  SOAP)
    REQ_SOAP='<?xml version="1.0" encoding="UTF-8"?>
      <soapenv:Envelope
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
          xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
          soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" 
          xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" 
          xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soapenv:Body>
          <MSS_Receipt>
            <mss:MSS_ReceiptReq MajorVersion="1" MinorVersion="1" MSSP_TransID="'$MSSP_TRANSID'" xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:sco="http://www.swisscom.ch/TS102204/ext/v1.0.0">
              <mss:AP_Info AP_ID="'$AP_ID'" AP_PWD="'$AP_PWD'" AP_TransID="'$AP_TRANSID'" Instant="'$AP_INSTANT'"/>
              <mss:MSSP_Info>
                <mss:MSSP_ID>
                  <mss:URI>http://mid.swisscom.ch/</mss:URI>
                </mss:MSSP_ID>
              </mss:MSSP_Info>
              <mss:MobileUser>
                <mss:MSISDN>'$MSISDN'</mss:MSISDN>
              </mss:MobileUser>
              <mss:Status>
                <mss:StatusCode Value="100"/>
                <mss:StatusDetail>
                  <sco:ReceiptRequestExtension ReceiptMessagingMode="synch" UserAck="true">
                    <sco:ReceiptProfile Language="'$USERLANG'">
                      <sco:ReceiptProfileURI>http://mss.swisscom.ch/synch</sco:ReceiptProfileURI>
                    </sco:ReceiptProfile>
                  </sco:ReceiptRequestExtension>
                </mss:StatusDetail>
              </mss:Status>
              <mss:Message MimeType="'$MIME_TYPE'" Encoding="'$ENCODING'">'$MSG_TXT'</mss:Message>
            </mss:MSS_ReceiptReq>
          </MSS_Receipt>
        </soapenv:Body>
      </soapenv:Envelope>'
    # store into file
    echo "$REQ_SOAP" > $TMP.req ;;
    
  # MessageType is JSON. Define the Request
  JSON)
    REQ_JSON='{
      "MSS_ReceiptReq": {
        "MajorVersion": "1",
        "MinorVersion": "1",
        "AP_Info": {
          "AP_ID": "'$AP_ID'",
          "AP_PWD": "'$AP_PWD'",
          "Instant": "'$AP_INSTANT'",
          "AP_TransID": "'$AP_TRANSID'"
        },
        "MSSP_Info": {
          "MSSP_ID": {
            "URI": "http://mid.swisscom.ch/"
          }
        },
        "MSSP_TransID": "'$MSSP_TRANSID'",
        "MobileUser": {
          "MSISDN": "'$MSISDN'"
        },
        "Status": {
          "StatusCode": {
            "Value": "100"
          },
          "StatusDetail": {
            "ReceiptRequestExtension": {
              "ReceiptMessagingMode": "synch",
              "UserAck": "true",
              "ReceiptProfile": {
                "Language": "'$USERLANG'",
                "ReceiptProfileURI": "http://mss.swisscom.ch/synch"
              }
            }
          }
        },
        "Message": {
          "MimeType": "'$MIME_TYPE'",
          "Encoding": "'$ENCODING'",
          "Data": "'$MSG_TXT'"
        }
      }
    }'
    # store into file
    echo "$REQ_JSON" > $TMP.req ;;
    
  # Unknown message type
  *)
    error "Unsupported message type $MSGTYPE, check with $0" ;;
    
esac

# Check existence of needed files
[ -r "${CERT_CA_SSL}" ] || error "CA certificate/chain file ($CERT_CA_SSL) missing or not readable"
[ -r "${CERT_KEY}" ]    || error "SSL key file ($CERT_KEY) missing or not readable"
[ -r "${CERT_FILE}" ]   || error "SSL certificate file ($CERT_FILE) missing or not readable"

# Define cURL Options according to Message Type
case "$MSGTYPE" in
  SOAP)
    URL=$BASE_URL/soap/services/MSS_ReceiptPort
    HEADER_ACCEPT="Accept: application/xml"
    HEADER_CONTENT_TYPE="Content-Type: text/xml;charset=utf-8"
    TMP_REQ="--data @$TMP.req" ;;
  JSON)
    URL=$BASE_URL/rest/service
    HEADER_ACCEPT="Accept: application/json"
    HEADER_CONTENT_TYPE="Content-Type: application/json;charset=utf-8"
    TMP_REQ="--request POST --data-binary @$TMP.req" ;;
esac

# Call the service
http_code=$(curl --write-out '%{http_code}\n' $CURL_OPTIONS \
  $TMP_REQ \
  --header "${HEADER_ACCEPT}" --header "${HEADER_CONTENT_TYPE}" \
  --cert $CERT_FILE --cacert $CERT_CA_SSL --key $CERT_KEY \
  --output $TMP.rsp --trace-ascii $TMP.curl.log \
  --connect-timeout $TIMEOUT_CON \
  $URL)

# Results
RC=$?
if [ "$RC" = "0" -a "$http_code" -eq 200 ]; then
  case "$MSGTYPE" in
    SOAP)
      # Parse the response xml
      RES_RC=$(sed -n -e 's/.*<mss:StatusCode Value="\(...\)"\/>.*/\1/p' $TMP.rsp)
      RES_ST=$(sed -n -e 's/.*<mss:StatusMessage>\(.*\)<\/mss:StatusMessage>.*/\1/p' $TMP.rsp)
      RES_USR_ACK=$(sed -n -e 's/.*UserAck="\([^"]*\)\".*$/\1/p' $TMP.rsp)
      RES_USR_RSP=$(sed -n -e 's/.*UserResponse="{\(.*\)}.*/\1/p' $TMP.rsp | sed -e 's/\&quot\;/\"/g')
      ;;
    JSON)
      RES_RC=$(sed -n -e 's/^.*"Value":"\([^"]*\)".*$/\1/p' $TMP.rsp)
      RES_ST=$(sed -n -e 's/^.*"StatusMessage":"\([^"]*\)".*$/\1/p' $TMP.rsp)
      RES_USR_ACK=$(sed -n -e 's/^.*"UserAck":"\([^"]*\)".*$/\1/p' $TMP.rsp)
      RES_USR_RSP=$(sed -n -e 's/^.*"UserResponse":"{\(.*\)}".*$/\1/p' $TMP.rsp | sed 's/\\//g')
      ;;
  esac
  if [ "$VERBOSE" = "1" ]; then                         # Verbose details
    echo "OK with following details and checks:"
    echo    " MSSP TransID   : $MSSP_TRANSID"
    echo    " Status code    : $RES_RC with exit $RC"
    echo    " Status details : $RES_ST"
    if [ "$RES_USR_ACK" = "true" -a "$RES_USR_RSP" != "" ]; then
      echo    " User Response  : $RES_USR_RSP"          # User Response details
     else
      echo    " User Response  : n/a"                   # No User Response available
    fi
  fi
 else
  CURL_ERR=$RC                                          # Keep related error
  RC=2                                                  # Force returned error code
  if [ "$VERBOSE" = "1" ]; then                         # Verbose details
    [ $CURL_ERR != "0" ] && echo "curl failed with $CURL_ERR"   # Curl error
    if [ -s $TMP.rsp ]; then                            # Response from the service
      case "$MSGTYPE" in
        SOAP)
          RES_VALUE=$(sed -n -e 's/.*<soapenv:Value>mss:_\(.*\)<\/soapenv:Value>.*/\1/p' $TMP.rsp)
          RES_REASON=$(sed -n -e 's/.*<soapenv:Text.*>\(.*\)<\/soapenv:Text>.*/\1/p' $TMP.rsp)
          RES_DETAIL=$(sed -n -e 's/.*<ns1:detail.*>\(.*\)<\/ns1:detail>.*/\1/p' $TMP.rsp)
          ;;
        JSON)
          RES_VALUE=$(sed -n -e 's/^.*"Value":"_\([^"]*\)".*$/\1/p' $TMP.rsp)
          RES_REASON=$(sed -n -e 's/^.*"Text":"\([^"]*\)".*$/\1/p' $TMP.rsp)
          RES_DETAIL=$(sed -n -e 's/^.*"Detail":"\([^"]*\)".*$/\1/p' $TMP.rsp)
          ;;
      esac
      echo "FAILED on $MSISDN with error $RES_VALUE ($RES_REASON: $RES_DETAIL) and exit $RC"
    fi
  fi
fi

# Cleanups if not DEBUG mode
if [ "$DEBUG" = "" ]; then
  [ -f "$TMP" ] && rm $TMP
  [ -f "$TMP.req" ] && rm $TMP.req
  [ -f "$TMP.curl.log" ] && rm $TMP.curl.log
  [ -f "$TMP.rsp" ] && rm $TMP.rsp
  [ -f "$TMP.msg" ] && rm $TMP.msg
 else
  [ -f "$TMP.req" ] && echo ">>> $TMP.req <<<" && cat $TMP.req
  [ -f "$TMP.curl.log" ] && echo ">>> $TMP.curl.log <<<" && cat $TMP.curl.log | grep '==\|error'
  [ -f "$TMP.rsp" ] && echo ">>> $TMP.rsp <<<" && cat $TMP.rsp | ( [ "$MSGTYPE" != "JSON" ] && xmllint --format - || python -m json.tool ) 
fi

exit $RC

#==========================================================
