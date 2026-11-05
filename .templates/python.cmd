@echo off
setlocal

:begin

:process
uv run --project "%~dp0..\..\.." python "%~dp0%~n0.py" %*

:end
pause
exit /b %errorlevel%
