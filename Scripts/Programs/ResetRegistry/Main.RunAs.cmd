@echo off
setlocal

:begin

:process
for /r "%~dp0\Public" %%f in ("*.cmd") do (
  echo call "%%~nxf"
  call "%%f"
)

:end
exit /b %errorlevel%
