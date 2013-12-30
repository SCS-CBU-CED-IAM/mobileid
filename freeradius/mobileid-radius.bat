@echo off
REM Copyright (C) 2013 - Swisscom (Schweiz) AG

REM This program is free software: you can redistribute it and/or modify
REM it under the terms of the GNU General Public License as published by
REM the Free Software Foundation, either version 3 of the License, or
REM (at your option) any later version.
REM 
REM This program is distributed in the hope that it will be useful,
REM but WITHOUT ANY WARRANTY; without even the implied warranty of
REM MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
REM GNU General Public License for more details.
REM 
REM You should have received a copy of the GNU General Public License
REM along with this program. If not, see http://www.gnu.org/licenses/.
REM 
REM Exit codes (as defined by the freeRADIUS exec module):
REM < 0: fail      the module failed
REM = 0: OK        the module succeeded
REM = 1: reject    the module rejected the user
REM = 2: fail      the module failed
REM = 3: OK        the module succeeded
REM = 4: handled   the module has done everything to handle the request
REM = 5: invalid   the user's configuration entry was invalid
REM = 6: userlock  the user was locked out
REM = 7: notfound  the user was not found
REM = 8: noop      the module did nothing
REM = 9: updated   the module updated information in the request
REM > 9: fail      the module failed
REM --------------------------------------------------------------------
REM The following line must to point to the mobileid-cmd directory
set MID_DIRECTORY=c:\Programme\mobileid
REM anything else than empty enables debug output into the given file
set MID_DEBUG=
set MID_LOGFILE=%USERPROFILE%\midradius-out.txt
REM --------------------------------------------------------------------
set MID-Testskript=%MID_DIRECTORY%\mobileid_sharp.ps1
set MID_MSISDN=
set MID_TEXT=
set MID_LANG=
where /Q powershell
if errorlevel 1 (
  exit 10 &rem ERROR: powershell not installed
)
if not exist %MID-Testskript% exit 12 &rem ERROR: mobile ID not installed
if DEFINED MID_DEBUG echo Command Line: %* > %MID_LOGFILE%
set argc=0
for %%i in (%*) do set /A argc+=1
if argc GTR 4 (
  if DEFINED MID_DEBUG echo Param 0: %0 >> %MID_LOGFILE%
  if DEFINED MID_DEBUG echo Param 1: %1 >> %MID_LOGFILE%
  if DEFINED MID_DEBUG echo Param 2: %2 >> %MID_LOGFILE%
  if DEFINED MID_DEBUG echo Param 3: %3 >> %MID_LOGFILE%
)

set MID_MSISDN=%Called-Station-Id%
if NOT DEFINED MID_MSISDN set MID_MSISD=%CALLED_STATION_ID% &rem might be changed by shell_escape
if NOT DEFINED MID_MSISDN set MID_MSISDN=%1% &rem might be passed in command line
if NOT DEFINED MID_MSISDN exit 14 &rem ERROR: MSISDN not passed by freeRADIUS
if DEFINED MID_DEBUG echo Called-Station-Id:%MID_MSISDN% >> %MID_LOGFILE%

set MID_TEXT=%X-MSS-Message%
if NOT DEFINED MID_TEXT set MID_TEXT=%X_MSS_MESSAGE%
if NOT DEFINED MID_TEXT set MID_TEXT=%2
if NOT DEFINED MID_TEXT set MID_TEXT="Login through Mobile ID?"
if DEFINED MID_DEBUG echo X-MSS-Message:%MID_TEXT% >> %MID_LOGFILE%

set MID_LANG=%X-MSS-Language%
if NOT DEFINED MID_LANG set MID_LANG=%X_MSS_LANGUAGE%
if NOT DEFINED MID_LANG set MID_LANG=%3
if NOT DEFINED MID_LANG set MID_LANG=en
if DEFINED MID_DEBUG echo X-MSS-Language:%MID_LANG% >> %MID_LOGFILE%

SET MID_TEXT=%MID_TEXT:"='% &rem replace double quotes with single quotes
SET MID_CMDARGS=%MID_MSISDN% %MID_TEXT% %MID_LANG%
IF DEFINED MID_DEBUG set MID_CMDARGS=-Verbose %MID_CMDARGS% ^>^> %MID_LOGFILE%

IF DEFINED MID_DEBUG echo %MID-Testskript% %MID_CMDARGS% >> %MID_LOGFILE%
powershell %MID-Testskript% %MID_CMDARGS%
if errorlevel 1 (
  IF DEFINED MID_DEBUG echo %MID-Testskript% returned error %ERRORLEVEL% >> %MID_LOGFILE%
  exit %ERRORLEVEL%
)
IF DEFINED MID_DEBUG echo %MID-Testskript% returned success >> %MID_LOGFILE%
