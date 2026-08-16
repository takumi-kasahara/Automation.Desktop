using namespace System.Management.Automation

[CmdletBinding()]
param ()

Import-Module -Name ($PSScriptRoot | Join-Path -ChildPath '..\Automation.Desktop.psm1') -Force
Set-StrictMode -Version Latest

InModuleScope 'Path' {
  Describe 'Compress-EnvironmentVariable' {
    BeforeAll {
      Mock -CommandName Get-ChildItem -ParameterFilter { $LiteralPath -eq 'Env:' } -MockWith {
        @(
          [PSCustomObject]@{
            Name  = 'HOME'
            Value = 'C:\Users\User'
          }
          [PSCustomObject]@{
            Name  = 'PATH'
            Value = 'C:\Users'
          }
          [PSCustomObject]@{
            Name  = 'EMPTY'
            Value = [string]::Empty
          }
        )
      }
    }
    Context 'Output' {
      It 'replaces environment variable values with percent-wrapped names' {
        $inputString = 'Begin C:\Users\User and then C:\Users end'

        $result = Compress-EnvironmentVariable -InputString $inputString

        $result | Should-BeString 'Begin %HOME% and then %PATH% end'
      }
    }
    Context 'Edge cases' {
      It 'skips empty environment variable values' {
        $inputString = 'Value C:\Users\User and empty text'

        $result = Compress-EnvironmentVariable -InputString $inputString

        $result | Should-NotMatchString '%EMPTY%'
      }
      It 'replaces longer matches before shorter substrings' {
        Mock -CommandName Get-ChildItem -ParameterFilter { $LiteralPath -eq 'Env:' } -MockWith {
          @(
            [PSCustomObject]@{
              Name  = 'LONG'
              Value = 'C:\Foo\Bar'
            }
            [PSCustomObject]@{
              Name  = 'SHORT'
              Value = 'C:\Foo'
            }
          )
        }
        $result = Compress-EnvironmentVariable -InputString 'Path C:\Foo\Bar'
        $result | Should-BeString 'Path %LONG%'
      }
    }
  }
  Describe 'Expand-EnvironmentVariable' {
    BeforeAll {
      $oldTestExpandVar1 = $env:TEST_EXPAND_VAR1
      $oldTestExpandVar2 = $env:TEST_EXPAND_VAR2
      $env:TEST_EXPAND_VAR1 = 'C:\Users\User'
      $env:TEST_EXPAND_VAR2 = 'C:\Temp'
    }
    AfterAll {
      if ($null -ne $oldTestExpandVar1) {
        $env:TEST_EXPAND_VAR1 = $oldTestExpandVar1
      } else {
        Remove-Item -LiteralPath 'Env:TEST_EXPAND_VAR1'
      }
      if ($null -ne $oldTestExpandVar2) {
        $env:TEST_EXPAND_VAR2 = $oldTestExpandVar2
      } else {
        Remove-Item -LiteralPath 'Env:TEST_EXPAND_VAR2'
      }
    }
    Context 'Output' {
      It 'expands a single environment variable' {
        $result = Expand-EnvironmentVariable -InputString '%TEST_EXPAND_VAR1%\file.txt'

        $result | Should-BeString 'C:\Users\User\file.txt'
      }
      It 'expands multiple environment variables' {
        $result = Expand-EnvironmentVariable -InputString '%TEST_EXPAND_VAR1%\%TEST_EXPAND_VAR2%'

        $result | Should-BeString 'C:\Users\User\C:\Temp'
      }
    }
    Context 'Edge cases' {
      It 'leaves unknown environment variables unchanged' {
        $result = Expand-EnvironmentVariable -InputString '%UNKNOWN_ENV_VAR%'

        $result | Should-BeString '%UNKNOWN_ENV_VAR%'
      }
    }
  }
  Describe 'ConvertTo-localPath' {
    BeforeAll {
      $oldComputerName = $env:COMPUTERNAME
      $env:COMPUTERNAME = 'Server'
      Mock -CommandName Compress-EnvironmentVariable -MockWith { $InputString }
      Mock -CommandName Test-Path -MockWith { $true }
      Mock -CommandName Get-CimInstance -ParameterFilter { $ClassName -eq 'Win32_Share' } -MockWith {
        @(
          [PSCustomObject]@{
            Name = 'share'
            Path = 'C:\share'
          }
        )
      }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq '\\server\share\*' } -MockWith {
        [PSCustomObject]@{ FullName = '\\server\share\dir\file.txt' }
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq '\\server\share\dir\file.txt' } -MockWith {
        [PSCustomObject]@{ FullName = '\\server\share\dir\file.txt' }
      }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\local\dir\file.txt' } -MockWith {
        [PSCustomObject]@{ FullName = 'C:\local\dir\file.txt' }
      }
    }
    AfterAll {
      if ($null -ne $oldComputerName) {
        $env:COMPUTERNAME = $oldComputerName
      } else {
        Remove-Item -LiteralPath 'Env:COMPUTERNAME'
      }
    }
    Context 'ParameterSetName' {
      It 'converts UNC share paths by Path with wildcards' {
        $result = ConvertTo-LocalPath -Path '\\server\share\*'

        $result | Should-BeString 'C:\share\dir\file.txt'
      }
      It 'converts UNC share paths by Path with ValueFromPipeline' {
        '\\server\share\*' | ConvertTo-LocalPath | Should-BeString 'C:\share\dir\file.txt'
      }
      It 'converts UNC share paths by Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = '\\server\share\*' } | ConvertTo-LocalPath | Should-BeString 'C:\share\dir\file.txt'
      }
      It 'converts UNC share paths by LiteralPath' {
        $result = ConvertTo-LocalPath -LiteralPath '\\server\share\dir\file.txt'

        $result | Should-BeString 'C:\share\dir\file.txt'
      }
    }
    Context 'Edge cases' {
      It 'returns a non-UNC local path unchanged' {
        $result = ConvertTo-LocalPath -Path 'C:\local\dir\file.txt'

        $result | Should-BeString 'C:\local\dir\file.txt'
      }
    }
  }
  Describe 'ConvertTo-NetworkPath' {
    BeforeAll {
      $oldComputerName = $env:COMPUTERNAME
      $env:COMPUTERNAME = 'Server'
      Mock -CommandName Test-Path -MockWith { $true }
      Mock -CommandName Get-CimInstance -ParameterFilter { $ClassName -eq 'Win32_Share' } -MockWith {
        @(
          [PSCustomObject]@{
            Name = 'share'
            Path = 'C:\share'
          }
        )
      }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\share\dir\*' } -MockWith {
        [PSCustomObject]@{ FullName = 'C:\share\dir\file.txt' }
      }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\share\dir\file.txt' } -MockWith {
        [PSCustomObject]@{ FullName = 'C:\share\dir\file.txt' }
      }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq '\\server\share\dir\file.txt' } -MockWith {
        [PSCustomObject]@{ FullName = '\\server\share\dir\file.txt' }
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\share\dir\file.txt' } -MockWith {
        [PSCustomObject]@{ FullName = 'C:\share\dir\file.txt' }
      }
    }
    AfterAll {
      if ($null -ne $oldComputerName) {
        $env:COMPUTERNAME = $oldComputerName
      } else {
        Remove-Item -LiteralPath 'Env:COMPUTERNAME'
      }
    }
    Context 'ParameterSetName' {
      It 'converts local paths to UNC paths by Path with wildcards' {
        $result = ConvertTo-NetworkPath -Path 'C:\share\dir\*'

        $result | Should-BeString '\\server\share\dir\file.txt'
      }
      It 'converts local paths to UNC paths by Path with ValueFromPipeline' {
        'C:\share\dir\*' | ConvertTo-NetworkPath | Should-BeString '\\server\share\dir\file.txt'
      }
      It 'converts local paths to UNC paths by Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = 'C:\share\dir\*' } | ConvertTo-NetworkPath | Should-BeString '\\server\share\dir\file.txt'
      }
      It 'converts local paths to UNC paths by LiteralPath' {
        $result = ConvertTo-NetworkPath -LiteralPath 'C:\share\dir\file.txt'

        $result | Should-BeString '\\server\share\dir\file.txt'
      }
    }
    Context 'Edge cases' {
      It 'returns an already UNC path unchanged' {
        $result = ConvertTo-NetworkPath -Path '\\server\share\dir\file.txt'

        $result | Should-BeString '\\server\share\dir\file.txt'
      }
    }
  }
  Describe 'ConvertTo-WSLPath' {
    BeforeAll {
      Mock -CommandName wsl.exe -MockWith { "WSL_PATH:$([string]::Join(' ', $args))" }
      Mock -CommandName Test-Path -MockWith { $true }
      Mock -CommandName Get-Item -ParameterFilter { -not [string]::IsNullOrEmpty($Path) } -MockWith {
        [PSCustomObject]@{ FullName = $Path }
      }
      Mock -CommandName Get-Item -ParameterFilter { -not [string]::IsNullOrEmpty($LiteralPath) } -MockWith {
        [PSCustomObject]@{ FullName = $LiteralPath }
      }
    }
    Context 'ParameterSetName' {
      It 'converts a Path Windows path to WSL path' {
        $result = ConvertTo-WSLPath -Path 'C:\Users\User\file.txt'

        $result | Should-BeString 'WSL_PATH:wslpath -a -u C:/Users/User/file.txt'
      }
      It 'converts a Path Windows path to WSL path with ValueFromPipeline' {
        'C:\Users\User\file.txt' | ConvertTo-WSLPath | Should-BeString 'WSL_PATH:wslpath -a -u C:/Users/User/file.txt'
      }
      It 'converts a Path Windows path to WSL path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = 'C:\Users\User\file.txt' } | ConvertTo-WSLPath | Should-BeString 'WSL_PATH:wslpath -a -u C:/Users/User/file.txt'
      }
      It 'converts a LiteralPath Windows path to WSL path' {
        $result = ConvertTo-WSLPath -LiteralPath 'C:\Users\User\file.txt'

        $result | Should-BeString 'WSL_PATH:wslpath -a -u C:/Users/User/file.txt'
      }
    }
    Context 'Other parameters' {
      It 'passes additional arguments to wsl.exe' {
        $result = ConvertTo-WSLPath -Path 'C:\Users\User\file.txt' -ArgumentList '--quiet'

        $result | Should-BeString 'WSL_PATH:--quiet wslpath -a -u C:/Users/User/file.txt'
      }
    }
  }
  Describe 'Get-NormalizedPath' {
    BeforeAll {
      Mock -CommandName Test-Path -MockWith { $true }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\*' } -MockWith {
        @(
          [PSCustomObject]@{
            FullName      = 'C:\dir\file1.txt'
            Name          = 'file1.txt'
            PSIsContainer = $false
            Directory     = [PSCustomObject]@{ FullName = 'C:\dir' }
          }
          [PSCustomObject]@{
            FullName      = 'C:\dir\file2.txt'
            Name          = 'file2.txt'
            PSIsContainer = $false
            Directory     = [PSCustomObject]@{ FullName = 'C:\dir' }
          }
        )
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\dir\file.txt' } -MockWith {
        [PSCustomObject]@{
          FullName      = 'C:\dir\file.txt'
          Name          = 'file.txt'
          PSIsContainer = $false
          Directory     = [PSCustomObject]@{ FullName = 'C:\dir' }
        }
      }
    }
    Context 'ParameterSetName' {
      It 'normalizes a wildcard Path using Get-Item' {
        $result = Get-NormalizedPath -Path 'C:\dir\*'

        $result | Should -HaveCount 2
        $result | Should-BeCollection @(
          'C:\dir\file1.txt',
          'C:\dir\file2.txt'
        )
      }
      It 'normalizes a wildcard Path with ValueFromPipeline' {
        'C:\dir\*' | Get-NormalizedPath | Should -HaveCount 2
      }
      It 'normalizes a wildcard Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = 'C:\dir\*' } | Get-NormalizedPath | Should -HaveCount 2
      }
      It 'normalizes a LiteralPath directly' {
        $result = Get-NormalizedPath -LiteralPath 'C:\dir\file.txt'

        $result | Should-BeString 'C:\dir\file.txt'
      }
    }
    Context 'Other parameters' {
      It 'supports compatible normalization mode' {
        $result = Get-NormalizedPath -Path 'C:\dir\*' -Compatible

        $result | Should -HaveCount 2
        $result | Should-BeCollection @(
          'C:\dir\file1.txt',
          'C:\dir\file2.txt'
        )
      }
    }
  }
  Describe 'Move-NormalizedPath' {
    BeforeAll {
      $mockSource = 'C:\Mock\file.txt'
      $mockDest = 'C:\Mock\file.normalized.txt'
      Mock -CommandName Get-Item -MockWith {
        [PSCustomObject]@{
          FullName      = $mockSource
          PSIsContainer = $false
        }
      }
      Mock -CommandName Get-ChildItem -MockWith {
        [PSCustomObject]@{
          FullName      = $mockSource
          PSIsContainer = $false
        }
      }
      Mock -CommandName Get-NormalizedPath -MockWith {
        $mockDest
      }
      Mock -CommandName Test-Path -MockWith {
        param(
          [string]
          $Path,
          [string]
          $LiteralPath
        )
        if ($PSBoundParameters.ContainsKey('Path')) {
          return $Path -eq $mockSource
        }
        if ($PSBoundParameters.ContainsKey('LiteralPath')) {
          return $LiteralPath -eq $mockSource
        }
        return $false
      }
      Mock -CommandName Move-Item -MockWith {
        param(
          [string]
          $LiteralPath,
          [string]
          $Destination,
          [switch]
          $PassThru
        )
        if ($PassThru) {
          return [PSCustomObject]@{
            Source      = $LiteralPath
            Destination = $Destination
          }
        }
      }
    }
    Context 'ParameterSetName' {
      It 'moves a item to its normalized destination by Path' {
        Move-NormalizedPath -Path $mockSource

        Should-Invoke -CommandName Move-Item -Times 1 -Exactly
      }
      It 'moves a item to its normalized destination by Path with ValueFromPipeline' {
        $mockSource | Move-NormalizedPath
        Should-Invoke -CommandName Move-Item -Times 1 -Exactly
      }
      It 'moves a item to its normalized destination by Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = $mockSource } | Move-NormalizedPath
        Should-Invoke -CommandName Move-Item -Times 1 -Exactly
      }
      It 'moves a item to its normalized destination by LiteralPath' {
        Move-NormalizedPath -LiteralPath $mockSource

        Should-Invoke -CommandName Move-Item -Times 1 -Exactly
      }
    }
    Context 'SupportsShouldProcess' {
      It 'does not move the item when WhatIf is specified' {
        Move-NormalizedPath -Path $mockSource -Force -WhatIf

        Should-Invoke -CommandName Move-Item -Times 0 -Exactly
      }
      It 'suppresses ShouldProcess when Force is supplied with Confirm' {
        Move-NormalizedPath -Path $mockSource -Force -Confirm

        Should-Invoke -CommandName Move-Item -Times 1 -Exactly
      }
    }
    Context 'Other parameters' {
      It 'returns PSObject when PassThru is specified' {
        $result = Move-NormalizedPath -Path $mockSource -PassThru

        $result | Should -BeOfType [PSObject]
        $result.Source | Should-BeString $mockSource
        $result.Destination | Should-BeString $mockDest
      }
    }
    Context 'Edge cases' {
    }
  }
  Describe 'Test-ArchiveExtension' {
    BeforeAll {
      Mock -CommandName Test-Path -MockWith {
        if ($PSBoundParameters.ContainsKey('IsValid')) {
          return $true
        }
        $target = if ($LiteralPath -is [string]) {
          $LiteralPath
        } elseif ($null -ne $LiteralPath -and $LiteralPath.PSObject.Properties.Name -contains 'FullName') {
          $LiteralPath.FullName
        } else {
          [string]$LiteralPath
        }
        if ($PathType -eq 'Leaf') {
          return $target -notlike '*\folder'
        }
        return $true
      }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\Docs\*' } -MockWith {
        @(
          [PSCustomObject]@{ FullName = 'C:\Docs\archive.zip' }
          [PSCustomObject]@{ FullName = 'C:\Docs\notes.txt' }
        )
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\Docs\archive.zip' } -MockWith {
        [PSCustomObject]@{ FullName = 'C:\Docs\archive.zip' }
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\Docs\notes.txt' } -MockWith {
        [PSCustomObject]@{ FullName = 'C:\Docs\notes.txt' }
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\Docs\folder' } -MockWith {
        [PSCustomObject]@{ FullName = 'C:\Docs\folder' }
      }
    }
    Context 'ParameterSetName' {
      It 'returns true for archive files by Path with wildcards' {
        Test-ArchiveExtension -Path 'C:\Docs\*' | Should -BeTrue
      }
      It 'returns true by Path with ValueFromPipeline' {
        'C:\Docs\*' | Test-ArchiveExtension | Should -BeTrue
      }
      It 'returns true by Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = 'C:\Docs\*' } | Test-ArchiveExtension | Should -BeTrue
      }
      It 'returns true by LiteralPath' {
        Test-ArchiveExtension -LiteralPath 'C:\Docs\archive.zip' | Should -BeTrue
      }
      It 'returns true by LiteralPath with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ LiteralPath = 'C:\Docs\archive.zip' } | Test-ArchiveExtension | Should -BeTrue
      }
    }
    Context 'Other parameters' {
      It 'returns false when none of the files have archive extensions' {
        Test-ArchiveExtension -LiteralPath 'C:\Docs\notes.txt' | Should -BeFalse
      }
      It 'matches archive extensions case-insensitively' {
        Test-ArchiveExtension -LiteralPath 'C:\Docs\archive.ZIP' | Should -BeTrue
      }
    }
    Context 'Edge cases' {
      It 'returns false for non-leaf items' {
        Test-ArchiveExtension -LiteralPath 'C:\Docs\folder' | Should -BeFalse
      }
      It 'returns false when Get-Item throws ItemNotFoundException' {
        Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\Docs\missing.*' } -MockWith {
          throw [ItemNotFoundException]::new('Not found')
        }
        Test-ArchiveExtension -Path 'C:\Docs\missing.*' | Should -BeFalse
      }
    }
  }
  Describe 'Test-PdfExtension' {
    BeforeAll {
      Mock -CommandName Test-Path -MockWith {
        if ($PSBoundParameters.ContainsKey('IsValid')) {
          return $true
        }
        $target = if ($LiteralPath -is [string]) {
          $LiteralPath
        } elseif ($null -ne $LiteralPath -and $LiteralPath.PSObject.Properties.Name -contains 'FullName') {
          $LiteralPath.FullName
        } else {
          [string]$LiteralPath
        }
        if ($PathType -eq 'Leaf') {
          return $target -notlike '*\folder'
        }
        return $true
      }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\Docs\*.pdf' } -MockWith {
        @(
          [PSCustomObject]@{ FullName = 'C:\Docs\manual.pdf' }
          [PSCustomObject]@{ FullName = 'C:\Docs\notes.txt' }
        )
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\Docs\manual.pdf' } -MockWith {
        [PSCustomObject]@{ FullName = 'C:\Docs\manual.pdf' }
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\Docs\notes.txt' } -MockWith {
        [PSCustomObject]@{ FullName = 'C:\Docs\notes.txt' }
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\Docs\folder' } -MockWith {
        [PSCustomObject]@{ FullName = 'C:\Docs\folder' }
      }
    }
    Context 'ParameterSetName' {
      It 'returns true for PDF files by Path with wildcards' {
        Test-PdfExtension -Path 'C:\Docs\*.pdf' | Should -BeTrue
      }
      It 'returns true by Path with ValueFromPipeline' {
        'C:\Docs\*.pdf' | Test-PdfExtension | Should -BeTrue
      }
      It 'returns true by Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = 'C:\Docs\*.pdf' } | Test-PdfExtension | Should -BeTrue
      }
      It 'returns true by LiteralPath' {
        Test-PdfExtension -LiteralPath 'C:\Docs\manual.pdf' | Should -BeTrue
      }
      It 'returns true by LiteralPath with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ LiteralPath = 'C:\Docs\manual.pdf' } | Test-PdfExtension | Should -BeTrue
      }
    }
    Context 'Other parameters' {
      It 'returns false when none of the files are PDFs' {
        Test-PdfExtension -LiteralPath 'C:\Docs\notes.txt' | Should -BeFalse
      }
      It 'matches PDF extensions case-insensitively' {
        Test-PdfExtension -LiteralPath 'C:\Docs\manual.PDF' | Should -BeTrue
      }
    }
    Context 'Edge cases' {
      It 'returns false for non-leaf items' {
        Test-PdfExtension -LiteralPath 'C:\Docs\folder' | Should -BeFalse
      }
      It 'returns false when Get-Item throws ItemNotFoundException' {
        Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\Docs\missing.pdf' } -MockWith {
          throw [ItemNotFoundException]::new('Not found')
        }
        Test-PdfExtension -Path 'C:\Docs\missing.pdf' | Should -BeFalse
      }
    }
  }
  Describe 'Test-PictureExtension' {
    BeforeAll {
      Mock -CommandName Test-Path -MockWith {
        if ($PSBoundParameters.ContainsKey('IsValid')) {
          return $true
        }
        $target = if ($LiteralPath -is [string]) {
          $LiteralPath
        } elseif ($null -ne $LiteralPath -and $LiteralPath.PSObject.Properties.Name -contains 'FullName') {
          $LiteralPath.FullName
        } else {
          [string]$LiteralPath
        }
        if ($PathType -eq 'Leaf') {
          return $target -notlike '*\folder'
        }
        return $true
      }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\Pictures\*' } -MockWith {
        @(
          [PSCustomObject]@{ FullName = 'C:\Pictures\photo.jpg' }
          [PSCustomObject]@{ FullName = 'C:\Pictures\notes.txt' }
        )
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\Pictures\photo.jpg' } -MockWith {
        [PSCustomObject]@{ FullName = 'C:\Pictures\photo.jpg' }
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\Pictures\notes.txt' } -MockWith {
        [PSCustomObject]@{ FullName = 'C:\Pictures\notes.txt' }
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\Pictures\folder' } -MockWith {
        [PSCustomObject]@{ FullName = 'C:\Pictures\folder' }
      }
    }
    Context 'ParameterSetName' {
      It 'returns true for picture files by Path with wildcards' {
        Test-PictureExtension -Path 'C:\Pictures\*' | Should -BeTrue
      }
      It 'returns true by Path with ValueFromPipeline' {
        'C:\Pictures\*' | Test-PictureExtension | Should -BeTrue
      }
      It 'returns true by Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = 'C:\Pictures\*' } | Test-PictureExtension | Should -BeTrue
      }
      It 'returns true by LiteralPath' {
        Test-PictureExtension -LiteralPath 'C:\Pictures\photo.jpg' | Should -BeTrue
      }
      It 'returns true by LiteralPath with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ LiteralPath = 'C:\Pictures\photo.jpg' } | Test-PictureExtension | Should -BeTrue
      }
    }
    Context 'Other parameters' {
      It 'returns false when none of the files are pictures' {
        Test-PictureExtension -LiteralPath 'C:\Pictures\notes.txt' | Should -BeFalse
      }
      It 'matches picture extensions case-insensitively' {
        Test-PictureExtension -LiteralPath 'C:\Pictures\photo.JPG' | Should -BeTrue
      }
    }
    Context 'Edge cases' {
      It 'returns false for non-leaf items' {
        Test-PictureExtension -LiteralPath 'C:\Pictures\folder' | Should -BeFalse
      }
      It 'returns false when Get-Item throws ItemNotFoundException' {
        Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\Pictures\missing.*' } -MockWith {
          throw [ItemNotFoundException]::new('Not found')
        }
        Test-PictureExtension -Path 'C:\Pictures\missing.*' | Should -BeFalse
      }
    }
  }
}
