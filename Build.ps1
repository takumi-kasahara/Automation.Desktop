[CmdletBinding()]
param ()

Set-StrictMode -Version Latest
Set-Location -LiteralPath $PSScriptRoot

Get-ChildItem -LiteralPath 'Scripts' -File -Recurse -Include @(
  '*.bat'
  '*.ps1'
  '*.js'
) |
ForEach-Object {
  if ($_.Name -eq 'Run.bat') {
    return
  }
  if ($_.Name -eq 'Run.wsf') {
    return
  }
  $directory = $_.Directory
  $arguments = switch -Exact -CaseSensitive ($_.Name) {
    { $_ -cin 'Main.bat', 'Main.RunAs.bat', 'Main.ps1', 'Main.RunAs.ps1' } {
      @{
        LiteralPath = '.templates\cmd.bat'
        Destination = $directory | Join-Path -ChildPath 'Run.bat'
      }
    }
    { $_ -cin 'Main.js' } {
      @{
        LiteralPath = '.templates\wsh.wsf'
        Destination = $directory | Join-Path -ChildPath 'Run.wsf'
      }
    }
    default {
      return
    }
  }
  if ($arguments) {
    $item = Copy-Item @arguments -Force -PassThru
    $item | Set-ItemProperty -Name IsReadOnly -Value $true
    return $item
  }
}
