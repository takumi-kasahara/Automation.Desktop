@echo off
setlocal

set "ROOT=HKCU\Software\Microsoft\Office\16.0\OneNote"
reg export "%ROOT%" "%TEMP%\OneNote.reg" /y
reg delete "%ROOT%\General" /v "NavigationBarSize" /f
reg delete "%ROOT%\General" /v "PageTabSize" /f
reg delete "%ROOT%\Options" /v "FontMru" /f

exit /b %errorlevel%
