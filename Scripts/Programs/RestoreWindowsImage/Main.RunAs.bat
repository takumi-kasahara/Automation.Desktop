@echo off
setlocal

:begin

:process
:: https://support.microsoft.com/en-us/account-billing/microsoft-store-doesn-t-open-126a875d-8b72-def1-0af6-d325276a058b
WSReset
:: https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism-default-application-association-servicing-command-line-options?view=windows-11
Dism /Online /Remove-DefaultAppAssociations
:: https://support.microsoft.com/en-us/topic/use-the-system-file-checker-tool-to-repair-missing-or-corrupted-system-files-79aa86cb-ca52-166a-92a3-966e85d4094e
Dism /Online /Cleanup-Image /RestoreHealth
sfc /SCANNOW
for /f %%D in ('powershell -NoProfile -Command "Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object -Property DriveType -EQ 3 | Select-Object -ExpandProperty DeviceID"') do (
  chkdsk %%D /scan /perf
)
:end
exit /b %errorlevel%
