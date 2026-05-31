[CmdletBinding()]
param ()

$modulePath = $PSScriptRoot | Join-Path -ChildPath '..\Automation.Desktop.psm1'
Import-Module -Name $modulePath -Force
Set-StrictMode -Version Latest

InModuleScope 'Utilities.PDFtk' {
  Describe 'Export-PdfDump' {
    BeforeAll {
      Mock -CommandName pdftk.exe
      Mock -CommandName Get-Content
      Mock -CommandName Out-File
      Mock -CommandName Out-Host
      Mock -CommandName Remove-Item
      Mock -CommandName Test-Path -MockWith { $PathType -ne 'Container' }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\Docs\*.pdf' } -MockWith {
        [PSCustomObject]@{ FullName = 'C:\Docs\manual1.pdf' }
        [PSCustomObject]@{ FullName = 'C:\Docs\manual2.pdf' }
      }
      Mock -CommandName Get-Item -ParameterFilter { -not [string]::IsNullOrEmpty($LiteralPath) } -MockWith {
        [PSCustomObject]@{
          FullName   = $LiteralPath
          IsReadOnly = $false
        }
      }
    }
    Context 'ParameterSetName' {
      It 'calls pdftk.exe by FilePath' {
        Export-PdfDump -Path 'C:\Docs\manual.pdf' -Destination 'C:\Temp\dump.txt'
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly
      }
      It 'calls pdftk.exe by Path with ValueFromPipeline' {
        'C:\Docs\manual.pdf' | Export-PdfDump -Destination 'C:\Temp\dump.txt'
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly
      }
      It 'calls pdftk.exe by Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = 'C:\Docs\manual.pdf' } | Export-PdfDump -Destination 'C:\Temp\dump.txt'
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly
      }
    }
    Context 'SupportsShouldProcess' {
      It 'does not call pdftk.exe when WhatIf is specified' {
        Export-PdfDump -Path 'C:\Docs\manual.pdf' -Destination 'C:\Temp\dump.txt' -Force -WhatIf
        Should -Invoke -CommandName pdftk.exe -Times 0 -Exactly
      }
      It 'calls pdftk.exe when Force is specified' {
        Export-PdfDump -Path 'C:\Docs\manual.pdf' -Destination 'C:\Temp\dump.txt' -Force -Confirm
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly
      }
      It 'fails when NoClobber is specified and destination exists' {
        Mock -CommandName Test-Path -ParameterFilter { $LiteralPath -eq 'C:\Temp\dump.txt' } -MockWith { $true }
        { Export-PdfDump -Path 'C:\Docs\manual.pdf' -Destination 'C:\Temp\dump.txt' -NoClobber } | Should -Throw
      }
    }
    Context 'Other parameters' {
      It 'passes dump_data_utf8 and output to pdftk.exe' {
        Export-PdfDump -Path 'C:\Docs\manual.pdf' -Destination 'C:\Temp\dump.txt'
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly -ParameterFilter {
          $args -contains 'dump_data_utf8' -and
          $args -contains 'output' -and
          $args -contains 'C:\Temp\dump.txt'
        }
      }
      It 'writes the log path when the log file contains output' {
        Mock -CommandName Get-Content -MockWith { 'warning' }
        Export-PdfDump -Path 'C:\Docs\manual.pdf' -Destination 'C:\Temp\dump.txt'
        Should -Invoke -CommandName Out-Host -Times 1 -Exactly
      }
    }
  }
  Describe 'Import-PdfDump' {
    BeforeAll {
      Mock -CommandName pdftk.exe
      Mock -CommandName Get-Content
      Mock -CommandName Out-File
      Mock -CommandName Out-Host
      Mock -CommandName Remove-Item
      Mock -CommandName Test-Path -MockWith { $PathType -ne 'Container' }
      Mock -CommandName Get-Item -ParameterFilter { -not [string]::IsNullOrEmpty($LiteralPath) } -MockWith {
        [PSCustomObject]@{
          FullName   = $LiteralPath
          IsReadOnly = $false
        }
      }
    }
    Context 'ParameterSetName' {
      It 'calls pdftk.exe by FilePath' {
        Import-PdfDump -Path 'C:\Docs\manual.pdf' -Source 'C:\Temp\dump.txt' -Destination 'C:\Temp\manual.updated.pdf'
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly
      }
      It 'calls pdftk.exe by Path with ValueFromPipeline' {
        'C:\Docs\manual.pdf' | Import-PdfDump -Source 'C:\Temp\dump.txt' -Destination 'C:\Temp\manual.updated.pdf'
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly
      }
      It 'calls pdftk.exe by Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = 'C:\Docs\manual.pdf' } | Import-PdfDump -Source 'C:\Temp\dump.txt' -Destination 'C:\Temp\manual.updated.pdf'
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly
      }
    }
    Context 'SupportsShouldProcess' {
      It 'does not call pdftk.exe when WhatIf is specified' {
        Import-PdfDump -Path 'C:\Docs\manual.pdf' -Source 'C:\Temp\dump.txt' -Destination 'C:\Temp\manual.updated.pdf' -Force -WhatIf
        Should -Invoke -CommandName pdftk.exe -Times 0 -Exactly
      }
      It 'calls pdftk.exe when Force is specified' {
        Import-PdfDump -Path 'C:\Docs\manual.pdf' -Source 'C:\Temp\dump.txt' -Destination 'C:\Temp\manual.updated.pdf' -Force -Confirm
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly
      }
    }
    Context 'Other parameters' {
      It 'passes update_info_utf8 and output to pdftk.exe' {
        Import-PdfDump -Path 'C:\Docs\manual.pdf' -Source 'C:\Temp\dump.txt' -Destination 'C:\Temp\manual.updated.pdf'
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly -ParameterFilter {
          $args -contains 'update_info_utf8' -and
          $args -contains 'C:\Temp\dump.txt' -and
          $args -contains 'output' -and
          $args -contains 'C:\Temp\manual.updated.pdf'
        }
      }
      It 'removes the log file when it is empty' {
        Mock -CommandName Get-Content -MockWith { @() }
        Import-PdfDump -Path 'C:\Docs\manual.pdf' -Source 'C:\Temp\dump.txt' -Destination 'C:\Temp\manual.updated.pdf'
        Should -Invoke -CommandName Remove-Item -ParameterFilter { $LiteralPath -like '*PDFtk.*.log' } -Times 1 -Exactly
      }
    }
  }
}
