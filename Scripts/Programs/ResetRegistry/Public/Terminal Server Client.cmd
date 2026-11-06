@echo off
setlocal

set "ROOT=HKCU\Software\Microsoft\Terminal Server Client"
reg export "%ROOT%" "%TEMP%\Terminal Server Client.reg" /y
reg delete "%ROOT%" /v "LastBBarXPos" /f
reg delete "%ROOT%" /v "LastBBarWidth" /f
reg delete "%ROOT%\Default" /f
reg delete "%ROOT%\LocalDevices" /f
reg delete "%ROOT%\Servers" /f

exit /b %errorlevel%
