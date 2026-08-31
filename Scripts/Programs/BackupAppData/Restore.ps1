<#
.SYNOPSIS
  Restores backed-up AppData directories from an external USB drive.

.DESCRIPTION
  This script restores directories listed in Directory.psd1 from a backup drive
  to the current machine's environment paths.

.NOTES
  Requires admin privileges to access external drives.
#>
[CmdletBinding()]
param ()

Set-StrictMode -Version Latest
Set-Location -LiteralPath $PSScriptRoot

Import-Module -LiteralPath (Resolve-Path -LiteralPath '..' | Join-Path -ChildPath '..' | Join-Path -ChildPath '..' | Join-Path -ChildPath 'Modules' | Join-Path -ChildPath 'Automation.Desktop.psd1')

$externalDrive = Get-Disk |
Where-Object -Property BusType -EQ 'USB' |
Get-Partition |
Get-Volume |
Select-Object -ExpandProperty DriveLetter -First 1
if (-not $externalDrive) {
  throw 'External drive not found.'
}
$sourceRoot = "$($externalDrive):"

Get-Process |
Where-Object -Property ProcessName -EQ 'Everything' |
Stop-Process -Force

# Invoke-Robocopy expanded (no module import required)
# Always includes /L for dry-run restore preview.
(Import-PowerShellDataFile -LiteralPath 'Directory.psd1').GetEnumerator() |
Sort-Object -Property Name |
ForEach-Object {
  $name = $_.Name
  $path = 'Env:\' | Join-Path -ChildPath $name
  if (-not (Test-Path -LiteralPath $path)) {
    return
  }
  $item = Get-Item -LiteralPath $path
  if ($_.Value.Count -eq 0) {
    $source = $sourceRoot | Join-Path -ChildPath $name
    if (-not (Test-Path -LiteralPath $source -PathType Container)) {
      Write-Warning -Message "$source not found."
      return
    }
    $destination = $item.Value
    Invoke-Robocopy -Source $source -Destination $destination -NoClobber -Confirm
  } else {
    $_.Value |
    ForEach-Object {
      if ($_ -match '^\.\.[\\/]') {
        Write-Verbose -Message "Skipped parent-relative path: $_"
        return
      }
      $source = $sourceRoot | Join-Path -ChildPath $name | Join-Path -ChildPath $_
      if (-not (Test-Path -LiteralPath $source -PathType Container)) {
        Write-Warning -Message "$source not found."
        return
      }
      $destination = $item.Value | Join-Path -ChildPath $_
      Invoke-Robocopy -Source $source -Destination $destination -NoClobber -Confirm
    }
  }
} | Out-Host
