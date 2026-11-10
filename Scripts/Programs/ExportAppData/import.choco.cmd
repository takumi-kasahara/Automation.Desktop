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
choco install "%~1" --accept-license --pre --yes

:end
pause
exit /B %errorlevel%
