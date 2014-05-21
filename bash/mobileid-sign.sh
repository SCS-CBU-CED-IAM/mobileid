#!/bin/sh
# mobileid-sign.sh - 2.6
#
# Generic script using curl to invoke Swisscom Mobile ID service.
# Dependencies: curl, openssl, base64, sed, date, xmllint
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
#  1.4 21.02.2013: Removal of the optional backend signature validation
#  1.5 05.04.2013: Switching from wget to curl
#                  Better error handling
#  1.6 08.05.2013: Options for sending normal/encrypted receipt
#  1.7 03.06.2013: Updated usage details
#  1.8 07.06.2013: Time to sign implementation
#  1.9 12.08.2013: Instant with timezone
#  2.0 18.10.2013: Format the xml results in debug mode
#                  Dependency checker
#  2.1 13.11.2013: Switched from xmlindent to xmllint
#  2.2 19.11.2013: Remove of unnecessary exports
#  2.3 20.11.2013: Improved signature response status code checks
#  2.4 25.11.2013: Removal of time to sign implementation
#  2.5 12.12.2013: Get the OCSP uri out of the signers certificate
#  2.6 21.02.2014: Dynamic issuer for OCSP verification
#                  Additional CRL verification

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
ENCRYPT=
while getopts "dve" opt; do                     # Parse the options
  case $opt in
    d) DEBUG=1 ;;                               # Debug
    v) VERBOSE=1 ;;                             # Verbose
    e) ENCRYPT=1 ;;                             # Encrypt receipt
  esac
done
shift $((OPTIND-1))                             # Remove the options

if [ $# -lt 3 ]; then                           # Parse the rest of the arguments
  echo "Usage: $0 <args> mobile 'message' userlang <receipt>"
  echo "  -v       - verbose output"
  echo "  -d       - debug mode"
  echo "  -e       - encrypted receipt"
  echo "  mobile   - mobile number"
  echo "  message  - message to be signed"
  echo "  userlang - user language (one of en, de, fr, it)"
  echo "  receipt  - optional success receipt message"
  echo
  echo "  Example $0 -v +41792080350 'Do you want to login to corporate VPN?' en"
  echo "          $0 -v +41792080350 'Do you want to login to corporate VPN?' en 'Successful login into VPN'"
  echo "          $0 -v -e +41792080350 'Do you need a new password?' en 'Temporary password: 123456'"
  echo 
  exit 1
fi

PWD=$(dirname $0)                               # Get the Path of the script

# Check the dependencies
for cmd in curl openssl base64 sed date xmllint awk; do
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
#  Synchron with timeout
#  Signature format in PKCS7
RANDOM=$$                                       # Seeds the random number generator from PID of script
AP_INSTANT=$(date +%Y-%m-%dT%H:%M:%S%:z)        # Define instant and transaction id
AP_TRANSID=AP.TEST.$((RANDOM%89999+10000)).$((RANDOM%8999+1000))
TMP=$(mktemp /tmp/_tmp.XXXXXX)                  # Request goes here
SEND_TO=$1                                      # To who
SEND_MSG=$2                                     # What DataToBeSigned (DTBS)
USERLANG=$3                                     # User language
RECEIPT_MSG=$4                                  # Optional Receipt Message
TIMEOUT=80                                      # Value of Timeout
TIMEOUT_CON=90                                  # Timeout of the client connection

cat > $TMP.req <<End
<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
    soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" 
    xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" 
    xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soapenv:Body>
    <MSS_Signature>
      <mss:MSS_SignatureReq MajorVersion="1" MinorVersion="1" MessagingMode="synch" TimeOut="$TIMEOUT" xmlns:mss="http://uri.etsi.org/TS102204/v1.1.2#" xmlns:fi="http://mss.ficom.fi/TS102204/v1.0.0#">
        <mss:AP_Info AP_ID="$AP_ID" AP_PWD="$AP_PWD" AP_TransID="$AP_TRANSID" Instant="$AP_INSTANT"/>
        <mss:MSSP_Info>
          <mss:MSSP_ID>
            <mss:URI>http://mid.swisscom.ch/</mss:URI>
          </mss:MSSP_ID>
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
[ -r "$CERT_CA" ]   || error "CA certificate/chain file ($CERT_CA) missing or not readable"
[ -r "$CERT_KEY" ]  || error "SSL key file ($CERT_KEY) missing or not readable"
[ -r "$CERT_FILE" ] || error "SSL certificate file ($CERT_FILE) missing or not readable"

# Call the service
SOAP_URL=https://soap.mobileid.swisscom.com/soap/services/MSS_SignaturePort
CURL_OPTIONS="--silent"
http_code=$(curl --write-out '%{http_code}\n' $CURL_OPTIONS --data @$TMP.req \
    --header "Content-Type: text/xml; charset=utf-8" \
    --cert $CERT_FILE --cacert $CERT_CA --key $CERT_KEY \
    --output $TMP.rsp --trace-ascii $TMP.curl.log \
    --connect-timeout $TIMEOUT_CON \
    $SOAP_URL)

# Results
RC=$?
if [ "$RC" = "0" -a "$http_code" -eq 200 ]; then
  # Parse the response xml
  RES_TRANSID=$(sed -n -e 's/.*AP_TransID="\(.*\)" AP_.*/\1/p' $TMP.rsp)
  RES_MSISDNID=$(sed -n -e 's/.*<mss:MSISDN>\(.*\)<\/mss:MSISDN>.*/\1/p' $TMP.rsp)
  RES_RC=$(sed -n -e 's/.*<mss:StatusCode Value="\(.*\)"\/>.*/\1/p' $TMP.rsp)
  RES_ST=$(sed -n -e 's/.*<mss:StatusMessage>\(.*\)<\/mss:StatusMessage>.*/\1/p' $TMP.rsp)
           sed -n -e 's/.*<mss:Base64Signature>\(.*\)<\/mss:Base64Signature>.*/\1/p' $TMP.rsp > $TMP.sig.base64
  RES_MSSPID=$(sed -n -e 's/.*MSSP_TransID="\(.*\)" xmlns:mss.*/\1/p' $TMP.rsp)

  [ -s "$TMP.sig.base64" ] || error "No Base64Signature found"
  # Decode the signature
  base64 --decode  $TMP.sig.base64 > $TMP.sig.der
  [ -s "$TMP.sig.der" ] || error "Unable to decode Base64Signature"

  # Extract the signers certificate
  openssl pkcs7 -inform der -in $TMP.sig.der -out $TMP.sig.cert.pem -print_certs
  [ -s "$TMP.sig.cert.pem" ] || error "Unable to extract signers certificate from signature"
  # Add the CA file as chain until provided by the response
  cat $CERT_CA >> $TMP.sig.cert.pem

  # Split the certificate list into separate files
  awk -v tmp=$TMP.sig.certs.level -v c=-1 '/-----BEGIN CERTIFICATE-----/{inc=1;c++} inc {print > (tmp c ".pem")}/---END CERTIFICATE-----/{inc=0}' $TMP.sig.cert.pem
  # Signers certificate is in level0
  [ -s "$TMP.sig.certs.level0.pem" ] || error "Unable to extract signers certificate from the list"
  RES_CERT_SUBJ=$(openssl x509 -subject -nameopt utf8 -nameopt sep_comma_plus -noout -in $TMP.sig.certs.level0.pem)
  RES_CERT_ISSUER=$(openssl x509 -issuer -nameopt utf8 -nameopt sep_comma_plus -noout -in $TMP.sig.certs.level0.pem)
  RES_CERT_START=$(openssl x509 -startdate -noout -in $TMP.sig.certs.level0.pem)
  RES_CERT_END=$(openssl x509 -enddate -noout -in $TMP.sig.certs.level0.pem)

  # Get CRL uri from the signers certificate
  CRL_URL=$(openssl x509 -in $TMP.sig.certs.level0.pem -text -noout | grep crl)
  CRL_URL=$(echo "$CRL_URL" | sed -e 's/URI://')

  # Get OCSP uri from the signers certificate
  OCSP_URL=$(openssl x509 -in $TMP.sig.certs.level0.pem -ocsp_uri -noout)

  # Find the proper issuer certificate in the list
  ISSUER=
  for i in $TMP.sig.certs.level?.pem; do
    if [ -s "$i" ]; then
      RES_TMP=$(openssl x509 -subject -nameopt utf8 -nameopt sep_comma_plus -noout -in $i)
      RES_TMP=$(echo "$RES_TMP" | sed -e 's/subject= /issuer= /')
      if [ "$RES_TMP" = "$RES_CERT_ISSUER" ]; then ISSUER=$i; fi
    fi
  done

  # Verify the certificate and revocation status over CRL
  RES_CERT_STATUS_CRL="Not yet implemented"
  if [ -n "$CRL_URL" ]; then
    # Get the CRL and convert from der to pem
    curl $CURL_OPTIONS --connect-timeout $TIMEOUT_CON $CRL_URL | openssl crl -inform DER  -out $TMP.crl.pem > /dev/null 2>&1
    # Add the chain to the CRL
    for i in $TMP.sig.certs.level?.pem; do
      if [ -s "$i" ]; then
        cat $i >> $TMP.crl.pem
      fi
    done
    # Verify the revocation status over CRL
    openssl verify -CAfile $TMP.crl.pem -crl_check $TMP.sig.certs.level0.pem > $TMP.sig.cert.checkcrl
    CRL_ERR=$?                                          # Keep related errorlevel
    if [ "$CRL_ERR" = "0" ]; then                       # Revocation check completed
      # if the certificate is revoked it will be in the .checkcrl as:
      #  /tmp/_tmp.DLIV9M.sig.certs.level0.pem: serialNumber = MIDCHEP1YYDBMA59, CN = MIDCHEP1YYDBMA59:PN, C = CH
      #  error 23 at 0 depth lookup:certificate revoked
      # we need get the line, remove all spaces and compare with the subject itself
      RES_CERT_STATUS_CRL=$(sed -n -e 's/.*.sig.certs.level0.pem: //p' $TMP.sig.cert.checkcrl)
      RES_CERT_STATUS_CRL=$(echo "$RES_CERT_STATUS_CRL" | sed -e 's/ //g')
      if [ "subject= $RES_CERT_STATUS_CRL" = "$RES_CERT_SUBJ" ]; then
        RES_CERT_STATUS_CRL="revoked"
      fi
     else                                               # -> check not ok
      RES_CERT_STATUS_CRL"error, status $CRL_ERR"           # Details for verification
    fi
   else
    RES_CERT_STATUS_CRL="No CRL information found in the signers certificate"
  fi
  if [ "$RES_CERT_STATUS_CRL" = "revoked" ]; then       # Force Revoked certificate
    RES_ID=501
  fi

  # Verify the revocation status over OCSP
  # -no_cert_verify: don't verify the OCSP response signers certificate at all
  if [ -n "$OCSP_URL" -a -n "$ISSUER" ]; then
    openssl ocsp -CAfile $CERT_CA -issuer $ISSUER -nonce -out $TMP.sig.cert.checkocsp -url $OCSP_URL -cert $TMP.sig.certs.level0.pem -no_cert_verify > /dev/null 2>&1
    OCSP_ERR=$?                                         # Keep related errorlevel
    if [ "$OCSP_ERR" = "0" ]; then                      # Revocation check completed
      RES_CERT_STATUS_OCSP=$(sed -n -e 's/.*.sig.certs.level0.pem: //p' $TMP.sig.cert.checkocsp)
     else                                               # -> check not ok
      RES_CERT_STATUS_OCSP="error, status $OCSP_ERR"        # Details for verification
    fi
   else
    RES_CERT_STATUS_OCSP="No OCSP information found in the signers certificate"
  fi
  if [ "$RES_CERT_STATUS_OCSP" = "revoked" ]; then      # Force Revoked certificate
    RES_ID=501
  fi

  # Extract the PKCS7 and validate the signature
  openssl cms -verify -inform der -in $TMP.sig.der -out $TMP.sig.txt -CAfile $CERT_CA -purpose sslclient > /dev/null 2>&1
  if [ "$?" = "0" ]; then                               # Decoding without any error
    RES_MSG=$(cat $TMP.sig.txt)                            # Decoded message is in this file
    RES_MSG_STATUS="success"                                    # Details of verification
   else                                                 # -> error in decoding
    RES_MSG=$(cat $TMP.sig.txt)                            # Decoded message is in this file
    RES_MSG_STATUS="failed, status $?"                          # Details of verification
    RES_ID=503                                                  # Force the Invalid signature status
  fi

  # Status codes
  case "$RES_ID" in
    "500" ) RC=0 ;;                                     # Signature constructed
    "501" ) RC=1 ;;                                     # Revoked certificate
    "502" ) RC=0 ;;                                     # Valid signature
    "503" ) RC=1 ;;                                     # Invalid signature
  esac 

  if [ "$VERBOSE" = "1" ]; then                         # Verbose details
    echo "OK with following details and checks:"
    echo -n " 1) Transaction ID : $RES_TRANSID"
      if [ "$RES_TRANSID" = "$AP_TRANSID" ] ; then echo " -> same as in request" ; else echo " -> different as in request!" ; fi
    echo    "    MSSP TransID   : $RES_MSSPID"
    echo -n " 2) Signed by      : $RES_MSISDNID"
      if [ "$RES_MSISDNID" = "$SEND_TO" ] ; then echo " -> same as in request" ; else echo " -> different as in request!" ; fi
    echo    " 3) Signer         : $RES_CERT_SUBJ"
    echo    "                     $RES_CERT_ISSUER"
    echo    "                     validity= $RES_CERT_START $RES_CERT_END"
    echo    "                     CRL check= $RES_CERT_STATUS_CRL"
    echo    "                     OCSP check= $RES_CERT_STATUS_OCSP"
    echo -n " 4) Signed Data    : $RES_MSG -> Decode and verify: $RES_MSG_STATUS and "
      if [ "$RES_MSG" = "$SEND_MSG" ] ; then echo "same as in request" ; else echo "different as in request!" ; fi
    echo    " 5) Status code    : $RES_RC with exit $RC"
    echo    "    Status details : $RES_ST"
  fi
 else
  CURL_ERR=$RC                                          # Keep related error
  RC=2                                                  # Force returned error code
  if [ "$VERBOSE" = "1" ]; then                         # Verbose details
    [ $CURL_ERR != "0" ] && echo "curl failed with $CURL_ERR"   # Curl error
    if [ -s "$TMP.rsp" ]; then                              # Response from the service
      RES_VALUE=$(sed -n -e 's/.*<soapenv:Value>\(.*\)<\/soapenv:Value>.*/\1/p' $TMP.rsp)
      RES_REASON=$(sed -n -e 's/.*<soapenv:Text.*>\(.*\)<\/soapenv:Text>.*/\1/p' $TMP.rsp)
      RES_DETAIL=$(sed -n -e 's/.*<ns1:detail.*>\(.*\)<\/ns1:detail>.*/\1/p' $TMP.rsp)
      echo "FAILED on $SEND_TO with $RES_VALUE ($RES_REASON: $RES_DETAIL) and exit $RC"
    fi
  fi
fi

# Debug details
if [ "$DEBUG" != "" ]; then
  [ -f "$TMP.req" ] && echo ">>> $TMP.req <<<" && cat $TMP.req | xmllint --format -
  [ -f "$TMP.curl.log" ] && echo ">>> $TMP.curl.log <<<" && cat $TMP.curl.log | grep '==\|error'
  [ -f "$TMP.rsp" ] && echo ">>> $TMP.rsp <<<" && cat $TMP.rsp | xmllint --format -
fi

# Need a receipt?
if [ "$RC" -lt "2" -a "$RECEIPT_MSG" != "" ]; then      # Request ok and need to send a reciept
  OPTS=
  if [ "$VERBOSE" = "1" ]; then OPTS="$OPTS -v" ; fi    # Keep the options
  if [ "$DEBUG"   = "1" ]; then OPTS="$OPTS -d" ; fi
  if [ "$ENCRYPT" = "1" ]; then                         # Encrypted Receipt
    $PWD/mobileid-receipt.sh $OPTS $SEND_TO $RES_MSSPID "$RECEIPT_MSG" "$USERLANG" $TMP.sig.certs.level0.pem
   else                                                 # Plain Receipt
    $PWD/mobileid-receipt.sh $OPTS $SEND_TO $RES_MSSPID "$RECEIPT_MSG" "$USERLANG"
  fi
fi

# Cleanups if not DEBUG mode
if [ "$DEBUG" = "" ]; then
  [ -f "$TMP" ] && rm $TMP
  [ -f "$TMP.req" ] && rm $TMP.req
  [ -f "$TMP.curl.log" ] && rm $TMP.curl.log
  [ -f "$TMP.rsp" ] && rm $TMP.rsp
  [ -f "$TMP.sig.base64" ] && rm $TMP.sig.base64
  [ -f "$TMP.sig.der" ] && rm $TMP.sig.der
  [ -f "$TMP.sig.cert.pem" ] && rm $TMP.sig.cert.pem
  for i in $TMP.sig.certs.level?.pem; do [ -f "$i" ] && rm $i; done
  [ -f "$TMP.crl.pem" ] && rm $TMP.crl.pem
  [ -f "$TMP.sig.cert.checkcrl" ] && rm $TMP.sig.cert.checkcrl
  [ -f "$TMP.sig.cert.checkocsp" ] && rm $TMP.sig.cert.checkocsp
  [ -f "$TMP.sig.txt" ] && rm $TMP.sig.txt
fi

exit $RC

#==========================================================