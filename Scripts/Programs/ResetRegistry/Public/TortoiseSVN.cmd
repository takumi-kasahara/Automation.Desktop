@echo off
setlocal enableextensions disabledelayedexpansion

set "ROOT=HKCU\Software\TortoiseSVN\TortoiseProc\ResizableState"
reg export "%ROOT%" "%TEMP%\TortoiseSVN.reg" /y
reg delete "%ROOT%" /f

exit /B %errorlevel%
