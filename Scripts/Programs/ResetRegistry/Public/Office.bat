@echo off
setlocal

set "ROOT=HKCU\Software\Microsoft\Office\16.0\OneNote\General"
reg export "%ROOT%" "%TEMP%\OneNote.reg" /y
reg delete "%ROOT%" /v "NavigationBarSize" /f
reg delete "%ROOT%" /v "PageTabSize" /f

exit /b %errorlevel%
