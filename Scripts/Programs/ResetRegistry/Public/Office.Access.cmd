@echo off
setlocal enableextensions disabledelayedexpansion

set "ROOT=HKCU\Software\Microsoft\Office\16.0\Access"
reg export "%ROOT%" "%TEMP%\Access.reg" /y
reg delete "%ROOT%\DocumentTemplateCache" /f

exit /B %errorlevel%
