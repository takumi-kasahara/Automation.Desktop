@echo off
cd /d "%~dp0"
setlocal

:begin
if "%~1"=="" (
  echo ERROR: No package specified.
  goto :end
)
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
choco install "%~1" --accept-license --pre --yes

:end
pause
exit /b %errorlevel%
