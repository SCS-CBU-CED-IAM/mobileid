@ECHO OFF
set OLDDIR=%CD%
chdir /d %~d0%
chdir %~p0%
powershell .\mobileid_sharp.ps1 %1 %2 %3 %4 %5
chdir /d %OLDDIR% &rem restore current directory
