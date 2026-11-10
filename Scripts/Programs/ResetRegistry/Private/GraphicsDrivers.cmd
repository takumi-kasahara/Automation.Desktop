@echo off
setlocal enableextensions disabledelayedexpansion

:begin
net session >nul 2>&1
if errorlevel 1 goto :elevate
goto :process

:elevate
where /Q sudo >nul 2>&1
if errorlevel 1 goto :no_sudo

sudo --disable-input "%~0"
goto :end

:no_sudo
echo ERROR: Access is denied.
goto :end

:process
set "ROOT=HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
call :export "%ROOT%\Configuration" "%TEMP%\GraphicsDrivers.Configuration.reg"
call :export "%ROOT%\Connectivity" "%TEMP%\GraphicsDrivers.Connectivity.reg"
call :export "%ROOT%\ScaleFactors" "%TEMP%\GraphicsDrivers.ScaleFactors.reg"
shutdown /g

:end
exit /B %errorlevel%

:export
  reg export "%~1" "%~2" /y
  reg delete "%~1" /f
exit /B
:: end export
