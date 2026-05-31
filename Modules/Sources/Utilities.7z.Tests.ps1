using namespace System.Text

[CmdletBinding()]
param ()

$modulePath = $PSScriptRoot | Join-Path -ChildPath '..\Automation.Desktop.psm1'
Import-Module -Name $modulePath -Force
Set-StrictMode -Version Latest

InModuleScope 'Utilities.7z' {
  Describe 'Get-ArchivedItem' {
    BeforeAll {
      Mock -CommandName Get-Content
      Mock -CommandName Remove-Item
      Mock -CommandName Test-Path -MockWith { $true }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\Archive\*.7z' } -MockWith {
        [PSCustomObject]@{ FullName = 'C:\Archive\sample.7z' }
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\Archive\sample.7z' } -MockWith {
        [PSCustomObject]@{ FullName = 'C:\Archive\sample.7z' }
      }
      Mock -CommandName 7z.exe -MockWith {
        @(
          'Path = file1.txt'
          'Created = 2025-01-02 03:04:05'
          'Modified = 2025-01-02 06:07:08'
          'Accessed = 2025-01-02 09:10:11'
          ''
        )
      }
    }
    Context 'ParameterSetName' {
      It 'parses archive entries by Path with wildcard' {
        $result = Get-ArchivedItem -Path 'C:\Archive\*.7z'
        $result | Should -HaveCount 1
        $result[0].Path | Should -Be 'file1.txt'
        $result[0].CreationTime | Should -Be ([datetime]'2025-01-02 03:04:05')
        $result[0].LastWriteTime | Should -Be ([datetime]'2025-01-02 06:07:08')
        $result[0].LastAccessTime | Should -Be ([datetime]'2025-01-02 09:10:11')
      }
      It 'parses archive entries by Path with ValueFromPipeline' {
        'C:\Archive\*.7z' | Get-ArchivedItem | Should -HaveCount 1
      }
      It 'parses archive entries by Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = 'C:\Archive\*.7z' } | Get-ArchivedItem | Should -HaveCount 1
      }
      It 'parses archive entries by LiteralPath' {
        $result = Get-ArchivedItem -LiteralPath 'C:\Archive\sample.7z'
        $result | Should -HaveCount 1
        $result[0].Path | Should -Be 'file1.txt'
      }
      It 'parses archive entries by LiteralPath with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ LiteralPath = 'C:\Archive\sample.7z' } | Get-ArchivedItem | Should -HaveCount 1
      }
    }
    Context 'Other parameters' {
      It 'passes the encoding codepage to 7z.exe' {
        Mock -CommandName 7z.exe -ParameterFilter { $args -contains '-mcp=65001' } -MockWith {
          @(
            'Path = file1.txt'
            'Created = 2025-01-02 03:04:05'
            'Modified = 2025-01-02 06:07:08'
            'Accessed = 2025-01-02 09:10:11'
            ''
          )
        }
        Get-ArchivedItem -LiteralPath 'C:\Archive\sample.7z' -Encoding ([Encoding]::UTF8) | Out-Null
        Should -Invoke -CommandName 7z.exe -Times 1 -Exactly -ParameterFilter { $args -contains '-mcp=65001' }
      }
    }
    Context 'Edge cases' {
      It 'returns empty array when no archive metadata is returned' {
        Mock -CommandName 7z.exe
        $result = Get-ArchivedItem -LiteralPath 'C:\Archive\sample.7z'
        $result | Should -HaveCount 0
      }
    }
  }
  Describe 'Sync-ArchivedItemDate' {
    BeforeAll {
      Mock -CommandName Set-ItemDate
      Mock -CommandName Test-Path -MockWith { $true }
      Mock -CommandName Get-Item -MockWith {
        [PSCustomObject]@{
          FullName      = 'C:\Archive\sample.7z'
          PSIsContainer = $false
        }
      }
      Mock -CommandName Get-ArchivedItem -MockWith {
        [PSCustomObject]@{
          Path           = 'file1.txt'
          CreationTime   = [datetime]'2025-01-02 03:04:05'
          LastWriteTime  = [datetime]'2025-01-02 06:07:08'
          LastAccessTime = [datetime]'2025-01-02 09:10:11'
        }
      }
    }
    Context 'ParameterSetName' {
      It 'applies archive timestamps using Path' {
        Sync-ArchivedItemDate -Path 'C:\Archive\*.7z'
        Should -Invoke -CommandName Set-ItemDate -Times 1 -Exactly
        Should -Invoke -CommandName Get-ArchivedItem -Times 1 -Exactly
      }
      It 'applies archive timestamps using Path with ValueFromPipeline' {
        'C:\Archive\*.7z' | Sync-ArchivedItemDate
        Should -Invoke -CommandName Set-ItemDate -Times 1 -Exactly
      }
      It 'applies archive timestamps using Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = 'C:\Archive\*.7z' } | Sync-ArchivedItemDate
        Should -Invoke -CommandName Set-ItemDate -Times 1 -Exactly
      }
      It 'applies archive timestamps using LiteralPath' {
        Sync-ArchivedItemDate -LiteralPath 'C:\Archive\sample.7z'
        Should -Invoke -CommandName Set-ItemDate -Times 1 -Exactly
      }
      It 'applies archive timestamps using LiteralPath with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ LiteralPath = 'C:\Archive\sample.7z' } | Sync-ArchivedItemDate
        Should -Invoke -CommandName Set-ItemDate -Times 1 -Exactly
      }
    }
    Context 'SupportsShouldProcess' {
      It 'passes WhatIf through to Set-ItemDate' {
        Sync-ArchivedItemDate -LiteralPath 'C:\Archive\sample.7z' -WhatIf
        Should -Invoke -CommandName Set-ItemDate -Times 1 -Exactly
      }
    }
    Context 'Edge cases' {
      It 'does not update when no archive metadata is returned' {
        Mock -CommandName Get-ArchivedItem
        Sync-ArchivedItemDate -Path 'C:\Archive\*.7z'
        Should -Invoke -CommandName Set-ItemDate -Times 0 -Exactly
      }
    }
  }
}
