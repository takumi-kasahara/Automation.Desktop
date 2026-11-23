[CmdletBinding()]
param ()
Set-StrictMode -Version Latest

Describe 'Add-Type' {
  It 'compiles StringMetrics' {
    Add-Type -LiteralPath ($PSScriptRoot | Join-Path -ChildPath 'StringMetrics.cs')

    'StringMetrics.Levenshtein' -as [type] | Should-NotBeNull
    'StringMetrics.LCS' -as [type] | Should-NotBeNull
  }
}
