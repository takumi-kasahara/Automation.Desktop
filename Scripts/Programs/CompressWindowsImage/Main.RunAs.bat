@echo off
setlocal

:begin

:process
:: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/arp
arp /d *
:: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/ipconfig
ipconfig /flushdns

:: https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/clean-up-the-winsxs-folder?view=windows-11
Dism /Online /Cleanup-Image /StartComponentCleanup /ResetBase
Dism /Online /Cleanup-Image /SPSuperseded

:end
exit /b %errorlevel%
