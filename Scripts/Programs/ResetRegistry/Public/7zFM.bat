@echo off
setlocal

set "ROOT=HKCU\Software\7-Zip\FM"
reg export "%ROOT%" "%TEMP%\7zFM.reg" /y
reg delete "%ROOT%" /v "FolderHistory" /f
reg delete "%ROOT%" /v "FlatViewArc0" /f
reg delete "%ROOT%" /v "FlatViewArc1" /f
reg delete "%ROOT%" /v "PanelPath0" /f
reg delete "%ROOT%" /v "PanelPath1" /f

exit /b %errorlevel%
