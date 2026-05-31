@echo off
setlocal

:begin

:process
:: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/netsh
netsh interface ip reset
set "ROOT=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList"
reg export "%ROOT%" "%TEMP%\NetworkList.reg" /y
reg delete "%ROOT%" /f
shutdown /g

:end
exit /b %errorlevel%
