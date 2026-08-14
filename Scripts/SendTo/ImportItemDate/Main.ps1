<#
.SYNOPSIS
  Imports item dates from a specified location.

.DESCRIPTION
  This script imports item dates from the specified paths to a target location.

.PARAMETER LiteralPath
  Specifies the paths of items to import.

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

Import-ItemDate -Path $LiteralPath -PassThru
