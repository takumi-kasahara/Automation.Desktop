@echo off
setlocal

set "ROOT=HKCU\Software\Thingamahoochie\WinMerge"
reg export "%ROOT%" "%TEMP%\WinMerge.reg" /y
reg delete "%ROOT%\Editor" /v "FindText" /f
reg delete "%ROOT%\Editor" /v "ReplaceText" /f
reg delete "%ROOT%\Files\DiffFile1" /f
reg delete "%ROOT%\Files\DiffFile2" /f
reg delete "%ROOT%\Files\DiffFileResult" /f
reg delete "%ROOT%\Files\EditorScript" /f
reg delete "%ROOT%\Files\Prediffer" /f
reg delete "%ROOT%\Files\Unpacker" /f
reg delete "%ROOT%\Files\Ext" /f
reg delete "%ROOT%\Files\Left" /f
reg delete "%ROOT%\Files\Right" /f
reg delete "%ROOT%\Recent File List" /f
reg delete "%ROOT%\ReportFiles" /f
reg delete "%ROOT%\ResizeableDialogs" /f
reg delete "%ROOT%\Settings" /v "ReBarState" /f
reg delete "%ROOT%\Settings-Bar0" /f
reg delete "%ROOT%\Settings-Bar1" /f
reg delete "%ROOT%\Settings-Bar2" /f
reg delete "%ROOT%\Settings-Bar3" /f
reg delete "%ROOT%\Settings-Bar4" /f
reg delete "%ROOT%\Settings-Bar5" /f
reg delete "%ROOT%\Settings-Bar6" /f
reg delete "%ROOT%\Settings-DirFrame-Bar0" /f
reg delete "%ROOT%\Settings-DirFrame-Bar1" /f
reg delete "%ROOT%\Settings-DirFrame-Bar2" /f
reg delete "%ROOT%\Settings-DirFrame-Summary" /f
reg delete "%ROOT%\Settings-ImgMergeFrame-Bar0" /f
reg delete "%ROOT%\Settings-ImgMergeFrame-Bar1" /f
reg delete "%ROOT%\Settings-ImgMergeFrame-Bar2" /f
reg delete "%ROOT%\Settings-ImgMergeFrame-SCBar-32820" /f
reg delete "%ROOT%\Settings-ImgMergeFrame-Summary" /f
reg delete "%ROOT%\Settings-SCBar-32819" /f
reg delete "%ROOT%\Settings-SCBar-32820" /f
reg delete "%ROOT%\Settings-Summary" /f

exit /b %errorlevel%
