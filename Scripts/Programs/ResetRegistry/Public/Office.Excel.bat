@echo off
setlocal

set "ROOT=HKCU\Software\Microsoft\Office\16.0\Excel"
reg export "%ROOT%" "%TEMP%\Excel.reg" /y
reg delete "%ROOT%\DocumentTemplateCache" /f
reg delete "%ROOT%\Options" /v "MRUFuncs" /f
reg delete "%ROOT%\Options" /v "Pos" /f

exit /b %errorlevel%
