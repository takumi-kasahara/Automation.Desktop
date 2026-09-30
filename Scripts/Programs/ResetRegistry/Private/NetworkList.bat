@echo off
setlocal

:begin
net session >nul 2>&1
if errorlevel 1 (
  where /q sudo >nul 2>&1
  if errorlevel 1 (
    echo ERROR: Access is denied.
    goto :end
  ) else (
    sudo --inline "%~0" %*
    exit /b %errorlevel%
  )
)

:process
:: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/netsh
netsh interface ip reset
set "ROOT=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList"
reg export "%ROOT%" "%TEMP%\NetworkList.reg" /y
reg delete "%ROOT%" /f
shutdown /g

:end
exit /b %errorlevel%
