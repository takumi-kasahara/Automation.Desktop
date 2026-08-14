<#
.SYNOPSIS
  Synchronizes item dates between locations.

.DESCRIPTION
  This script synchronizes item dates between the specified paths.

.PARAMETER LiteralPath
  Specifies the paths of items to synchronize.

.NOTES
  Requires appropriate permissions to access the specified paths.
#>
using namespace System.IO
using namespace System.Globalization

[CmdletBinding()]
param (
  [Parameter(ValueFromRemainingArguments)]
  [ValidateScript({ Test-Path -LiteralPath $_ })]
  [string[]]
  $LiteralPath
)

Set-StrictMode -Version Latest
Set-Location -LiteralPath $PSScriptRoot

Sync-ItemDate -LiteralPath $LiteralPath
