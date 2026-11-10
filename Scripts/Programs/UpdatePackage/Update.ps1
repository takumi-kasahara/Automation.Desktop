<#
.SYNOPSIS
  Trusts all package sources and PowerShell repositories, then updates modules and help.

.DESCRIPTION
  This script marks every registered package source as trusted and sets the installation policy of every PowerShell repository to Trusted.
  It then updates all installed modules and downloads the latest help files.

.NOTES
  Requires administrator privileges to update modules installed in system-wide locations.
  Changing package source trust settings affects all subsequent package operations in the session.
#>
[CmdletBinding()]
param ()
Set-StrictMode -Version Latest
Set-Location -LiteralPath $PSScriptRoot

Get-PackageSource | Set-PackageSource -Trusted
Get-PSRepository | ForEach-Object { Set-PSRepository -Name $_.Name -InstallationPolicy Trusted }
Update-Module
Update-Help
