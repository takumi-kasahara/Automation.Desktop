@echo off
setlocal

:begin
net session >nul 2>&1
if errorlevel 1 (
  where /q sudo >nul 2>&1
  if errorlevel 1 (
    echo ERROR: Access is denied.
    goto :end
  ) else (
    sudo --inline "%~0" %*
    exit /b %errorlevel%
  )
)

:process
set "ROOT=HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
call :export "%ROOT%\Configuration" "%TEMP%\GraphicsDrivers.Configuration.reg"
call :export "%ROOT%\Connectivity" "%TEMP%\GraphicsDrivers.Connectivity.reg"
call :export "%ROOT%\ScaleFactors" "%TEMP%\GraphicsDrivers.ScaleFactors.reg"
shutdown /g

:end
exit /b %errorlevel%

:export
  reg export "%~1" "%~2" /y
  reg delete "%~1" /f
exit /b
:: end export
