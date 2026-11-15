@echo off
setlocal enableextensions disabledelayedexpansion

:begin

:process
uv run --project "%~dp0..\..\.." python "%~dp0%~n0.py" %*

:end
pause
exit /B %errorlevel%
