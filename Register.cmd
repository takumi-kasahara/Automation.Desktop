@echo off
setlocal enableextensions disabledelayedexpansion
cd /D "%~dp0"

:begin
net session >nul 2>&1
if errorlevel 1 goto :elevate
goto :process

:elevate
where /Q sudo >nul 2>&1
if errorlevel 1 goto :powershell

sudo --disable-input "%~0"
goto :end

:powershell
set "PSModulePath="
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -Command'Start-Process "%~0" -Verb RunAs'
goto :end

:process
pwsh -NoLogo -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -File "Register.ScheduledTask.ps1"

:end
exit /B %errorlevel%
