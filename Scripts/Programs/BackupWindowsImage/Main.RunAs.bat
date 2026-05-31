@echo off
setlocal

:begin
for /f "usebackq" %%I in (`powershell -NoLogo -NoProfile -Command "Get-Disk | Where-Object -Property BusType -EQ 'USB' | Get-Partition | Get-Volume | Select-Object -ExpandProperty DriveLetter -First 1"`) do set "target=%%I:"
if not defined target (
  echo External drive not found.
  goto :end
)

:process
:: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/wbadmin
wbadmin start backup -backupTarget:%target% -allCritical -vssFull -quiet
wbadmin delete backup -keepVersions:1 -quiet

:end
exit /b %errorlevel%
