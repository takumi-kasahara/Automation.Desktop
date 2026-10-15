@echo off
setlocal

:begin

:process
if exist "%~dp0\Main.bat" goto :run_bat
if exist "%~dp0\Main.ps1" goto :run_ps1
if exist "%~dp0\Main.RunAs.bat" goto :run_as_bat
if exist "%~dp0\Main.RunAs.ps1" goto :run_as_ps1
goto :end

:run_bat
cmd /c "%~dp0\Main.bat" %*
goto :end

:run_ps1
pwsh -NoLogo -NoProfile -ExecutionPolicy RemoteSigned -File "%~dp0\Main.ps1" %*
goto :end

:run_as_bat
sudo --inline cmd /c "%~dp0\Main.RunAs.bat" %*
goto :end

:run_as_ps1
sudo --inline pwsh -NoLogo -NoProfile -ExecutionPolicy RemoteSigned -File "%~dp0\Main.RunAs.ps1" %*
goto :end

:end
pause
exit /b %errorlevel%
