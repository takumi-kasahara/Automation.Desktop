@echo off
setlocal enableextensions disabledelayedexpansion

:begin

:process
if exist "%~dp0Main.cmd" goto :run_bat
if exist "%~dp0Main.ps1" goto :run_ps1
if exist "%~dp0Main.RunAs.cmd" goto :runas_bat
if exist "%~dp0Main.RunAs.ps1" goto :runas_ps1
goto :end

:run_bat
cmd /D /E:ON /V:OFF /S /C "%~dp0Main.cmd" %*
goto :end

:run_ps1
pwsh -NoLogo -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -File "%~dp0Main.ps1" %*
goto :end

:runas_bat
sudo --disable-input cmd /D /E:ON /V:OFF /S /C "%~dp0Main.RunAs.cmd" %*
goto :end

:runas_ps1
sudo --disable-input pwsh -NoLogo -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -File "%~dp0Main.RunAs.ps1" %*
goto :end

:end
pause
exit /B %errorlevel%
