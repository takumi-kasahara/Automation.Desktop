@echo off
setlocal enableextensions disabledelayedexpansion

:begin

:process
where /Q choco >nul 2>&1 && choco upgrade all --accept-license --pre --yes
where /Q winget >nul 2>&1 && winget upgrade --all --include-unknown --silent --accept-package-agreements --accept-source-agreements
where /Q store >nul 2>&1 && store updates --apply
set "PSModulePath="
where /Q powershell >nul 2>&1 && powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -File "%~dp0Update.ps1"
where /Q pwsh >nul 2>&1 && pwsh -NoLogo -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -File "%~dp0Update.ps1"
where /Q apm >nul 2>&1 && apm update --global --yes
where /Q dotnet >nul 2>&1 && dotnet tool update --global --all
where /Q gh >nul 2>&1 && gh extension upgrade --all
where /Q git >nul 2>&1 && git update-git-for-windows --yes
where /Q nuget >nul 2>&1 && nuget update -Self
where /Q npx >nul 2>&1 && cmd /D /E:ON /V:OFF /S /C call npx --yes npm-check-updates --global --upgrade
where /Q npm >nul 2>&1 && cmd /D /E:ON /V:OFF /S /C call npm update --global

:end
exit /B %errorlevel%
