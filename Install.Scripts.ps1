using namespace System.IO
[CmdletBinding()]
param ()
if ($PSEdition -ne 'Core') {
  return
}
Set-StrictMode -Version Latest
Set-Location -LiteralPath $PSScriptRoot

function Install-Shortcut {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [FileInfo]
    $FileInfo,
    [Parameter(Mandatory)]
    [string]
    $Destination
  )
  $shortcutDefinitions = @(
    @{
      Name      = $FileInfo.Directory.Name
      Arguments = $null
    }
  )
  if ($FileInfo.Name -eq 'Run.wsf') {
    $config = $FileInfo.DirectoryName | Join-Path -ChildPath 'Config.psd1'
    if (Test-Path -LiteralPath $config) {
      $shortcutDefinitions = (Import-PowerShellDataFile -LiteralPath $config).Shortcuts
    }
  }
  $script = $FileInfo.FullName
  foreach ($shortcutDefinition in $shortcutDefinitions) {
    $path = $Destination | Join-Path -ChildPath "$($shortcutDefinition.Name)$($FileInfo.Extension).lnk"
    $arguments = switch -Exact -CaseSensitive ($FileInfo.Name) {
      'Run.cmd' {
        @{
          Path         = $path
          TargetPath   = 'wt.exe'
          Arguments    = "`"$script`""
          IconLocation = 'cmd.exe,0'
        }
      }
      'Run.wsf' {
        $wscript = @(
          '//B'
          '//Nologo'
          '//Job:Main'
          "`"$script`""
        )
        if ($shortcutDefinition.Arguments) {
          $wscript += $shortcutDefinition.Arguments
        }
        @{
          Path         = $path
          TargetPath   = 'wscript.exe'
          Arguments    = $wscript -join ' '
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
}

& '.\Build.ps1'

$startMenu = Get-SpecialFolder -Name Programs | Join-Path -ChildPath '.Local\Scripts'
if (Test-Path -LiteralPath $startMenu) {
  Get-ChildItem -LiteralPath $startMenu -Filter '*.lnk' | Remove-Item
} else {
  New-Item -Path $startMenu -ItemType Directory | Out-Null
}
'.\Scripts\Programs' |
Get-ChildItem -File -Recurse |
ForEach-Object {
  Install-Shortcut -FileInfo $_ -Destination $startMenu
}
$sendTo = Get-SpecialFolder -Name SendTo
'.\Scripts\SendTo' |
Get-ChildItem -File -Recurse |
ForEach-Object {
  Install-Shortcut -FileInfo $_ -Destination $sendTo
}
