@echo off
setlocal enableextensions disabledelayedexpansion

:begin
net session >nul 2>&1
if errorlevel 1 goto :elevate
goto :process

:elevate
where /q sudo >nul 2>&1
if errorlevel 1 goto :no_sudo

sudo --disable-input "%~0"
goto :end

:no_sudo
echo ERROR: Access is denied.
goto :end

:process
:: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/netsh-advfirewall
:: netsh advfirewall show allprofiles
netsh advfirewall export "%TEMP%\firewall.wfw"
netsh advfirewall reset
netsh advfirewall set allprofiles state on
netsh advfirewall set allprofiles settings inboundusernotification disable
netsh advfirewall set allprofiles settings unicastresponsetomulticast disable

:end
exit /B %errorlevel%
