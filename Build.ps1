[CmdletBinding()]
param ()
Set-StrictMode -Version Latest
Set-Location -LiteralPath $PSScriptRoot

Get-ChildItem -LiteralPath '.\Scripts' -File -Recurse -Include @(
  '*.cmd'
  '*.ps1'
  '*.js'
) |
ForEach-Object {
  if ($_.Name -eq 'Run.cmd') {
    return
  }
  if ($_.Name -eq 'Run.wsf') {
    return
  }
  $directoryName = $_.DirectoryName
  $items = switch -Exact -CaseSensitive ($_.Name) {
    { $_ -cin 'Main.cmd', 'Main.RunAs.cmd', 'Main.ps1', 'Main.RunAs.ps1' } {
      Copy-Item -LiteralPath '.\.templates\Run.cmd' -Destination $directoryName -Force -PassThru
    }
    { $_ -cin 'Main.js' } {
      Copy-Item -LiteralPath '.\.templates\Run.wsf' -Destination $directoryName -Force -PassThru
    }
    default {
      return
    }
  }
  $items |
  ForEach-Object {
    $_ | Set-ItemProperty -Name IsReadOnly -Value $true
    return $_
  }
} | Out-Host
Get-ChildItem -LiteralPath '.\Tools\src' -File -Filter '*.py' |
ForEach-Object {
  $baseName = $_.BaseName
  $destination = $_.DirectoryName | Join-Path -ChildPath "$baseName.cmd"
  $item = Copy-Item -LiteralPath '.\.templates\python.cmd' -Destination $destination -Force -PassThru
  $item | Set-ItemProperty -Name IsReadOnly -Value $true
  return $item
} | Out-Host
