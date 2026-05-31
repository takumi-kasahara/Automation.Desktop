using namespace System.IO

[CmdletBinding()]
param ()

Set-StrictMode -Version Latest

Describe 'Add-Type' {
  It 'compiles StringMetrics' {
    Add-Type -LiteralPath ([Path]::GetFullPath(($PSScriptRoot | Join-Path -ChildPath 'StringMetrics.cs')))
    'StringMetrics.Levenshtein' -as [type] | Should -Not -BeNullOrEmpty
    'StringMetrics.LCS' -as [type] | Should -Not -BeNullOrEmpty
  }
}
