@echo off
setlocal enableextensions disabledelayedexpansion

set "ROOT=HKCU\Console"
reg export "%ROOT%" "%TEMP%\Console.reg" /y
reg delete "%ROOT%" /f

exit /B %errorlevel%
