<#
.SYNOPSIS
  Creates and manages Windows Dev Drives for enhanced storage performance.

.DESCRIPTION
  This script creates and manages Windows Dev Drives, which are optimized storage volumes that provide faster performance for applications.
  It identifies external USBdrives, optimizes existing VHD files, and copies ReFS volumes to the Dev Drive location.

.NOTES
  Requires admin privileges to create and manage Dev Drives.
#>
using namespace System.IO

[CmdletBinding()]
param ()

Set-StrictMode -Version Latest
Set-Location -LiteralPath $PSScriptRoot

$externalDrive = Get-Disk |
Where-Object -Property BusType -EQ 'USB' |
Get-Partition |
Get-Volume |
Select-Object -ExpandProperty DriveLetter -First 1
if (-not $externalDrive) {
  throw 'External drive not found.'
}
$target = "$($externalDrive):\"

# https://learn.microsoft.com/en-us/windows/dev-drive/
try {
  Get-ChildItem -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\AutoAttachVirtualDisks' |
  ForEach-Object { $_.GetValue('Path') } |
  Where-Object { Test-Path -LiteralPath $_ } |
  ForEach-Object { [WildcardPattern]::Escape($_) } |
  ForEach-Object { Optimize-VHD -Path $_ -Mode Full }

  $root = $target | Join-Path -ChildPath 'DevDrives'
  @(Get-Volume | Where-Object -Property FileSystem -EQ 'ReFS' | Select-Object -ExpandProperty DriveLetter) |
  ForEach-Object {
    $source = "$($_):\"
    $destination = $root | Join-Path -ChildPath $_
    Invoke-Robocopy -Source $source -Destination $destination
    Remove-ItemAttribute -LiteralPath $destination -Attribute Hidden, System
  } | Out-Host
} catch {
  Write-Warning -Message $_.Exception.Message
}
