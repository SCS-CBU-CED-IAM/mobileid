@echo off
chcp 1252>NUL
java -cp ".;./jar/*" com.swisscom.mid.client.MobileidSign -v -d -msisdn=41791234567 -message='Do you want to login?' -language=en
pause