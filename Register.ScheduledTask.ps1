[CmdletBinding()]
param ()

Set-StrictMode -Version Latest
Set-Location -LiteralPath $PSScriptRoot

$winEvent = Get-WinEvent -ListLog 'Microsoft-Windows-TaskScheduler/Operational'
if (-not $winEvent.IsEnabled) {
  $winEvent.IsEnabled = $true
  $winEvent.SaveChanges()
}
Get-ChildItem -LiteralPath '.\Scripts' -File -Recurse -Include @(
  'Run.bat'
) |
ForEach-Object {
  $name = $($_.Directory.Name)
  if ($name -cmatch '^[A-Z][a-z]*') {
    $verb = $matches[0]
  }
  if ($verb -notin 'Optimize') {
    return
  }
  $destination = $_.Directory | Join-Path -ChildPath 'Run.wsf'
  Copy-Item -LiteralPath '.templates\wsh.wsf' -Destination $destination -Force -PassThru | Set-ItemProperty -Name IsReadOnly -Value $true
  $arguments = @{
    TaskName = $name
    TaskPath = '\Automation.Desktop\'
    Action   = New-ScheduledTaskAction -Execute 'wscript.exe' -Argument (
      @(
        '//b'
        '//nologo'
        '//job:run'
        "`"$destination`""
      ) -join ' ')
    Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -RunOnlyIfIdle -StartWhenAvailable -DontStopIfGoingOnBatteries -RestartOnIdle
    Trigger  = New-ScheduledTaskTrigger -AtLogOn
    RunLevel = 'Highest'
  }
  Register-ScheduledTask @arguments -Force
}
