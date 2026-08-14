<#
.SYNOPSIS
  Installs shortcuts and URL links to the user's Start Menu.

.DESCRIPTION
  This script installs shortcuts and URL links to the user's Start Menu.
  It creates a .Local directory in the Programs folder, removes existing shortcuts, and creates new shortcuts and URL links based on configuration.

.NOTES
  Requires admin privileges to install shortcuts.
  The script creates a .Local directory in the Programs folder.
#>
[CmdletBinding()]
param ()

Set-StrictMode -Version Latest
Set-Location -LiteralPath $PSScriptRoot

$programs = Get-SpecialFolder -Name Programs
$settings = $programs | Join-Path -ChildPath '.Local'
if (Test-Path -LiteralPath $settings) {
  Get-ChildItem -LiteralPath $settings -Filter '*.lnk' | Remove-Item
  Get-ChildItem -LiteralPath $settings -Filter '*.url' | Remove-Item
} else {
  New-Item -Path $settings -ItemType Directory | Out-Null
}
$config = Import-PowerShellDataFile -LiteralPath 'Config.psd1'
$config.Settings |
ForEach-Object {
  New-UrlShortcut -Path ($settings | Join-Path -ChildPath "$($_.Name).url") -TargetPath $_.Uri
}
$config.Shortcuts |
ForEach-Object {
  New-Shortcut -Path ($settings | Join-Path -ChildPath "$($_.Name).lnk") -TargetPath $_.TargetPath -Arguments $_.Arguments
}
$config.Controls |
ForEach-Object {
  New-Shortcut -Path ($settings | Join-Path -ChildPath "$(@($_ -split '\.')[-1]).lnk") -TargetPath 'control.exe' -Arguments "/name $_"
}
