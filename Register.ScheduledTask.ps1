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
  'Run.cmd'
) |
ForEach-Object {
  $name = $($_.Directory.Name)
  if ($name -cmatch '^[A-Z][a-z]*') {
    $verb = $matches[0]
  }
  if ($verb -notin 'Optimize') {
    return
  }
  Copy-Item -LiteralPath '.templates\Run.js' -Destination $_.DirectoryName -Force -PassThru | Set-ItemProperty -Name IsReadOnly -Value $true
  Copy-Item -LiteralPath '.templates\Run.wsf' -Destination $_.DirectoryName -Force -PassThru | Set-ItemProperty -Name IsReadOnly -Value $true
  $script = $_.DirectoryName | Join-Path -ChildPath 'Run.wsf'
  $arguments = @{
    TaskName = $name
    TaskPath = '\Automation.Desktop\'
    Action   = New-ScheduledTaskAction -Execute 'wscript.exe' -Argument (
      @(
        '//B'
        '//Nologo'
        '//Job:Run'
        "`"$script`""
      ) -join ' ')
    Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -RunOnlyIfIdle -StartWhenAvailable -DontStopIfGoingOnBatteries -RestartOnIdle
    Trigger  = New-ScheduledTaskTrigger -AtLogOn
  }
  Register-ScheduledTask @arguments -Force
}
