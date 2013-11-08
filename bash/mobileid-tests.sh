#!/bin/bash
# mobileid-tests.sh - 1.8
#
# Generic test script against Swisscom Mobile ID service
# Dependencies: mobileid-sign.sh
#
# Change Log:
#  1.0 27.09.2013: Initial version
#  1.1 16.10.2013: Updated version

# Fault codes with specific MSISDN’s
echo "> Fault codes with specific MSISDN’s"
$PWD/mobileid-sign.sh -v +41000092101 "WRONG_PARAM" en
$PWD/mobileid-sign.sh -v +41000092102 "MISSING_PARAM" en
$PWD/mobileid-sign.sh -v +41000092103 "WRONG_DATA_LENGTH" en
$PWD/mobileid-sign.sh -v +41000092104 "UNAUTHORIZED_ACCESS" en
$PWD/mobileid-sign.sh -v +41000092105 "UNKNOWN_CLIENT" en
$PWD/mobileid-sign.sh -v +41000092107 "INAPPROPRIATE_DATA" en
$PWD/mobileid-sign.sh -v +41000092108 "INCOMPATIBLE_INTERFACE" en
$PWD/mobileid-sign.sh -v +41000092109 "UNSUPPORTED_PROFILE" en
$PWD/mobileid-sign.sh -v +41000092208 "EXPIRED_TRANSACTION" en
$PWD/mobileid-sign.sh -v +41000092209 "OTA_ERROR" en
$PWD/mobileid-sign.sh -v +41000092401 "USER_CANCEL" en
$PWD/mobileid-sign.sh -v +41000092402 "PIN_NR_BLOCKED" en
$PWD/mobileid-sign.sh -v +41000092403 "CARD_BLOCKED" en
$PWD/mobileid-sign.sh -v +41000092404 "NO_KEY_FOUND" en
$PWD/mobileid-sign.sh -v +41000092406 "PB_SIGNATURE_PROCESS" en
$PWD/mobileid-sign.sh -v +41000092422 "NO_CERT_FOUND" en
$PWD/mobileid-sign.sh -v +41000092900 "INTERNAL_ERROR" en

# Unknown fault codes
echo "> Specific MSISDN's with inexistent fault code"
$PWD/mobileid-sign.sh -v +41000092700 "FAULT_CODE_DOES_NOT_EXIST" en
 
# Test of Heartbeat
echo ">  Specific MSISDN for Heratbeat"
$PWD/mobileid-sign.sh -v +41000000000 "HEARTBEAT" en
