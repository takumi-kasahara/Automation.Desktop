@echo off
setlocal

set "ROOT=HKCU\Software\Microsoft\Office\16.0\PowerPoint"
reg export "%ROOT%" "%TEMP%\PowerPoint.reg" /y
reg delete "%ROOT%\DocumentTemplateCache" /f

exit /b %errorlevel%
