@echo off
cd /d "%~dp0"
setlocal

:begin
net session >nul 2>&1
if errorlevel 1 goto :elevate
goto :process

:elevate
where /q sudo >nul 2>&1
if errorlevel 1 goto :powershell

sudo --inline "%~0"
goto :end

:powershell
set "PSModulePath="
powershell -NoLogo -NoProfile -Command "Start-Process '%~0' -Verb RunAs"
goto :end

:process
pwsh -NoLogo -NoProfile -ExecutionPolicy RemoteSigned -File "Register.ScheduledTask.ps1"

:end
exit /b %errorlevel%
