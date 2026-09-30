@echo off
setlocal

:begin

:process
if exist "%~dp0\Main.bat" (
  cmd /c "%~dp0\Main.bat" %*
) else if exist "%~dp0\Main.ps1" (
  pwsh -NoLogo -NoProfile -ExecutionPolicy RemoteSigned -File "%~dp0\Main.ps1" %*
) else if exist "%~dp0\Main.RunAs.bat" (
  sudo --inline cmd /c "%~dp0\Main.RunAs.bat" %*
) else if exist "%~dp0\Main.RunAs.ps1" (
  sudo --inline pwsh -NoLogo -NoProfile -ExecutionPolicy RemoteSigned -File "%~dp0\Main.RunAs.ps1" %*
)

:end
pause
exit /b %errorlevel%
