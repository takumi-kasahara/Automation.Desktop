using namespace System.Diagnostics.CodeAnalysis

[CmdletBinding()]
param ()

Import-Module -Name ($PSScriptRoot | Join-Path -ChildPath '..\Automation.Desktop.psm1') -Force
Set-StrictMode -Version Latest
$WhatIfPreference = $false

InModuleScope 'Utilities.QPDF' {
  BeforeAll {
    function Get-Password {
      [CmdletBinding()]
      [OutputType([SecureString])]
      [SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'Used in tests to generate random passwords for verification purposes')]
      param (
        [string]
        $Text
      )
      return ConvertTo-SecureString -String $Text -AsPlainText -Force
    }
  }
  Describe 'ConvertTo-Qdf' {
    BeforeAll {
      Mock -CommandName qpdf.exe
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
      It 'converts PDF to QDF' {
        ConvertTo-Qdf -Path 'C:\docs\manual.pdf' -Destination 'C:\dir\manual.qdf'

        Should-Invoke -CommandName qpdf.exe -Times 1 -Exactly
      }
      It 'converts PDF to QDF by Path with ValueFromPipeline' {
        'C:\docs\manual.pdf' | ConvertTo-Qdf -Destination 'C:\dir\manual.qdf'

        Should-Invoke -CommandName qpdf.exe -Times 1 -Exactly
      }
      It 'converts PDF to QDF by Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = 'C:\docs\manual.pdf' } | ConvertTo-Qdf -Destination 'C:\dir\manual.qdf'

        Should-Invoke -CommandName qpdf.exe -Times 1 -Exactly
      }
    }
    Context 'Other parameters' {
      It 'passes --owner-password to qpdf.exe when OwnerPassword is specified' {
        ConvertTo-Qdf -Path 'C:\docs\encrypted.pdf' -Destination 'C:\dir\manual.qdf' -OwnerPassword (Get-Password -Text 'owner123') -Force -Confirm:$false

        Should-Invoke -CommandName qpdf.exe -ParameterFilter { $args -contains '--owner-password=owner123' }
      }
      It 'passes --password to qpdf.exe when UserPassword is specified' {
        ConvertTo-Qdf -Path 'C:\docs\encrypted.pdf' -Destination 'C:\dir\manual.qdf' -UserPassword (Get-Password -Text 'user123') -Force -Confirm:$false

        Should-Invoke -CommandName qpdf.exe -ParameterFilter { $args -contains '--password=user123' }
      }
      It 'passes both passwords when both are specified' {
        ConvertTo-Qdf -Path 'C:\docs\encrypted.pdf' -Destination 'C:\dir\manual.qdf' -OwnerPassword (Get-Password -Text 'owner123') -UserPassword (Get-Password -Text 'user123') -Force -Confirm:$false

        Should-Invoke -CommandName qpdf.exe -ParameterFilter {
          $args -contains '--owner-password=owner123' -and $args -contains '--password=user123'
        }
      }
    }
    Context 'SupportsShouldProcess' {
      It 'does not call qpdf.exe when WhatIf is specified' {
        ConvertTo-Qdf -Path 'C:\docs\manual.pdf' -Destination 'C:\dir\manual.qdf' -Force -WhatIf

        Should-Invoke -CommandName qpdf.exe -Times 0 -Exactly
      }
      It 'calls qpdf.exe when Force is specified' {
        ConvertTo-Qdf -Path 'C:\docs\manual.pdf' -Destination 'C:\dir\manual.qdf' -Force -Confirm

        Should-Invoke -CommandName qpdf.exe -Times 1 -Exactly
      }
    }
    Context 'Other parameters' {
      It 'fails when NoClobber is specified and destination exists' {
        Mock -CommandName Test-Path -ParameterFilter { $LiteralPath -eq 'C:\dir\manual.qdf' } -MockWith { $true }
        { ConvertTo-Qdf -Path 'C:\docs\manual.pdf' -Destination 'C:\dir\manual.qdf' -NoClobber } | Should-Throw
      }
      It 'removes the log file when it is empty' {
        Mock -CommandName Get-Content -MockWith { @() }

        ConvertTo-Qdf -Path 'C:\docs\manual.pdf' -Destination 'C:\dir\manual.qdf'

        Should-Invoke -CommandName Remove-Item -ParameterFilter { $LiteralPath -like '*QPDF.*.log' } -Times 1 -Exactly
      }
      It 'writes the log path when the log file contains output' {
        Mock -CommandName Get-Content -MockWith { 'warning' }

        ConvertTo-Qdf -Path 'C:\docs\manual.pdf' -Destination 'C:\dir\manual.qdf'

        Should-Invoke -CommandName Out-Host -Times 1 -Exactly
        Should-Invoke -CommandName Remove-Item -ParameterFilter { $LiteralPath -like '*QPDF.*.log' } -Times 0 -Exactly
      }
    }
  }
  Describe 'ConvertFrom-Qdf' {
    BeforeAll {
      Mock -CommandName fix-qdf.exe
      Mock -CommandName Get-Content
      Mock -CommandName Out-Host
      Mock -CommandName Out-File
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
      It 'converts QDF to PDF' {
        ConvertFrom-Qdf -Path 'C:\dir\manual.qdf' -Destination 'C:\docs\manual.pdf'

        Should-Invoke -CommandName fix-qdf.exe -Times 1 -Exactly
      }
      It 'converts QDF to PDF by Path with ValueFromPipeline' {
        'C:\dir\manual.qdf' | ConvertFrom-Qdf -Destination 'C:\docs\manual.pdf'

        Should-Invoke -CommandName fix-qdf.exe -Times 1 -Exactly
      }
      It 'converts QDF to PDF by Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = 'C:\dir\manual.qdf' } | ConvertFrom-Qdf -Destination 'C:\docs\manual.pdf'

        Should-Invoke -CommandName fix-qdf.exe -Times 1 -Exactly
      }
    }
    Context 'Other parameters' {
      It 'passes --owner-password to fix-qdf.exe when OwnerPassword is specified' {
        ConvertFrom-Qdf -Path 'C:\dir\manual.qdf' -Destination 'C:\docs\manual.pdf' -OwnerPassword (Get-Password -Text 'owner123') -Force -Confirm:$false

        Should-Invoke -CommandName fix-qdf.exe -ParameterFilter { $args -contains '--owner-password=owner123' }
      }
      It 'passes --password to fix-qdf.exe when UserPassword is specified' {
        ConvertFrom-Qdf -Path 'C:\dir\manual.qdf' -Destination 'C:\docs\manual.pdf' -UserPassword (Get-Password -Text 'user123') -Force -Confirm:$false

        Should-Invoke -CommandName fix-qdf.exe -ParameterFilter { $args -contains '--password=user123' }
      }
      It 'passes both passwords when both are specified' {
        ConvertFrom-Qdf -Path 'C:\dir\manual.qdf' -Destination 'C:\docs\manual.pdf' -OwnerPassword (Get-Password -Text 'owner123') -UserPassword (Get-Password -Text 'user123') -Force -Confirm:$false

        Should-Invoke -CommandName fix-qdf.exe -ParameterFilter {
          $args -contains '--owner-password=owner123' -and $args -contains '--password=user123'
        }
      }
    }
    Context 'SupportsShouldProcess' {
      It 'does not call fix-qdf.exe when WhatIf is specified' {
        ConvertFrom-Qdf -Path 'C:\dir\manual.qdf' -Destination 'C:\docs\manual.pdf' -Force -WhatIf

        Should-Invoke -CommandName fix-qdf.exe -Times 0 -Exactly
      }
      It 'calls fix-qdf.exe when Force is specified' {
        ConvertFrom-Qdf -Path 'C:\dir\manual.qdf' -Destination 'C:\docs\manual.pdf' -Force -Confirm

        Should-Invoke -CommandName fix-qdf.exe -Times 1 -Exactly
      }
    }
    Context 'Other parameters' {
      It 'fails when NoClobber is specified and destination exists' {
        Mock -CommandName Test-Path -ParameterFilter { $LiteralPath -eq 'C:\docs\manual.pdf' } -MockWith { $true }

        { ConvertFrom-Qdf -Path 'C:\dir\manual.qdf' -Destination 'C:\docs\manual.pdf' -NoClobber } | Should-Throw
      }
      It 'removes the log file when it is empty' {
        Mock -CommandName Get-Content -MockWith { @() }

        ConvertFrom-Qdf -Path 'C:\dir\manual.qdf' -Destination 'C:\docs\manual.pdf'

        Should-Invoke -CommandName Remove-Item -ParameterFilter { $LiteralPath -like '*QPDF.*.log' } -Times 1 -Exactly
      }
      It 'writes the log path when the log file contains output' {
        Mock -CommandName Get-Content -MockWith { 'warning' }

        ConvertFrom-Qdf -Path 'C:\dir\manual.qdf' -Destination 'C:\docs\manual.pdf'

        Should-Invoke -CommandName Out-Host -Times 1 -Exactly
        Should-Invoke -CommandName Remove-Item -ParameterFilter { $LiteralPath -like '*QPDF.*.log' } -Times 0 -Exactly
      }
    }
  }
  Describe 'Get-PdfPage' {
    BeforeAll {
      Mock -CommandName Get-Content
      Mock -CommandName Remove-Item
      Mock -CommandName Test-Path -MockWith { $PathType -ne 'Container' }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\docs\*.pdf' } -MockWith {
        [PSCustomObject]@{ FullName = 'C:\docs\manual1.pdf' }
        [PSCustomObject]@{ FullName = 'C:\docs\manual2.pdf' }
      }
      Mock -CommandName Get-Item -ParameterFilter { -not [string]::IsNullOrEmpty($LiteralPath) } -MockWith {
        [PSCustomObject]@{
          FullName = $LiteralPath
        }
      }
    }
    Context 'ParameterSetName' {
      It 'returns page count by Path with wildcards' {
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--show-npages' } -MockWith {
          $global:LASTEXITCODE = 0
          return 12
        }

        Get-PdfPage -Path 'C:\docs\*.pdf' | Should-NotBeNull
      }
      It 'returns page count by Path with ValueFromPipeline' {
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--show-npages' } -MockWith {
          $global:LASTEXITCODE = 0
          return 12
        }

        'C:\docs\*.pdf' | Get-PdfPage | Should-NotBeNull
      }
      It 'returns page count by Path with ValueFromPipelineByPropertyName' {
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--show-npages' } -MockWith {
          $global:LASTEXITCODE = 0
          return 12
        }

        [PSCustomObject]@{ Path = 'C:\docs\*.pdf' } | Get-PdfPage | Should-NotBeNull
      }
      It 'returns page count by LiteralPath' {
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--show-npages' } -MockWith {
          $global:LASTEXITCODE = 0
          return 34
        }

        Get-PdfPage -LiteralPath 'C:\docs\manual.pdf' | Should-NotBeNull
      }
      It 'returns page count by LiteralPath with ValueFromPipelineByPropertyName' {
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--show-npages' } -MockWith {
          $global:LASTEXITCODE = 0
          return 34
        }

        [PSCustomObject]@{ LiteralPath = 'C:\docs\manual.pdf' } | Get-PdfPage | Should-NotBeNull
      }
    }
    Context 'Output' {
      It 'returns page count with Item property by Path with wildcards' {
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--show-npages' } -MockWith {
          $global:LASTEXITCODE = 0
          return 12
        }

        $result = Get-PdfPage -Path 'C:\docs\*.pdf'

        $result | Should-HaveType ([Object[]])
        $result.Count | Should-Be 2
        $result[0].PageCount | Should-Be 12
        $result[1].PageCount | Should-Be 12
        $result[0].Item.FullName | Should-BeString 'C:\docs\manual1.pdf'
        $result[1].Item.FullName | Should-BeString 'C:\docs\manual2.pdf'
      }
      It 'returns page count with Item property by LiteralPath' {
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--show-npages' } -MockWith {
          $global:LASTEXITCODE = 0
          return 34
        }

        $result = Get-PdfPage -LiteralPath 'C:\docs\manual.pdf'

        $result | Should-HaveType ([PSCustomObject])
        $result.PageCount | Should-Be 34
        $result.Item.FullName | Should-BeString 'C:\docs\manual.pdf'
      }
    }
    Context 'Other parameters' {
      It 'passes --owner-password to qpdf.exe when OwnerPassword is specified' {
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--show-npages' } -MockWith {
          $global:LASTEXITCODE = 0
          return 12
        }

        Get-PdfPage -LiteralPath 'C:\docs\encrypted.pdf' -OwnerPassword (Get-Password -Text 'owner123')

        Should-Invoke -CommandName qpdf.exe -ParameterFilter { $args -contains '--owner-password=owner123' }
      }
      It 'passes --password to qpdf.exe when UserPassword is specified' {
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--show-npages' } -MockWith {
          $global:LASTEXITCODE = 0
          return 12
        }

        Get-PdfPage -LiteralPath 'C:\docs\encrypted.pdf' -UserPassword (Get-Password -Text 'user123')

        Should-Invoke -CommandName qpdf.exe -ParameterFilter { $args -contains '--password=user123' }
      }
      It 'passes both passwords when both are specified' {
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--show-npages' } -MockWith {
          $global:LASTEXITCODE = 0
          return 12
        }

        Get-PdfPage -LiteralPath 'C:\docs\encrypted.pdf' -OwnerPassword (Get-Password -Text 'owner123') -UserPassword (Get-Password -Text 'user123')

        Should-Invoke -CommandName qpdf.exe -ParameterFilter {
          $args -contains '--owner-password=owner123' -and $args -contains '--password=user123'
        }
      }
    }
    Context 'Edge cases' {
      It 'returns no object when qpdf reports a non-zero exit code' {
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--show-npages' } -MockWith {
          $global:LASTEXITCODE = 1
          return 'Error'
        }

        $result = Get-PdfPage -LiteralPath 'C:\docs\manual.pdf'

        $result | Should-BeNull
      }
    }
  }
  Describe 'Unblock-Pdf' {
    BeforeAll {
      Mock -CommandName Get-Content
      Mock -CommandName Remove-Item
      Mock -CommandName Test-Path -MockWith { $true }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\docs\*.pdf' } -MockWith {
        @(
          [PSCustomObject]@{ FullName = 'C:\docs\manual1.pdf' }
          [PSCustomObject]@{ FullName = 'C:\docs\manual2.pdf' }
        )
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\docs\manual.pdf' } -MockWith {
        [PSCustomObject]@{ FullName = 'C:\docs\manual.pdf' }
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\docs\plain.pdf' } -MockWith {
        [PSCustomObject]@{ FullName = 'C:\docs\plain.pdf' }
      }
    }
    Context 'ParameterSetName' {
      It 'decrypts encrypted PDF files by Path with wildcards' {
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--show-encryption' } -MockWith {
          return 'R = 6'
        }
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--decrypt' } -MockWith { }

        Unblock-Pdf -Path 'C:\docs\*.pdf' -Confirm:$false

        Should-Invoke -CommandName qpdf.exe -ParameterFilter { $args -contains '--show-encryption' } -Times 2 -Exactly
        Should-Invoke -CommandName qpdf.exe -ParameterFilter { $args -contains '--decrypt' -and $args -contains '--replace-input' } -Times 2 -Exactly
      }
      It 'decrypts encrypted PDF files by Path with ValueFromPipeline' {
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--show-encryption' } -MockWith {
          return 'R = 6'
        }
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--decrypt' } -MockWith { }

        'C:\docs\*.pdf' | Unblock-Pdf -Confirm:$false

        Should-Invoke -CommandName qpdf.exe -ParameterFilter { $args -contains '--decrypt' } -Times 2 -Exactly
      }
      It 'decrypts encrypted PDF files by Path with ValueFromPipelineByPropertyName' {
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--show-encryption' } -MockWith {
          return 'R = 6'
        }
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--decrypt' } -MockWith { }

        [PSCustomObject]@{ Path = 'C:\docs\*.pdf' } | Unblock-Pdf -Confirm:$false

        Should-Invoke -CommandName qpdf.exe -ParameterFilter { $args -contains '--decrypt' } -Times 2 -Exactly
      }
      It 'decrypts encrypted PDF files by LiteralPath' {
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--show-encryption' } -MockWith {
          return 'R = 6'
        }
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--decrypt' } -MockWith { }

        Unblock-Pdf -LiteralPath 'C:\docs\manual.pdf' -Confirm:$false

        Should-Invoke -CommandName qpdf.exe -ParameterFilter {
          $args -contains '--show-encryption' -and $args[1].FullName -eq 'C:\docs\manual.pdf'
        } -Times 1 -Exactly
        Should-Invoke -CommandName qpdf.exe -ParameterFilter {
          $args -contains '--decrypt' -and $args -contains '--replace-input' -and $args[0].FullName -eq 'C:\docs\manual.pdf'
        } -Times 1 -Exactly
      }
      It 'decrypts encrypted PDF files by LiteralPath with ValueFromPipelineByPropertyName' {
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--show-encryption' } -MockWith {
          return 'R = 6'
        }
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--decrypt' } -MockWith { }

        [PSCustomObject]@{ LiteralPath = 'C:\docs\manual.pdf' } | Unblock-Pdf -Confirm:$false

        Should-Invoke -CommandName qpdf.exe -ParameterFilter { $args -contains '--decrypt' } -Times 1 -Exactly
      }
    }
    Context 'Other parameters' {
      It 'passes --owner-password to qpdf.exe when decrypting with OwnerPassword' {
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--show-encryption' } -MockWith {
          return 'R = 6'
        }
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--decrypt' } -MockWith { }

        Unblock-Pdf -LiteralPath 'C:\docs\manual.pdf' -OwnerPassword (Get-Password -Text 'owner123') -Confirm:$false

        Should-Invoke -CommandName qpdf.exe -ParameterFilter { $args -contains '--owner-password=owner123' } -Times 2 -Exactly
      }
      It 'passes --password to qpdf.exe when decrypting with UserPassword' {
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--show-encryption' } -MockWith {
          return 'R = 6'
        }
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--decrypt' } -MockWith { }
        Unblock-Pdf -LiteralPath 'C:\docs\manual.pdf' -UserPassword (Get-Password -Text 'user123') -Confirm:$false
        Should-Invoke -CommandName qpdf.exe -ParameterFilter { $args -contains '--password=user123' } -Times 2 -Exactly
      }
    }
    Context 'SupportsShouldProcess' {
      It 'does not decrypt the file when WhatIf is specified' {
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--show-encryption' } -MockWith {
          return 'R = 6'
        }
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--decrypt' } -MockWith { }

        Unblock-Pdf -LiteralPath 'C:\docs\manual.pdf' -WhatIf

        Should-Invoke -CommandName qpdf.exe -ParameterFilter { $args -contains '--show-encryption' } -Times 1 -Exactly
        Should-Invoke -CommandName qpdf.exe -ParameterFilter { $args -contains '--decrypt' } -Times 0 -Exactly
      }
      It 'decrypts the file when confirmation is accepted' {
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--show-encryption' } -MockWith {
          return 'R = 6'
        }
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--decrypt' } -MockWith { }

        Unblock-Pdf -LiteralPath 'C:\docs\manual.pdf' -Confirm:$false

        Should-Invoke -CommandName qpdf.exe -ParameterFilter { $args -contains '--decrypt' } -Times 1 -Exactly
      }
    }
    Context 'Edge cases' {
      It 'does not decrypt files that are not encrypted' {
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--show-encryption' } -MockWith {
          return 'File is not encrypted'
        }
        Mock -CommandName qpdf.exe -ParameterFilter { $args -contains '--decrypt' } -MockWith { }

        Unblock-Pdf -LiteralPath 'C:\docs\plain.pdf' -Confirm:$false

        Should-Invoke -CommandName qpdf.exe -ParameterFilter { $args -contains '--show-encryption' } -Times 1 -Exactly
        Should-Invoke -CommandName qpdf.exe -ParameterFilter { $args -contains '--decrypt' } -Times 0 -Exactly
      }
    }
  }
}
