@echo off
chcp 1252>NUL
java -cp ".;./jar/*" com.swisscom.mid.client.MobileidSign -v -d -msisdn=41791234567 -message='Test: Do you want to login? (#TRANSID#)' -language=en
pause