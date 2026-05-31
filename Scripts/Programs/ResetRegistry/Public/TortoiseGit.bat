@echo off
setlocal

set "ROOT=HKCU\Software\TortoiseGit\TortoiseProc\ResizableState"
reg export "%ROOT%" "%TEMP%\TortoiseGit.reg" /y
reg delete "%ROOT%" /f

exit /b %errorlevel%
