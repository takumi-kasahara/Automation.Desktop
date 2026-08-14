<#
.SYNOPSIS
  Restores default SendTo menu items.

.DESCRIPTION
  This script restores default SendTo menu items by creating missing shortcut files in the user's SendTo folder.
  It checks for standard SendTo targets and creates them if they don't exist.

.NOTES
  The script creates shortcut files for common SendTo destinations like compressed folders, desktop shortcuts, documents, and mail recipients.
#>
[CmdletBinding()]
param ()

Set-StrictMode -Version Latest
Set-Location -LiteralPath $PSScriptRoot

$sendTo = Get-SpecialFolder -Name SendTo
@(
  $sendTo | Join-Path -ChildPath 'Compressed (zipped) Folder.ZFSendToTarget'
  $sendTo | Join-Path -ChildPath 'Desktop (create shortcut).DeskLink'
  $sendTo | Join-Path -ChildPath 'Documents.mydocs'
  $sendTo | Join-Path -ChildPath 'Mail Recipient.MAPIMail'
) |
Where-Object { -not (Test-Path -LiteralPath $_) } |
ForEach-Object { New-Item -Path $_ -ItemType File }
