<#
.SYNOPSIS
  Exports item dates to a specified location.

.DESCRIPTION
  This script exports item dates from the specified paths to a backup location.

.PARAMETER LiteralPath
  Specifies the paths of items to export.

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

Export-ItemDate -LiteralPath $LiteralPath -NoClobber
