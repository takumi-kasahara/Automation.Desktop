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
