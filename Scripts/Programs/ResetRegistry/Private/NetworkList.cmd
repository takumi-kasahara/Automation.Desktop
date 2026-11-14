@echo off
cd /d "%~dp0"
setlocal

:begin
net session >nul 2>&1
if errorlevel 1 goto :elevate
goto :process

:elevate
where /q sudo >nul 2>&1
if errorlevel 1 goto :no_sudo

sudo "%~0" %*
goto :end

:no_sudo
echo ERROR: Access is denied.
goto :end

:process
set "ROOT=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList"
reg export "%ROOT%" "%TEMP%\NetworkList.reg" /y
reg delete "%ROOT%" /f
shutdown /g

:end
exit /b %errorlevel%
