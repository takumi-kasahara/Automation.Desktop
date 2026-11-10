@echo off
setlocal enableextensions disabledelayedexpansion

:begin

:process
where /Q choco >nul 2>&1 && choco upgrade all --accept-license --pre --yes
where /Q winget >nul 2>&1 && winget upgrade --all --include-unknown --silent --accept-package-agreements --accept-source-agreements
where /Q store >nul 2>&1 && store updates --apply
set "PSModulePath="
where /Q powershell >nul 2>&1 &&^
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -Command "Get-PackageSource | Set-PackageSource -Trusted" &&^
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -Command "Get-PSRepository | ForEach-Object { Set-PSRepository -Name $_.Name -InstallationPolicy Trusted }" &&^
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -Command "Update-Module -ErrorAction SilentlyContinue" &&^
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -Command "Update-Help -ErrorAction SilentlyContinue"
where /Q pwsh >nul 2>&1 &&^
pwsh -NoLogo -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -Command "Get-PackageSource | Set-PackageSource -Trusted" &&^
pwsh -NoLogo -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -Command "Get-PSRepository | ForEach-Object { Set-PSRepository -Name $_.Name -InstallationPolicy Trusted }" &&^
pwsh -NoLogo -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -Command "Update-Module -ErrorAction SilentlyContinue" &&^
pwsh -NoLogo -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -Command "Update-Help -ErrorAction SilentlyContinue"
where /Q apm >nul 2>&1 && apm update --global --yes
where /Q dotnet >nul 2>&1 && dotnet tool update --global --all
where /Q gh >nul 2>&1 && gh extension upgrade --all
where /Q git >nul 2>&1 && git update-git-for-windows --yes
where /Q nuget >nul 2>&1 && nuget update -Self
where /Q npx >nul 2>&1 && cmd /D /E:ON /V:OFF /S /C call npx --yes npm-check-updates --global --upgrade
where /Q npm >nul 2>&1 && cmd /D /E:ON /V:OFF /S /C call npm update --global

:end
exit /B %errorlevel%
