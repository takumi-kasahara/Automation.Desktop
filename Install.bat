@echo off
cd /d "%~dp0"
setlocal

:begin

:process
pwsh -NoLogo -NoProfile -ExecutionPolicy RemoteSigned -File "Install.Modules.ps1"
pwsh -NoLogo -NoProfile -ExecutionPolicy RemoteSigned -File "Install.Scripts.ps1"

:end
exit /b %errorlevel%
