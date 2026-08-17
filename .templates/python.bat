@echo off
setlocal

:begin

:process
uv run --project "%~dp0..\..\.." python "%~dp0main.py" %*

:end
pause
exit /b %errorlevel%
