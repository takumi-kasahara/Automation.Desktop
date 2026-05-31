@echo off
setlocal

set "HKCU=HKCU\Software\Microsoft\Command Processor"
reg export "%HKCU%" "%TEMP%\Command Processor (HKCU).reg" /y
reg delete "%HKCU%" /v "AutoRun" /f

set "HKLM=HKLM\SOFTWARE\Microsoft\Command Processor"
reg export "%HKLM%" "%TEMP%\Command Processor (HKLM).reg" /y
reg delete "%HKLM%" /v "AutoRun" /f

exit /b %errorlevel%
