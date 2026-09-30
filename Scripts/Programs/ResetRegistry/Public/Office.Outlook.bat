@echo off
setlocal

set "OUTLOOK=HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Outlook"
reg export "%OUTLOOK%" "%TEMP%\Outlook.reg" /y
reg delete "%OUTLOOK%\Office Finder" /f

exit /b %errorlevel%
