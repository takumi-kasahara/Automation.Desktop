@echo off
setlocal enableextensions disabledelayedexpansion

set "ROOT=HKCU\Software\Microsoft\Office\16.0\Word"
reg export "%ROOT%" "%TEMP%\Word.reg" /y
reg delete "%ROOT%\DocumentTemplateCache" /f

exit /B %errorlevel%
