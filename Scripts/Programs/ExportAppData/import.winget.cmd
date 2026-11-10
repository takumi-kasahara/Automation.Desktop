@echo off
setlocal enableextensions disabledelayedexpansion

:begin
if "%~1"=="" (
  echo ERROR: No package specified.
  goto :end
)
net session >nul 2>&1
if errorlevel 1 goto :elevate
goto :process

:elevate
where /Q sudo >nul 2>&1
if errorlevel 1 goto :no_sudo
sudo --disable-input "%~0" %*
goto :end

:no_sudo
echo ERROR: Access is denied.
goto :end

:process
winget import --import-file "%~1" --ignore-unavailable --ignore-versions --accept-package-agreements --accept-source-agreements

:end
pause
exit /B %errorlevel%
