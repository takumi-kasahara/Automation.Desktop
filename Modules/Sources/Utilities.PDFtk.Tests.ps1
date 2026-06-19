using namespace System.Diagnostics.CodeAnalysis

[CmdletBinding()]
param ()

$modulePath = $PSScriptRoot | Join-Path -ChildPath '..\Automation.Desktop.psm1'
Import-Module -Name $modulePath -Force
Set-StrictMode -Version Latest
$WhatIfPreference = $false

InModuleScope 'Utilities.PDFtk' {
  BeforeAll {
    function Get-Password {
      [CmdletBinding()]
      [OutputType([SecureString])]
      [SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'Used in tests to generate random passwords for verification purposes')]
      param (
        [string]$Text
      )
      return ConvertTo-SecureString -String $Text -AsPlainText -Force
    }
  }
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
    Context 'Password parameters' {
      It 'passes owner_pw to pdftk.exe when OwnerPassword is specified' {
        Export-PdfDump -Path 'C:\Docs\manual.pdf' -Destination 'C:\Temp\dump.txt' -OwnerPassword (Get-Password -Text 'owner')
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly -ParameterFilter {
          $args -contains 'owner_pw' -and
          $args -contains 'dump_data_utf8'
        }
      }
      It 'passes user_pw to pdftk.exe when UserPassword is specified' {
        Export-PdfDump -Path 'C:\Docs\manual.pdf' -Destination 'C:\Temp\dump.txt' -UserPassword (Get-Password -Text 'user')
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly -ParameterFilter {
          $args -contains 'user_pw' -and
          $args -contains 'dump_data_utf8'
        }
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
    Context 'Password parameters' {
      It 'passes owner_pw to pdftk.exe when OwnerPassword is specified' {
        Import-PdfDump -Path 'C:\Docs\manual.pdf' -Source 'C:\Temp\dump.txt' -Destination 'C:\Temp\manual.updated.pdf' -OwnerPassword (Get-Password -Text 'owner') -Force
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly -ParameterFilter {
          $args -contains 'owner_pw' -and
          $args -contains 'update_info_utf8'
        }
      }
      It 'passes user_pw to pdftk.exe when UserPassword is specified' {
        Import-PdfDump -Path 'C:\Docs\manual.pdf' -Source 'C:\Temp\dump.txt' -Destination 'C:\Temp\manual.updated.pdf' -UserPassword (Get-Password -Text 'user') -Force
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly -ParameterFilter {
          $args -contains 'user_pw' -and
          $args -contains 'update_info_utf8'
        }
      }
    }
  }
  Describe 'Join-Pdf' {
    BeforeAll {
      Mock -CommandName pdftk.exe
      Mock -CommandName Get-Content
      Mock -CommandName Out-Host
      Mock -CommandName Remove-Item
      Mock -CommandName Test-Path -MockWith { $PathType -ne 'Container' }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\Docs\manual.pdf' } -MockWith {
        [PSCustomObject]@{
          FullName      = 'C:\Docs\manual.pdf'
          IsReadOnly    = $false
          PSIsContainer = $false
        }
      }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\Docs' } -MockWith {
        [PSCustomObject]@{
          FullName      = 'C:\Docs'
          Name          = 'Docs'
          Parent        = [PSCustomObject]@{ FullName = 'C:\' }
          IsReadOnly    = $false
          PSIsContainer = $true
        }
      }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\Docs\chapter1.pdf' } -MockWith {
        [PSCustomObject]@{
          FullName      = 'C:\Docs\chapter1.pdf'
          IsReadOnly    = $false
          PSIsContainer = $false
        }
      }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\Docs\chapter2.pdf' } -MockWith {
        [PSCustomObject]@{
          FullName      = 'C:\Docs\chapter2.pdf'
          IsReadOnly    = $false
          PSIsContainer = $false
        }
      }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\Books' } -MockWith {
        [PSCustomObject]@{
          FullName      = 'C:\Books'
          Name          = 'Books'
          Parent        = [PSCustomObject]@{ FullName = 'C:\' }
          IsReadOnly    = $false
          PSIsContainer = $true
        }
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\Docs\manual.pdf' } -MockWith {
        [PSCustomObject]@{
          FullName      = 'C:\Docs\manual.pdf'
          IsReadOnly    = $false
          PSIsContainer = $false
        }
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\Temp\merged.pdf' } -MockWith {
        [PSCustomObject]@{
          FullName   = 'C:\Temp\merged.pdf'
          IsReadOnly = $false
        }
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\Docs.pdf' } -MockWith {
        [PSCustomObject]@{
          FullName   = 'C:\Docs.pdf'
          IsReadOnly = $false
        }
      }
    }
    Context 'ParameterSetName' {
      It 'calls pdftk.exe with Path parameter set' {
        Join-Pdf -Path 'C:\Docs\manual.pdf' -Destination 'C:\Temp\merged.pdf'
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly
      }
      It 'calls pdftk.exe with wildcard Path parameter set' {
        Join-Pdf -Path 'C:\Docs\*.pdf' -Destination 'C:\Temp\merged.pdf'
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly
      }
      It 'calls pdftk.exe with multiple file paths' {
        Join-Pdf -Path 'C:\Docs\chapter1.pdf', 'C:\Docs\chapter2.pdf' -Destination 'C:\Temp\merged.pdf'
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly
      }
      It 'calls pdftk.exe with LiteralPath parameter set' {
        Join-Pdf -LiteralPath 'C:\Docs\manual.pdf' -Destination 'C:\Temp\merged.pdf'
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly
      }
    }
    Context 'Source shape' {
      It 'passes quoted file path and verbose when source is a file' {
        Join-Pdf -Path 'C:\Docs\manual.pdf' -Destination 'C:\Temp\merged.pdf'
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly -ParameterFilter {
          $args[0] -eq '"C:\Docs\manual.pdf"' -and
          $args -contains 'cat' -and
          $args -contains 'output' -and
          $args -contains 'C:\Temp\merged.pdf' -and
          $args -contains 'verbose'
        }
      }
      It 'passes quoted file list and verbose when multiple files are specified' {
        Join-Pdf -Path 'C:\Docs\chapter1.pdf', 'C:\Docs\chapter2.pdf' -Destination 'C:\Temp\merged.pdf'
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly -ParameterFilter {
          $args[0] -eq '"C:\Docs\chapter1.pdf" "C:\Docs\chapter2.pdf"' -and
          $args -contains 'cat' -and
          $args -contains 'output' -and
          $args -contains 'C:\Temp\merged.pdf' -and
          $args -contains 'verbose'
        }
      }
      It 'passes wildcard Path as specified without expanding it' {
        Join-Pdf -Path 'C:\Docs\*.pdf' -Destination 'C:\Temp\merged.pdf'
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly -ParameterFilter {
          $args[0] -eq '"C:\Docs\*.pdf"' -and
          $args -contains 'cat' -and
          $args -contains 'output' -and
          $args -contains 'C:\Temp\merged.pdf' -and
          $args -contains 'verbose'
        }
      }
      It 'passes quoted directory wildcard and verbose when source is a directory' {
        Join-Pdf -Path 'C:\Docs' -Destination 'C:\Temp\merged.pdf'
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly -ParameterFilter {
          $args[0] -eq '"C:\Docs\*.pdf"' -and
          $args -contains 'cat' -and
          $args -contains 'output' -and
          $args -contains 'C:\Temp\merged.pdf' -and
          $args -contains 'verbose'
        }
      }
      It 'uses directory name as default output when Destination is omitted' {
        Join-Pdf -Path 'C:\Docs'
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly -ParameterFilter {
          $args[0] -eq '"C:\Docs\*.pdf"' -and
          $args -contains 'cat' -and
          $args -contains 'output' -and
          $args[3] -eq 'C:\Docs.pdf' -and
          $args -contains 'verbose'
        }
      }
    }
    Context 'SupportsShouldProcess' {
      It 'does not call pdftk.exe when WhatIf is specified' {
        Join-Pdf -Path 'C:\Docs\manual.pdf' -Destination 'C:\Temp\merged.pdf' -WhatIf
        Should -Invoke -CommandName pdftk.exe -Times 0 -Exactly
      }
    }
    Context 'Overwrite behavior' {
      It 'throws when destination exists and NoClobber is specified' {
        Mock -CommandName Test-Path -ParameterFilter { $LiteralPath -eq 'C:\Temp\merged.pdf' -and $PathType -eq 'Leaf' } -MockWith { $true }
        { Join-Pdf -Path 'C:\Docs\manual.pdf' -Destination 'C:\Temp\merged.pdf' -NoClobber } | Should -Throw
      }
    }
    Context 'Edge case' {
      It 'throws when multiple directories are specified' {
        { Join-Pdf -Path 'C:\Docs', 'C:\Books' -Destination 'C:\Temp\merged.pdf' } | Should -Throw
      }
      It 'throws when a file and directory are specified together' {
        { Join-Pdf -Path 'C:\Docs\manual.pdf', 'C:\Docs' -Destination 'C:\Temp\merged.pdf' } | Should -Throw
      }
      It 'throws when Destination is omitted for file input' {
        { Join-Pdf -Path 'C:\Docs\manual.pdf' -ErrorAction Stop } | Should -Throw -ErrorId 'DestinationRequired,Join-Pdf'
      }
    }
    Context 'Password parameters' {
      It 'passes owner_pw to pdftk.exe when OwnerPassword is specified' {
        Join-Pdf -Path 'C:\Docs\manual.pdf' -Destination 'C:\Temp\merged.pdf' -OwnerPassword (Get-Password -Text 'owner') -Force
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly -ParameterFilter {
          $args -contains 'owner_pw' -and
          $args -contains 'cat'
        }
      }
      It 'passes user_pw to pdftk.exe when UserPassword is specified' {
        Join-Pdf -Path 'C:\Docs\manual.pdf' -Destination 'C:\Temp\merged.pdf' -UserPassword (Get-Password -Text 'user') -Force
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly -ParameterFilter {
          $args -contains 'user_pw' -and
          $args -contains 'cat'
        }
      }
    }
  }
  Describe 'Split-Pdf' {
    BeforeAll {
      Mock -CommandName pdftk.exe
      Mock -CommandName Get-Content
      Mock -CommandName Out-Host
      Mock -CommandName Remove-Item
      Mock -CommandName Test-Path -MockWith { $PathType -ne 'Container' }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\Docs\manual.pdf' } -MockWith {
        [PSCustomObject]@{
          FullName      = 'C:\Docs\manual.pdf'
          IsReadOnly    = $false
          PSIsContainer = $false
        }
      }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\Docs' } -MockWith {
        [PSCustomObject]@{
          FullName      = 'C:\Docs'
          IsReadOnly    = $false
          PSIsContainer = $true
        }
      }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\Docs\readme.txt' } -MockWith {
        [PSCustomObject]@{
          FullName      = 'C:\Docs\readme.txt'
          IsReadOnly    = $false
          PSIsContainer = $false
        }
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\Docs\manual.pdf' } -MockWith {
        [PSCustomObject]@{
          FullName      = 'C:\Docs\manual.pdf'
          IsReadOnly    = $false
          PSIsContainer = $false
        }
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\Temp\page_%04d.pdf' } -MockWith {
        [PSCustomObject]@{
          FullName   = 'C:\Temp\page_%04d.pdf'
          IsReadOnly = $false
        }
      }
    }
    Context 'ParameterSetName' {
      It 'calls pdftk.exe with Path parameter set' {
        Split-Pdf -Path 'C:\Docs\manual.pdf' -Destination 'C:\Temp\page_%04d.pdf'
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly
      }
      It 'calls pdftk.exe with LiteralPath parameter set' {
        Split-Pdf -LiteralPath 'C:\Docs\manual.pdf' -Destination 'C:\Temp\page_%04d.pdf'
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly
      }
    }
    Context 'SupportsShouldProcess' {
      It 'does not call pdftk.exe when WhatIf is specified' {
        Split-Pdf -Path 'C:\Docs\manual.pdf' -Destination 'C:\Temp\page_%04d.pdf' -WhatIf
        Should -Invoke -CommandName pdftk.exe -Times 0 -Exactly
      }
    }
    Context 'Other parameters' {
      It 'passes burst, output and verbose to pdftk.exe' {
        Split-Pdf -Path 'C:\Docs\manual.pdf' -Destination 'C:\Temp\page_%04d.pdf'
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly -ParameterFilter {
          $args -contains 'C:\Docs\manual.pdf' -and
          $args -contains 'burst' -and
          $args -contains 'output' -and
          $args -contains 'C:\Temp\page_%04d.pdf' -and
          $args -contains 'verbose'
        }
      }
    }
    Context 'Edge case' {
      It 'throws when source path is a directory' {
        { Split-Pdf -Path 'C:\Docs' -Destination 'C:\Temp\page_%04d.pdf' } | Should -Throw
      }
      It 'throws when source is not a PDF file' {
        { Split-Pdf -Path 'C:\Docs\readme.txt' -Destination 'C:\Temp\page_%04d.pdf' } | Should -Throw
      }
    }
    Context 'Password parameters' {
      It 'passes owner_pw to pdftk.exe when OwnerPassword is specified' {
        Split-Pdf -Path 'C:\Docs\manual.pdf' -Destination 'C:\Temp\page_%04d.pdf' -OwnerPassword (Get-Password -Text 'owner')
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly -ParameterFilter {
          $args -contains 'owner_pw' -and
          $args -contains 'burst'
        }
      }
      It 'passes user_pw to pdftk.exe when UserPassword is specified' {
        Split-Pdf -Path 'C:\Docs\manual.pdf' -Destination 'C:\Temp\page_%04d.pdf' -UserPassword (Get-Password -Text 'user')
        Should -Invoke -CommandName pdftk.exe -Times 1 -Exactly -ParameterFilter {
          $args -contains 'user_pw' -and
          $args -contains 'burst'
        }
      }
    }
  }
}
