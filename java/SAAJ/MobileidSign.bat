@echo off
chcp 1252>NUL
java -cp ".;./jar/*" com.swisscom.mid.client.MobileidSign -d -config=mobileid.properties -msisdn=41792080350 -message='Sign?' -language=en
pause