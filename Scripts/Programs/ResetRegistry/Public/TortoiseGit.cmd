@echo off
setlocal enableextensions disabledelayedexpansion

set "ROOT=HKCU\Software\TortoiseGit\TortoiseProc\ResizableState"
reg export "%ROOT%" "%TEMP%\TortoiseGit.reg" /y
reg delete "%ROOT%" /f

exit /B %errorlevel%
