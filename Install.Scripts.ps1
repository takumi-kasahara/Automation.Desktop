[CmdletBinding()]
param ()

Set-StrictMode -Version Latest
Set-Location -LiteralPath $PSScriptRoot

& '.\Build.ps1'

$startMenu = Get-SpecialFolder -Name Programs | Join-Path -ChildPath '.Local\Scripts'
if (Test-Path -LiteralPath $startMenu) {
  Get-ChildItem -LiteralPath $startMenu -Filter '*.lnk' | Remove-Item
}
else {
  New-Item -Path $startMenu -ItemType Directory | Out-Null
}
'Scripts\Programs' |
Get-ChildItem -File -Recurse |
ForEach-Object {
  $path = $startMenu | Join-Path -ChildPath "$($_.Directory.Name)$($_.Extension).lnk"
  $fullName = $_.FullName
  $arguments = switch -Exact -CaseSensitive ($_.Name) {
    'Run.bat' {
      @{
        Path         = $path
        TargetPath   = 'wt.exe'
        Arguments    = "`"$fullName`""
        IconLocation = 'cmd.exe,0'
      }
    }
    'Run.wsf' {
      @{
        Path         = $path
        TargetPath   = 'wscript.exe'
        Arguments    = @(
          '//b'
          '//nologo'
          '//job:run'
          "`"$fullName`""
        ) -join ' '
        IconLocation = 'wscript.exe,1'
      }
    }
    default {
      return
    }
  }
  if ($arguments) {
    New-Shortcut @arguments
  }
}
$sendTo = Get-SpecialFolder -Name SendTo
'Scripts\SendTo' |
Get-ChildItem -File -Recurse |
ForEach-Object {
  $path = $sendTo | Join-Path -ChildPath "$($_.Directory.Name)$($_.Extension).lnk"
  $fullName = $_.FullName
  $arguments = switch -Exact -CaseSensitive ($_.Name) {
    'Run.bat' {
      @{
        Path         = $path
        TargetPath   = 'wt.exe'
        Arguments    = "`"$fullName`""
        IconLocation = 'cmd.exe,0'
      }
    }
    'Run.wsf' {
      @{
        Path         = $path
        TargetPath   = 'wscript.exe'
        Arguments    = @(
          '//b'
          '//nologo'
          '//job:run'
          "`"$fullName`""
        ) -join ' '
        IconLocation = 'wscript.exe,1'
      }
    }
    default {
      return
    }
  }
  if ($arguments) {
    New-Shortcut @arguments
  }
}
