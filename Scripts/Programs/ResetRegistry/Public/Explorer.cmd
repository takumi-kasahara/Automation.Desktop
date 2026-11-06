@echo off
setlocal

set "ROOT=HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Modules\GlobalSettings\Sizer"
reg export "%ROOT%" "%TEMP%\Explorer.reg" /y
reg delete "%ROOT%" /v "PageSpaceControlSizer" /f
