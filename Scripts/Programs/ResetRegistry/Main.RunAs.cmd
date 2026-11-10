@echo off
setlocal enableextensions disabledelayedexpansion

:begin

:process
for /R "%~dp0\Public" %%f in ("*.cmd") do (
  echo call "%%~nxf"
  call "%%f"
)

:end
exit /B %errorlevel%
