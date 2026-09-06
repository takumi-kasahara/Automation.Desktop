@echo off
setlocal

:begin

:process
where /q choco >nul 2>&1 && choco upgrade all --accept-license --pre --yes
where /q winget >nul 2>&1 && winget upgrade --all --include-unknown --silent --accept-package-agreements --accept-source-agreements
where /q store >nul 2>&1 && store updates --apply
where /q pwsh >nul 2>&1 &&^
pwsh -NoLogo -NoProfile -Command "Get-ExperimentalFeature | Where-Object -Property Enabled -Not | Enable-ExperimentalFeature" &&^
pwsh -NoLogo -NoProfile -Command "Get-PackageSource | Set-PackageSource -Trusted" &&^
pwsh -NoLogo -NoProfile -Command "Get-PSRepository | ForEach-Object { Set-PSRepository -Name $_.Name -InstallationPolicy Trusted }" &&^
pwsh -NoLogo -NoProfile -Command "Update-Module -ErrorAction SilentlyContinue" &&^
pwsh -NoLogo -NoProfile -Command "Update-Help -ErrorAction SilentlyContinue"
where /q powershell >nul 2>&1 &&^
powershell -NoLogo -NoProfile -Command "Get-PackageSource | Set-PackageSource -Trusted" &&^
powershell -NoLogo -NoProfile -Command "Get-PSRepository | ForEach-Object { Set-PSRepository -Name $_.Name -InstallationPolicy Trusted }" &&^
powershell -NoLogo -NoProfile -Command "Update-Module -ErrorAction SilentlyContinue" &&^
powershell -NoLogo -NoProfile -Command "Update-Help -ErrorAction SilentlyContinue"
where /q apm >nul 2>&1 && apm update --global --yes
where /q dotnet >nul 2>&1 && dotnet tool update --global --all
where /q nuget >nul 2>&1 && nuget update -Self
where /q npx >nul 2>&1 && cmd /c npx npm-check-updates --global --upgrade
where /q npm >nul 2>&1 && cmd /c npm update --global --no-fund

:end
exit /b %errorlevel%
