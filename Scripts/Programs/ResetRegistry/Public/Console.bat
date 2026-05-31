@echo off
setlocal

set "ROOT=HKCU\Console"
reg export "%ROOT%" "%TEMP%\Console.reg" /y
reg delete "%ROOT%" /f

exit /b %errorlevel%
