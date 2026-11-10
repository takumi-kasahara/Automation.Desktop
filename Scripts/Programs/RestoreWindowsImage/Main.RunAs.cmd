@echo off
setlocal enableextensions disabledelayedexpansion

:begin

:process
:: https://support.microsoft.com/en-us/accounts-billing/microsoft-store-doesn-t-open
WSReset
:: https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism-default-application-association-servicing-command-line-options?view=windows-11
Dism /Online /Remove-DefaultAppAssociations
:: https://support.microsoft.com/en-us/windows/experience/backup-recovery/use-the-system-file-checker-tool-to-repair-missing-or-corrupted-system-files
Dism /Online /Cleanup-Image /RestoreHealth
sfc /scannow
for /F %%D in ('powershell -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -Command "Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object -Property DriveType -EQ 3 | Select-Object -ExpandProperty DeviceID"') do (
  chkdsk %%D /scan /perf
)
:end
exit /B %errorlevel%
