#!/bin/sh
# mobileid-tests.sh
#
# Generic test script against Swisscom Mobile ID service
# Dependencies: mobileid-sign.sh
#

# set current working path to the path of the script
cd "$(dirname "$0")"

# Fault codes with specific MSISDN’s
echo "> Fault codes with specific MSISDN’s"
./mobileid-sign.sh -v +41000092101 "WRONG_PARAM" en
./mobileid-sign.sh -v +41000092102 "MISSING_PARAM" en
./mobileid-sign.sh -v +41000092103 "WRONG_DATA_LENGTH" en
./mobileid-sign.sh -v +41000092104 "UNAUTHORIZED_ACCESS" en
./mobileid-sign.sh -v +41000092105 "UNKNOWN_CLIENT" en
./mobileid-sign.sh -v +41000092107 "INAPPROPRIATE_DATA" en
./mobileid-sign.sh -v +41000092108 "INCOMPATIBLE_INTERFACE" en
./mobileid-sign.sh -v +41000092109 "UNSUPPORTED_PROFILE" en
./mobileid-sign.sh -v +41000092208 "EXPIRED_TRANSACTION" en
./mobileid-sign.sh -v +41000092209 "OTA_ERROR" en
./mobileid-sign.sh -v +41000092401 "USER_CANCEL" en
./mobileid-sign.sh -v +41000092402 "PIN_NR_BLOCKED" en
./mobileid-sign.sh -v +41000092403 "CARD_BLOCKED" en
./mobileid-sign.sh -v +41000092404 "NO_KEY_FOUND" en
./mobileid-sign.sh -v +41000092406 "PB_SIGNATURE_PROCESS" en
./mobileid-sign.sh -v +41000092422 "NO_CERT_FOUND" en
./mobileid-sign.sh -v +41000092900 "INTERNAL_ERROR" en

# Unknown fault codes
echo "> Specific MSISDN's with inexistent fault code"
./mobileid-sign.sh -v +41000092700 "FAULT_CODE_DOES_NOT_EXIST" en
 
# Test of Heartbeat
echo ">  Specific MSISDN for Heratbeat"
./mobileid-sign.sh -v +41000000000 "HEARTBEAT" en
