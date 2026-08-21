[CmdletBinding()]
param ()

Import-Module -Name ($PSScriptRoot | Join-Path -ChildPath '..\Automation.Desktop.psm1') -Force
Set-StrictMode -Version Latest

InModuleScope 'Item' {
  Describe 'Get-DuplicateFile' {
    BeforeAll {
      Mock -CommandName Test-Path -MockWith { $true }
      Mock -CommandName Get-FileHash -MockWith { [PSCustomObject]@{ Hash = 'duplicate-hash' } }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\*' } -MockWith {
        [PSCustomObject]@{
          FullName      = 'C:\dir'
          PSIsContainer = $true
        }
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\dir' -or $PSPath -eq 'C:\dir' } -MockWith {
        [PSCustomObject]@{
          FullName      = 'C:\dir'
          PSIsContainer = $true
        }
      }
      Mock -CommandName Get-ChildItem -ParameterFilter { $Directory } -MockWith {
        [PSCustomObject]@{
          FullName      = 'C:\dir\emptydir'
          PSIsContainer = $true
        }
      }
      Mock -CommandName Get-ChildItem -ParameterFilter { $File } -MockWith {
        [PSCustomObject]@{
          Path          = 'C:\dir\file1.txt'
          Extension     = '.txt'
          Length        = 100
          CreationTime  = [datetime]'2025-01-01'
          LastWriteTime = [datetime]'2025-01-03'
        }
        [PSCustomObject]@{
          Path          = 'C:\dir\file2.txt'
          Extension     = '.txt'
          Length        = 100
          CreationTime  = [datetime]'2025-01-01'
          LastWriteTime = [datetime]'2025-01-02'
        }
        [PSCustomObject]@{
          Path          = 'C:\dir\file3.log'
          Extension     = '.log'
          Length        = 200
          CreationTime  = [datetime]'2025-01-03'
          LastWriteTime = [datetime]'2025-01-04'
        }
      }
      Mock -CommandName Get-ChildItem -ParameterFilter { $Force -and -not $Directory -and -not $File } -MockWith {
        process {
          if ($_.FullName -eq 'C:\dir\emptydir') {
            return @()
          }
          return [PSCustomObject]@{ Path = 'C:\dir\nonempty.txt' }
        }
      }
    }
    Context 'ParameterSetName' {
      It 'returns duplicate files by Path with wildcard' {
        Get-DuplicateFile -Path 'C:\dir\*' | Should-BeCollection -Count 1
      }
      It 'returns duplicate files by Path with ValueFromPipeline' {
        'C:\dir\*' | Get-DuplicateFile | Should-BeCollection -Count 1
      }
      It 'returns duplicate files by Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = 'C:\dir\*' } | Get-DuplicateFile | Should-BeCollection -Count 1
      }
      It 'returns duplicate files by LiteralPath' {
        Get-DuplicateFile -LiteralPath 'C:\dir' | Should-BeCollection -Count 1
      }
      It 'returns duplicate files by LiteralPath with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ PSPath = 'C:\dir' } | Get-DuplicateFile | Should-BeCollection -Count 1
      }
    }
    Context 'Output' {
      It 'returns the duplicate file Path property' {
        $result = Get-DuplicateFile -Path 'C:\dir\*'

        $result | Should-BeCollection -Count 1
        $result[0].Path | Should-BeString 'C:\dir\file1.txt'
      }
      It 'returns the duplicate file Path property by LiteralPath' {
        $result = Get-DuplicateFile -LiteralPath 'C:\dir'

        $result | Should-BeCollection -Count 1
        $result[0].Path | Should-BeString 'C:\dir\file1.txt'
      }
    }
    Context 'Other parameters' {
      It 'passes Recurse to Get-ChildItem' {
        Get-DuplicateFile -LiteralPath 'C:\dir' -Recurse | Out-Null

        Should-Invoke -CommandName Get-ChildItem -ParameterFilter { $Recurse -eq $true } -Times 1 -Exactly
      }
      It 'sorts duplicates using specified properties and returns skip results' {
        $result = Get-DuplicateFile -LiteralPath 'C:\dir' -Property 'LastWriteTime' -Descending

        $result | Should-BeCollection -Count 1
        $result[0].Path | Should-BeString 'C:\dir\file2.txt'
      }
    }
  }
  Describe 'Get-EmptyDirectory' {
    BeforeAll {
      Mock -CommandName Test-Path -MockWith { $true }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\*' } -MockWith {
        [PSCustomObject]@{
          FullName      = 'C:\dir'
          PSIsContainer = $true
        }
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\dir' -or $PSPath -eq 'C:\dir' } -MockWith {
        [PSCustomObject]@{
          FullName      = 'C:\dir'
          PSIsContainer = $true
        }
      }
      Mock -CommandName Get-ChildItem -ParameterFilter { $Directory } -MockWith {
        [PSCustomObject]@{
          FullName      = 'C:\dir\emptydir'
          PSIsContainer = $true
        }
      }
      Mock -CommandName Get-ChildItem -ParameterFilter { $Force -and -not $Directory -and -not $File }
    }
    Context 'ParameterSetName' {
      It 'returns empty directories by Path with wildcard' {
        Get-EmptyDirectory -Path 'C:\dir\*' | Should-BeCollection -Count 1
      }
      It 'returns empty directories by Path with ValueFromPipeline' {
        'C:\dir\*' | Get-EmptyDirectory | Should-BeCollection -Count 1
      }
      It 'returns empty directories by Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = 'C:\dir\*' } | Get-EmptyDirectory | Should-BeCollection -Count 1
      }
      It 'returns empty directories by LiteralPath' {
        Get-EmptyDirectory -LiteralPath 'C:\dir' | Should-BeCollection -Count 1
      }
      It 'returns empty directories by LiteralPath with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ PSPath = 'C:\dir' } | Get-EmptyDirectory | Should-BeCollection -Count 1
      }
    }
    Context 'Output' {
      It 'returns the empty directory FullName property' {
        $result = Get-EmptyDirectory -Path 'C:\dir\*'

        @($result) | Should-BeCollection -Count 1
        @($result)[0].FullName | Should-BeString 'C:\dir\emptydir'
      }
      It 'returns the empty directory FullName property by LiteralPath' {
        $result = Get-EmptyDirectory -LiteralPath 'C:\dir'

        @($result) | Should-BeCollection -Count 1
        @($result)[0].FullName | Should-BeString 'C:\dir\emptydir'
      }
    }
    Context 'Other parameters' {
      It 'returns empty directories when Recurse is specified' {
        $result = Get-EmptyDirectory -LiteralPath 'C:\dir' -Recurse

        @($result) | Should-BeCollection -Count 1
        @($result)[0].FullName | Should-BeString 'C:\dir\emptydir'
      }
    }
  }
  Describe 'Measure-Directory' {
    BeforeAll {
      Mock -CommandName Test-Path -MockWith { $true }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\*' -and $Force -eq $true } -MockWith {
        [PSCustomObject]@{
          FullName      = 'C:\dir'
          PSIsContainer = $true
        }
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\dir' -and $Force -eq $true } -MockWith {
        [PSCustomObject]@{
          FullName      = 'C:\dir'
          PSIsContainer = $true
        }
      }
      Mock -CommandName Get-ChildItem -MockWith {
        [PSCustomObject]@{
          FullName      = 'C:\dir\file1.txt'
          Path          = 'C:\dir\file1.txt'
          CreationTime  = [datetime]'2025-01-01'
          LastWriteTime = [datetime]'2025-01-02'
          Length        = 100
        }
      }
    }
    Context 'ParameterSetName' {
      It 'returns recent created files by Path' {
        Measure-Directory -Path 'C:\dir\*' -RecentCreatedFiles | Should-NotBeNull
      }
      It 'returns recent created files by Path with ValueFromPipeline' {
        'C:\dir\*' | Measure-Directory -RecentCreatedFiles | Should-NotBeNull
      }
      It 'returns recent created files by Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = 'C:\dir\*' } | Measure-Directory -RecentCreatedFiles | Should-NotBeNull
      }
      It 'returns recent created files by LiteralPath' {
        Measure-Directory -LiteralPath 'C:\dir' -RecentCreatedFiles | Should-NotBeNull
      }
    }
    Context 'Output' {
      It 'returns the recent created files with FullName property' {
        $result = Measure-Directory -Path 'C:\dir\*' -RecentCreatedFiles

        $result.RecentCreatedFiles | Should-BeCollection -Count 1
        $result.RecentCreatedFiles[0].FullName | Should-BeString 'C:\dir\file1.txt'
      }
      It 'returns the recent created files with FullName property by LiteralPath' {
        $result = Measure-Directory -LiteralPath 'C:\dir' -RecentCreatedFiles

        $result.RecentCreatedFiles | Should-BeCollection -Count 1
        $result.RecentCreatedFiles[0].FullName | Should-BeString 'C:\dir\file1.txt'
      }
    }
    Context 'Other parameters' {
      It 'passes Recurse to Get-ChildItem when specified' {
        Measure-Directory -LiteralPath 'C:\dir' -RecentCreatedFiles -Recurse | Out-Null

        Should-Invoke -CommandName Get-ChildItem -ParameterFilter { $Recurse -eq $true -and $File } -Times 1 -Exactly
      }
      It 'passes Depth to Get-ChildItem when specified' {
        Measure-Directory -LiteralPath 'C:\dir' -RecentCreatedFiles -Depth 2 | Out-Null

        Should-Invoke -CommandName Get-ChildItem -ParameterFilter { $Depth -eq 2 -and $File } -Times 1 -Exactly
      }
      It 'returns recent created directories by LiteralPath' {
        Mock -CommandName Get-ChildItem -ParameterFilter { $Directory -and -not $File } -MockWith {
          @(
            [PSCustomObject]@{
              FullName      = 'C:\dir\newer'
              Path          = 'C:\dir\newer'
              Name          = 'newer'
              PSIsContainer = $true
              CreationTime  = [datetime]'2025-01-04'
              LastWriteTime = [datetime]'2025-01-04'
            }
            [PSCustomObject]@{
              FullName      = 'C:\dir\older'
              Path          = 'C:\dir\older'
              Name          = 'older'
              PSIsContainer = $true
              CreationTime  = [datetime]'2025-01-01'
              LastWriteTime = [datetime]'2025-01-02'
            }
          )
        }

        $result = Measure-Directory -LiteralPath 'C:\dir' -RecentCreatedDirectories

        $result.RecentCreatedDirectories | Should-BeCollection -Count 2
        $result.RecentCreatedDirectories[0].FullName | Should-BeString 'C:\dir\newer'
      }
      It 'returns recent modified files limited to the top square root count' {
        Mock -CommandName Get-ChildItem -ParameterFilter { $File } -MockWith {
          @(
            [PSCustomObject]@{
              FullName      = 'C:\dir\file1.txt'
              Path          = 'C:\dir\file1.txt'
              Name          = 'file1.txt'
              PSIsContainer = $false
              CreationTime  = [datetime]'2025-01-01'
              LastWriteTime = [datetime]'2025-01-01'
              Length        = 10
            }
            [PSCustomObject]@{
              FullName      = 'C:\dir\file2.txt'
              Path          = 'C:\dir\file2.txt'
              Name          = 'file2.txt'
              PSIsContainer = $false
              CreationTime  = [datetime]'2025-01-02'
              LastWriteTime = [datetime]'2025-01-04'
              Length        = 20
            }
            [PSCustomObject]@{
              FullName      = 'C:\dir\file3.txt'
              Path          = 'C:\dir\file3.txt'
              Name          = 'file3.txt'
              PSIsContainer = $false
              CreationTime  = [datetime]'2025-01-03'
              LastWriteTime = [datetime]'2025-01-03'
              Length        = 30
            }
            [PSCustomObject]@{
              FullName      = 'C:\dir\file4.txt'
              Path          = 'C:\dir\file4.txt'
              Name          = 'file4.txt'
              PSIsContainer = $false
              CreationTime  = [datetime]'2025-01-04'
              LastWriteTime = [datetime]'2025-01-02'
              Length        = 40
            }
          )
        }

        $result = Measure-Directory -LiteralPath 'C:\dir' -RecentModifiedFiles

        $result.RecentModifiedFiles | Should-BeCollection -Count 2
        $result.RecentModifiedFiles[0].FullName | Should-BeString 'C:\dir\file2.txt'
        $result.RecentModifiedFiles[1].FullName | Should-BeString 'C:\dir\file3.txt'
      }
      It 'returns large directories with calculated total sizes' {
        Mock -CommandName Get-ChildItem -ParameterFilter { $Directory -and -not $File } -MockWith {
          @(
            [PSCustomObject]@{
              FullName      = 'C:\dir\gamma'
              Path          = 'C:\dir\gamma'
              Name          = 'gamma'
              PSIsContainer = $true
              CreationTime  = [datetime]'2025-01-03'
              LastWriteTime = [datetime]'2025-01-03'
            }
            [PSCustomObject]@{
              FullName      = 'C:\dir\delta'
              Path          = 'C:\dir\delta'
              Name          = 'delta'
              PSIsContainer = $true
              CreationTime  = [datetime]'2025-01-04'
              LastWriteTime = [datetime]'2025-01-04'
            }
            [PSCustomObject]@{
              FullName      = 'C:\dir\beta'
              Path          = 'C:\dir\beta'
              Name          = 'beta'
              PSIsContainer = $true
              CreationTime  = [datetime]'2025-01-02'
              LastWriteTime = [datetime]'2025-01-02'
            }
            [PSCustomObject]@{
              FullName      = 'C:\dir\alpha'
              Path          = 'C:\dir\alpha'
              Name          = 'alpha'
              PSIsContainer = $true
              CreationTime  = [datetime]'2025-01-01'
              LastWriteTime = [datetime]'2025-01-01'
            }
          )
        }
        Mock -CommandName Get-ChildItem -ParameterFilter { $File -and $Recurse } -MockWith {
          process {
            if ($null -eq $_ -or -not ($_.PSObject.Properties.Name -contains 'FullName')) {
              return
            }
            switch ($_.FullName) {
              'C:\dir\alpha' {
                [PSCustomObject]@{ Length = 5 }
                [PSCustomObject]@{ Length = 5 }
              }
              'C:\dir\beta' {
                [PSCustomObject]@{ Length = 10 }
                [PSCustomObject]@{ Length = 10 }
              }
              'C:\dir\gamma' {
                [PSCustomObject]@{ Length = 40 }
              }
              'C:\dir\delta' {
                [PSCustomObject]@{ Length = 15 }
                [PSCustomObject]@{ Length = 15 }
              }
            }
          }
        }

        $result = Measure-Directory -LiteralPath 'C:\dir' -LargeDirectories

        $result.LargeDirectories | Should-BeCollection -Count 2
        $result.LargeDirectories[0].FullName | Should-BeString 'C:\dir\gamma'
        $result.LargeDirectories[1].FullName | Should-BeString 'C:\dir\delta'
        $result.LargeDirectories[0].PSObject.Properties.Name | Should-ContainCollection 'TotalSize'
        $result.LargeDirectories[1].PSObject.Properties.Name | Should-ContainCollection 'TotalSize'
      }
      It 'returns long names sorted by descending length' {
        Mock -CommandName Get-ChildItem -ParameterFilter { -not $File -and -not $Directory } -MockWith {
          @(
            [PSCustomObject]@{
              FullName      = 'C:\dir\a.txt'
              Path          = 'C:\dir\a.txt'
              Name          = 'a.txt'
              PSIsContainer = $false
            }
            [PSCustomObject]@{
              FullName      = 'C:\dir\medium-name.txt'
              Path          = 'C:\dir\medium-name.txt'
              Name          = 'medium-name.txt'
              PSIsContainer = $false
            }
            [PSCustomObject]@{
              FullName      = 'C:\dir\very-very-long-name.txt'
              Path          = 'C:\dir\very-very-long-name.txt'
              Name          = 'very-very-long-name.txt'
              PSIsContainer = $false
            }
            [PSCustomObject]@{
              FullName      = 'C:\dir\name'
              Path          = 'C:\dir\name'
              Name          = 'name'
              PSIsContainer = $true
            }
          )
        }

        $result = Measure-Directory -LiteralPath 'C:\dir' -LongNames

        $result.LongNames | Should-BeCollection -Count 2
        $result.LongNames[0].Name | Should-BeString 'very-very-long-name.txt'
        $result.LongNames[1].Name | Should-BeString 'medium-name.txt'
      }
      It 'returns similar directory pairs' {
        Mock -CommandName Get-ChildItem -ParameterFilter { $Directory -and -not $Recurse } -MockWith {
          @(
            [PSCustomObject]@{
              FullName      = 'C:\dir\report-2024'
              Path          = 'C:\dir\report-2024'
              Name          = 'report-2024'
              PSIsContainer = $true
              CreationTime  = [datetime]'2025-01-01'
              LastWriteTime = [datetime]'2025-01-02'
            }
            [PSCustomObject]@{
              FullName      = 'C:\dir\report-2025'
              Path          = 'C:\dir\report-2025'
              Name          = 'report-2025'
              PSIsContainer = $true
              CreationTime  = [datetime]'2025-01-03'
              LastWriteTime = [datetime]'2025-01-04'
            }
          )
        }

        $result = Measure-Directory -LiteralPath 'C:\dir' -SimilarNames

        $result.SimilarNames | Should-BeCollection -Count 1
        $result.SimilarNames[0].OlderItem.Name | Should-BeString 'report-2024'
        $result.SimilarNames[0].NewerItem.Name | Should-BeString 'report-2025'
      }
    }
    Context 'Edge cases' {
      It 'returns an empty result when no files are found' {
        Mock -CommandName Get-ChildItem -ParameterFilter { $File }

        $result = Measure-Directory -LiteralPath 'C:\dir' -RecentCreatedFiles

        $result.RecentCreatedFiles | Should-BeNull
      }
      It 'returns no similar names when fewer than two directories are found' {
        Mock -CommandName Get-ChildItem -ParameterFilter { $Directory -and -not $Recurse } -MockWith {
          [PSCustomObject]@{
            FullName      = 'C:\dir\only-one'
            Path          = 'C:\dir\only-one'
            Name          = 'only-one'
            PSIsContainer = $true
            CreationTime  = [datetime]'2025-01-01'
            LastWriteTime = [datetime]'2025-01-02'
          }
        }
        $result = Measure-Directory -LiteralPath 'C:\dir' -SimilarNames
        $result | Should-BeNull
      }
    }
  }
  Describe 'Set-ItemAttribute' {
    BeforeAll {
      Mock -CommandName Test-Path -MockWith { $true }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\*.txt' -and $Force -eq $true } -MockWith {
        [PSCustomObject]@{
          FullName      = 'C:\dir\file1.txt'
          PSIsContainer = $false
          Attributes    = [FileAttributes]::Normal
        }
        [PSCustomObject]@{
          FullName      = 'C:\dir\file2.txt'
          PSIsContainer = $false
          Attributes    = [FileAttributes]::Normal
        }
      }
      Mock -CommandName Get-Item -ParameterFilter { ($LiteralPath -eq 'C:\dir\file.txt' -or $PSPath -eq 'C:\dir\file.txt') -and $Force -eq $true } -MockWith {
        [PSCustomObject]@{
          FullName      = 'C:\dir\file.txt'
          PSIsContainer = $false
          Attributes    = [FileAttributes]::Normal
        }
      }
    }
    Context 'ParameterSetName' {
      It 'sets the attribute by Path with wildcard' {
        $item1 = [PSCustomObject]@{
          FullName      = 'C:\dir\file1.txt'
          PSIsContainer = $false
          Attributes    = [FileAttributes]::Normal
        }
        $item2 = [PSCustomObject]@{
          FullName      = 'C:\dir\file2.txt'
          PSIsContainer = $false
          Attributes    = [FileAttributes]::Normal
        }
        Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\*.txt' -and $Force -eq $true } -MockWith { @($item1, $item2) }

        Set-ItemAttribute -Path 'C:\dir\*.txt' -Attribute ReadOnly

        $item1.Attributes | Should-Be ([FileAttributes]::Normal -bor [FileAttributes]::ReadOnly)
        $item2.Attributes | Should-Be ([FileAttributes]::Normal -bor [FileAttributes]::ReadOnly)
        Should-Invoke -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\*.txt' -and $Force -eq $true } -Times 1 -Exactly
      }
      It 'sets the attribute by Path with ValueFromPipeline' {
        'C:\dir\*.txt' | Set-ItemAttribute -Attribute ReadOnly

        Should-Invoke -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\*.txt' -and $Force -eq $true } -Times 1 -Exactly
      }
      It 'sets the attribute by Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = 'C:\dir\*.txt' } | Set-ItemAttribute -Attribute ReadOnly

        Should-Invoke -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\*.txt' -and $Force -eq $true } -Times 1 -Exactly
      }
      It 'sets the attribute by LiteralPath' {
        $item = [PSCustomObject]@{
          FullName      = 'C:\dir\file.txt'
          PSIsContainer = $false
          Attributes    = [FileAttributes]::Normal
        }
        Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\dir\file.txt' -and $Force -eq $true } -MockWith { return $item }

        Set-ItemAttribute -LiteralPath 'C:\dir\file.txt' -Attribute ReadOnly

        $item.Attributes | Should-Be ([FileAttributes]::Normal -bor [FileAttributes]::ReadOnly)
      }
      It 'sets the attribute by LiteralPath with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ PSPath = 'C:\dir\file.txt' } | Set-ItemAttribute -Attribute ReadOnly

        Should-Invoke -CommandName Get-Item -ParameterFilter { $PSPath -eq 'C:\dir\file.txt' -and $Force -eq $true } -Times 1 -Exactly
      }
    }
    Context 'SupportsShouldProcess' {
      It 'does not change attributes when WhatIf is supplied' {
        $item = [PSCustomObject]@{
          FullName      = 'C:\dir\file.txt'
          PSIsContainer = $false
          Attributes    = [FileAttributes]::Normal
        }
        Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\file.txt' -and $Force -eq $true } -MockWith { $item }

        Set-ItemAttribute -Path 'C:\dir\file.txt' -Attribute ReadOnly -Force -WhatIf

        $item.Attributes | Should-Be ([FileAttributes]::Normal)
      }
      It 'suppresses ShouldProcess when Force is supplied with Confirm' {
        $item = [PSCustomObject]@{
          FullName      = 'C:\dir\file.txt'
          PSIsContainer = $false
          Attributes    = [FileAttributes]::Normal
        }
        Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\file.txt' -and $Force -eq $true } -MockWith { $item }

        Set-ItemAttribute -Path 'C:\dir\file.txt' -Attribute ReadOnly -Force -Confirm

        $item.Attributes | Should-Be ([FileAttributes]::Normal -bor [FileAttributes]::ReadOnly)
      }
    }
    Context 'Other parameters' {
      It 'calls Get-Item with Path when using Path parameter set' {
        $item = [PSCustomObject]@{
          FullName      = 'C:\dir\file.txt'
          PSIsContainer = $false
          Attributes    = [FileAttributes]::Normal
        }
        Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\file.txt' -and $Force -eq $true } -MockWith { $item }
        Set-ItemAttribute -Path 'C:\dir\file.txt' -Attribute ReadOnly
        Should-Invoke -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\file.txt' -and $Force -eq $true } -Times 1 -Exactly
      }
      It 'calls Get-Item with LiteralPath when using LiteralPath parameter set' {
        $item = [PSCustomObject]@{
          FullName      = 'C:\dir\file.txt'
          PSIsContainer = $false
          Attributes    = [FileAttributes]::Normal
        }
        Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\dir\file.txt' -and $Force -eq $true } -MockWith { $item }
        Set-ItemAttribute -LiteralPath 'C:\dir\file.txt' -Attribute ReadOnly
        Should-Invoke -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\dir\file.txt' -and $Force -eq $true } -Times 1 -Exactly
      }
    }
    Context 'Edge cases' {
      It 'skips applying the attribute when it is already present without Force' {
        $item = [PSCustomObject]@{
          FullName      = 'C:\dir\file.txt'
          PSIsContainer = $false
          Attributes    = [FileAttributes]::ReadOnly
        }
        Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\file.txt' -and $Force -eq $true } -MockWith { $item }
        Set-ItemAttribute -Path 'C:\dir\file.txt' -Attribute ReadOnly
        $item.Attributes | Should-Be ([FileAttributes]::ReadOnly)
      }
    }
  }
  Describe 'Remove-ItemAttribute' {
    BeforeAll {
      Mock -CommandName Test-Path -MockWith { $true }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\file.txt' -and $Force -eq $true } -MockWith {
        [PSCustomObject]@{
          FullName      = 'C:\dir\file.txt'
          PSIsContainer = $false
          Attributes    = [FileAttributes]::ReadOnly -bor [FileAttributes]::Archive
        }
      }
      Mock -CommandName Get-Item -ParameterFilter { ($LiteralPath -eq 'C:\dir\file.txt' -or $PSPath -eq 'C:\dir\file.txt') -and $Force -eq $true } -MockWith {
        [PSCustomObject]@{
          FullName      = 'C:\dir\file.txt'
          PSIsContainer = $false
          Attributes    = [FileAttributes]::ReadOnly -bor [FileAttributes]::Archive
        }
      }
    }
    Context 'ParameterSetName' {
      It 'removes the attribute by Path' {
        $item = [PSCustomObject]@{
          FullName      = 'C:\dir\file.txt'
          PSIsContainer = $false
          Attributes    = [FileAttributes]::ReadOnly -bor [FileAttributes]::Archive
        }
        Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\file.txt' -and $Force -eq $true } -MockWith { $item }

        Remove-ItemAttribute -Path 'C:\dir\file.txt' -Attribute ReadOnly

        $item.Attributes | Should-Be ([FileAttributes]::Archive)
      }
      It 'removes the attribute by Path with ValueFromPipeline' {
        'C:\dir\file.txt' | Remove-ItemAttribute -Attribute ReadOnly

        Should-Invoke -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\file.txt' -and $Force -eq $true } -Times 1 -Exactly
      }
      It 'removes the attribute by Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = 'C:\dir\file.txt' } | Remove-ItemAttribute -Attribute ReadOnly

        Should-Invoke -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\file.txt' -and $Force -eq $true } -Times 1 -Exactly
      }
      It 'removes the attribute by LiteralPath' {
        $item = [PSCustomObject]@{
          FullName      = 'C:\dir\file.txt'
          PSIsContainer = $false
          Attributes    = [FileAttributes]::ReadOnly -bor [FileAttributes]::Archive
        }

        Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\dir\file.txt' -and $Force -eq $true } -MockWith { $item }

        Remove-ItemAttribute -LiteralPath 'C:\dir\file.txt' -Attribute ReadOnly
        $item.Attributes | Should-Be ([FileAttributes]::Archive)
      }
      It 'removes the attribute by LiteralPath with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ PSPath = 'C:\dir\file.txt' } | Remove-ItemAttribute -Attribute ReadOnly

        Should-Invoke -CommandName Get-Item -ParameterFilter { $PSPath -eq 'C:\dir\file.txt' -and $Force -eq $true } -Times 1 -Exactly
      }
    }
    Context 'SupportsShouldProcess' {
      It 'does not change attributes when WhatIf is supplied' {
        $item = [PSCustomObject]@{
          FullName      = 'C:\dir\file.txt'
          PSIsContainer = $false
          Attributes    = [FileAttributes]::ReadOnly -bor [FileAttributes]::Archive
        }
        Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\file.txt' -and $Force -eq $true } -MockWith { $item }

        Remove-ItemAttribute -Path 'C:\dir\file.txt' -Attribute ReadOnly -Force -WhatIf | Out-Null

        $item.Attributes | Should-Be ([FileAttributes]::ReadOnly -bor [FileAttributes]::Archive)
      }
      It 'suppresses ShouldProcess when Force is supplied with Confirm' {
        $item = [PSCustomObject]@{
          FullName      = 'C:\dir\file.txt'
          PSIsContainer = $false
          Attributes    = [FileAttributes]::ReadOnly -bor [FileAttributes]::Archive
        }
        Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\file.txt' -and $Force -eq $true } -MockWith { $item }

        Remove-ItemAttribute -Path 'C:\dir\file.txt' -Attribute ReadOnly -Force -Confirm

        $item.Attributes | Should-Be ([FileAttributes]::Archive)
      }
    }
    Context 'Other parameters' {
      It 'calls Get-Item with Path when using Path parameter set' {
        $item = [PSCustomObject]@{
          FullName      = 'C:\dir\file.txt'
          PSIsContainer = $false
          Attributes    = [FileAttributes]::ReadOnly -bor [FileAttributes]::Archive
        }
        Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\file.txt' -and $Force -eq $true } -MockWith { $item }

        Remove-ItemAttribute -Path 'C:\dir\file.txt' -Attribute ReadOnly

        Should-Invoke -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\file.txt' -and $Force -eq $true } -Times 1 -Exactly
      }
      It 'calls Get-Item with LiteralPath when using LiteralPath parameter set' {
        $item = [PSCustomObject]@{
          FullName      = 'C:\dir\file.txt'
          PSIsContainer = $false
          Attributes    = [FileAttributes]::ReadOnly -bor [FileAttributes]::Archive
        }
        Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\dir\file.txt' -and $Force -eq $true } -MockWith { $item }

        Remove-ItemAttribute -LiteralPath 'C:\dir\file.txt' -Attribute ReadOnly

        Should-Invoke -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\dir\file.txt' -and $Force -eq $true } -Times 1 -Exactly
      }
    }
    Context 'Edge cases' {
      It 'skips removal when the attribute is not present without Force' {
        $item = [PSCustomObject]@{
          FullName      = 'C:\dir\file.txt'
          PSIsContainer = $false
          Attributes    = [FileAttributes]::Archive
        }
        Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\file.txt' -and $Force -eq $true } -MockWith { $item }

        Remove-ItemAttribute -Path 'C:\dir\file.txt' -Attribute ReadOnly

        $item.Attributes | Should-Be ([FileAttributes]::Archive)
      }
      It 'removes the attribute when Force is supplied even if it is missing' {
        $item = [PSCustomObject]@{
          FullName      = 'C:\dir\file.txt'
          PSIsContainer = $false
          Attributes    = [FileAttributes]::Archive
        }
        Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\file.txt' -and $Force -eq $true } -MockWith { $item }

        Remove-ItemAttribute -Path 'C:\dir\file.txt' -Attribute ReadOnly -Force

        $item.Attributes | Should-Be ([FileAttributes]::Archive)
      }
    }
  }
  Describe 'Set-ItemDate' {
    BeforeAll {
      Mock -CommandName Set-ItemProperty
      Mock -CommandName Get-ItemPropertyValue -ParameterFilter { $Name -eq 'CreationTime' } -MockWith { [datetime]'2025-01-01' }
      Mock -CommandName Get-ItemPropertyValue -ParameterFilter { $Name -eq 'LastWriteTime' } -MockWith { [datetime]'2025-01-02' }
      Mock -CommandName Get-ItemPropertyValue -ParameterFilter { $Name -eq 'LastAccessTime' } -MockWith { [datetime]'2025-01-03' }
      Mock -CommandName Test-Path -MockWith { $true }
      Mock -CommandName Get-ExifDate -MockWith {
        [PSCustomObject]@{
          Path          = 'C:\file.txt'
          CreationTime  = [datetime]'2025-01-01'
          LastWriteTime = [datetime]'2025-01-02'
        }
      }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\*.txt' } -MockWith {
        [PSCustomObject]@{
          Name          = 'file1.txt'
          Path          = 'C:\file1.txt'
          PSIsContainer = $false
        }
        [PSCustomObject]@{
          Name          = 'file2.txt'
          Path          = 'C:\file2.txt'
          PSIsContainer = $false
        }
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\file.txt' -or $PSPath -eq 'C:\file.txt' } -MockWith {
        [PSCustomObject]@{
          Name          = 'file.txt'
          Path          = 'C:\file.txt'
          PSIsContainer = $false
        }
      }
    }
    Context 'ParameterSetName' {
      It 'sets all timestamps by Path' {
        Set-ItemDate -Path 'C:\*.txt' -Date ([datetime]'2025-01-01')

        Should-Invoke -CommandName Set-ItemProperty -Times 6 -Exactly
      }
      It 'sets all timestamps by Path with ValueFromPipeline' {
        'C:\*.txt' | Set-ItemDate -Date ([datetime]'2025-01-01')

        Should-Invoke -CommandName Set-ItemProperty -Times 6 -Exactly
      }
      It 'sets all timestamps by Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = 'C:\*.txt' } | Set-ItemDate -Date ([datetime]'2025-01-01')

        Should-Invoke -CommandName Set-ItemProperty -Times 6 -Exactly
      }
      It 'sets all timestamps by LiteralPath' {
        Set-ItemDate -LiteralPath 'C:\file.txt' -Date ([datetime]'2025-01-01')

        Should-Invoke -CommandName Set-ItemProperty -Times 3 -Exactly
      }
      It 'sets all timestamps by LiteralPath with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ PSPath = 'C:\file.txt' } | Set-ItemDate -Date ([datetime]'2025-01-01')

        Should-Invoke -CommandName Set-ItemProperty -Times 3 -Exactly
      }
      It 'sets individual timestamps by Path' {
        Set-ItemDate -Path 'C:\*.txt' -CreationTime ([datetime]'2025-01-01') -LastWriteTime ([datetime]'2025-01-02') -LastAccessTime ([datetime]'2025-01-03')

        Should-Invoke -CommandName Set-ItemProperty -Times 6 -Exactly
      }
      It 'sets individual timestamps by LiteralPath' {
        Set-ItemDate -LiteralPath 'C:\file.txt' -CreationTime ([datetime]'2025-01-01') -LastWriteTime ([datetime]'2025-01-02') -LastAccessTime ([datetime]'2025-01-03')

        Should-Invoke -CommandName Set-ItemProperty -Times 3 -Exactly
      }
      It 'sets timestamps from EXIF data by Path' {
        Set-ItemDate -Path 'C:\*.txt' -UseExif

        Should-Invoke -CommandName Set-ItemProperty -Times 4 -Exactly
      }
      It 'sets timestamps from EXIF data by LiteralPath' {
        Set-ItemDate -LiteralPath 'C:\file.txt' -UseExif

        Should-Invoke -CommandName Set-ItemProperty -Times 2 -Exactly
      }
    }
    Context 'SupportsShouldProcess' {
      It 'does not set properties when WhatIf specified' {
        Set-ItemDate -LiteralPath 'C:\file.txt' -Date ([datetime]'2025-01-01') -Force -WhatIf

        Should-Invoke -CommandName Set-ItemProperty -Times 0 -Exactly
      }
      It 'suppresses ShouldProcess when Force is supplied with Confirm' {
        Set-ItemDate -LiteralPath 'C:\file.txt' -Date ([datetime]'2025-01-01') -Force -Confirm

        Should-Invoke -CommandName Set-ItemProperty -ParameterFilter { $Force -eq $true } -Times 3 -Exactly
      }
    }
    Context 'Other parameters' {
      It 'fixes CreationTime if greater than LastWriteTime' {
        Set-ItemDate -LiteralPath 'C:\file.txt' -CreationTime ([datetime]'2025-01-03') -LastWriteTime ([datetime]'2025-01-02') -TimeFix

        Should-Invoke -CommandName Set-ItemProperty -Times 3 -Exactly
      }
      It 'sets read-only files when Force is specified' {
        Set-ItemDate -LiteralPath 'C:\file.txt' -Date ([datetime]'2025-01-01')

        Should-Invoke -CommandName Set-ItemProperty -ParameterFilter { $Force -eq $true } -Times 0 -Exactly

        Set-ItemDate -LiteralPath 'C:\file.txt' -Date ([datetime]'2025-01-01') -Force

        Should-Invoke -CommandName Set-ItemProperty -ParameterFilter { $Force -eq $true } -Times 3 -Exactly
      }
    }
    Context 'Edge cases' {
    }
  }
  Describe 'Sync-DirectoryDate' {
    BeforeAll {
      Mock -CommandName Set-ItemDate
      Mock -CommandName Test-Path -MockWith { $true }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\*' } -MockWith {
        [PSCustomObject]@{
          Path          = 'C:\dir\sub1'
          PSIsContainer = $true
        }
        [PSCustomObject]@{
          Path          = 'C:\dir\sub2'
          PSIsContainer = $true
        }
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\dir' -or $PSPath -eq 'C:\dir' } -MockWith {
        [PSCustomObject]@{
          Path          = 'C:\dir'
          PSIsContainer = $true
        }
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\empty' -or $PSPath -eq 'C:\empty' } -MockWith {
        [PSCustomObject]@{
          Path          = 'C:\empty'
          PSIsContainer = $true
        }
      }
      Mock -CommandName Get-ChildItem -MockWith {
        $target = $LiteralPath ?? $Path
        if ($target -in @(
            'C:\dir'
            'C:\dir\sub1'
            'C:\dir\sub2'
          ) -and $File -and $Recurse) {
          [PSCustomObject]@{
            Path           = "$target\file1.txt"
            CreationTime   = [datetime]'2025-01-01'
            LastWriteTime  = [datetime]'2025-01-03'
            LastAccessTime = [datetime]'2025-01-04'
          }
        }
      }
    }
    Context 'ParameterSetName' {
      It 'synchronizes directory timestamps by Path with wildcard' {
        Sync-DirectoryDate -Path 'C:\dir\*'

        Should-Invoke -CommandName Set-ItemDate -ParameterFilter {
          $Path -eq 'C:\dir\sub1' -and
          $CreationTime -eq [datetime]'2025-01-01' -and
          $LastWriteTime -eq [datetime]'2025-01-03' -and
          $LastAccessTime -eq [datetime]'2025-01-04' -and
          $TimeFix -eq $true -and
          $Force -eq $false
        } -Exactly 1
        Should-Invoke -CommandName Set-ItemDate -ParameterFilter {
          $Path -eq 'C:\dir\sub2' -and
          $CreationTime -eq [datetime]'2025-01-01' -and
          $LastWriteTime -eq [datetime]'2025-01-03' -and
          $LastAccessTime -eq [datetime]'2025-01-04' -and
          $TimeFix -eq $true -and
          $Force -eq $false
        } -Exactly 1
      }
      It 'synchronizes directory timestamps by Path with ValueFromPipeline' {
        'C:\dir\*' | Sync-DirectoryDate

        Should-Invoke -CommandName Set-ItemDate -Times 2 -Exactly
      }
      It 'synchronizes directory timestamps by Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = 'C:\dir\*' } | Sync-DirectoryDate

        Should-Invoke -CommandName Set-ItemDate -Times 2 -Exactly
      }
      It 'synchronizes directory timestamps by LiteralPath' {
        Sync-DirectoryDate -LiteralPath 'C:\dir'

        Should-Invoke -CommandName Set-ItemDate -ParameterFilter {
          $CreationTime -eq [datetime]'2025-01-01' -and
          $LastWriteTime -eq [datetime]'2025-01-03' -and
          $LastAccessTime -eq [datetime]'2025-01-04' -and
          $TimeFix -eq $true -and
          $Force -eq $false
        } -Times 1 -Exactly
      }
      It 'synchronizes directory timestamps by LiteralPath with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ PSPath = 'C:\dir' } | Sync-DirectoryDate

        Should-Invoke -CommandName Set-ItemDate -Times 1 -Exactly
      }
    }
    Context 'SupportsShouldProcess' {
      It 'does not synchronize timestamps when WhatIf is specified' {
        Sync-DirectoryDate -LiteralPath 'C:\dir' -WhatIf

        Should-Invoke -CommandName Set-ItemDate -Times 0 -Exactly
      }
      It 'suppresses ShouldProcess when Force is supplied with Confirm' {
        Sync-DirectoryDate -LiteralPath 'C:\dir' -Force -Confirm

        Should-Invoke -CommandName Set-ItemDate -ParameterFilter { $Force -eq $true } -Times 1 -Exactly
      }
    }
    Context 'Other parameters' {
      It 'passes Force through to child enumeration and Set-ItemDate' {
        Sync-DirectoryDate -LiteralPath 'C:\dir' -Force

        Should-Invoke -CommandName Set-ItemDate -ParameterFilter { $Force -eq $true } -Times 1 -Exactly
        Should-Invoke -CommandName Get-ChildItem -ParameterFilter { $Force -eq $true } -Times 1 -Exactly
      }
    }
    Context 'Edge cases' {
      It 'warns when the directory contains no child files' {
        $warnings = @()
        Sync-DirectoryDate -LiteralPath 'C:\empty' -WarningVariable warnings

        Should-Invoke -CommandName Set-ItemDate -Times 0 -Exactly
        $warnings.Count | Should-Be 1
        $warnings[0].Message | Should-MatchString 'is empty\.'
      }
    }
  }
  Describe 'Sync-ItemDate' {
    BeforeAll {
      Mock -CommandName Sync-ArchivedItemDate
      Mock -CommandName Set-ItemDate
      Mock -CommandName Sync-DirectoryDate
      Mock -CommandName Unblock-File
      Mock -CommandName Unblock-Pdf
      Mock -CommandName Out-Host
      Mock -CommandName Resolve-Path -MockWith { 'file.txt' }
      Mock -CommandName Test-ArchiveExtension -MockWith { $false }
      Mock -CommandName Test-Path -MockWith { $true }
      Mock -CommandName Test-PdfExtension -MockWith { $false }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\*' -and $Force -eq $true } -MockWith {
        [PSCustomObject]@{
          Path          = 'C:\dir\file.txt'
          FullName      = 'C:\dir\file.txt'
          PSIsContainer = $false
        }
      }
      Mock -CommandName Get-Item -ParameterFilter { ($Path -eq 'C:\dir' -or $LiteralPath -eq 'C:\dir' -or $PSPath -eq 'C:\dir') -and $Force -eq $true } -MockWith {
        [PSCustomObject]@{
          Path          = 'C:\dir'
          FullName      = 'C:\dir'
          PSIsContainer = $true
        }
      }
      Mock -CommandName Get-Item -ParameterFilter { ($Path -eq 'C:\dir\file.txt' -or $LiteralPath -eq 'C:\dir\file.txt' -or $PSPath -eq 'C:\dir\file.txt') -and $Force -eq $true } -MockWith {
        [PSCustomObject]@{
          Path          = 'C:\dir\file.txt'
          FullName      = 'C:\dir\file.txt'
          PSIsContainer = $false
        }
      }
      Mock -CommandName Get-ChildItem -ParameterFilter { $File -and $Recurse } -MockWith {
        [PSCustomObject]@{
          Path          = 'C:\dir\file.txt'
          FullName      = 'C:\dir\file.txt'
          PSIsContainer = $false
        }
      }
      Mock -CommandName Get-ChildItem -ParameterFilter { $Directory -and $Recurse } -MockWith {
        [PSCustomObject]@{
          Path          = 'C:\dir\subdir'
          FullName      = 'C:\dir\subdir'
          PSIsContainer = $true
        }
      }
      Mock -CommandName Get-ExifDate -MockWith {
        [PSCustomObject]@{
          Path          = 'C:\dir\file.txt'
          CreationTime  = [datetime]'2025-01-01'
          LastWriteTime = [datetime]'2025-01-02'
        }
      }
    }
    Context 'ParameterSetName' {
      It 'processes items by Path with wildcard' {
        Sync-ItemDate -Path 'C:\dir\*' -Force | Out-Null

        Should-Invoke -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\*' } -Times 1 -Exactly
        Should-Invoke -CommandName Set-ItemDate -ParameterFilter { $TimeFix -eq $true } -Times 2 -Exactly
        Should-Invoke -CommandName Sync-DirectoryDate -Times 0 -Exactly
      }
      It 'processes items by Path with ValueFromPipeline' {
        'C:\dir\*' | Sync-ItemDate -Force | Out-Null

        Should-Invoke -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\*' } -Times 1 -Exactly
      }
      It 'processes items by Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = 'C:\dir\*' } | Sync-ItemDate -Force | Out-Null

        Should-Invoke -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\*' } -Times 1 -Exactly
      }
      It 'processes items by LiteralPath' {
        Sync-ItemDate -LiteralPath 'C:\dir' -Force | Out-Null

        Should-Invoke -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\dir' } -Times 1 -Exactly
        Should-Invoke -CommandName Set-ItemDate -ParameterFilter { $TimeFix -eq $true } -Times 2 -Exactly
        Should-Invoke -CommandName Sync-DirectoryDate -Times 2 -Exactly
      }
      It 'processes items by LiteralPath with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ PSPath = 'C:\dir' } | Sync-ItemDate -Force | Out-Null

        Should-Invoke -CommandName Get-Item -ParameterFilter { $PSPath -eq 'C:\dir' } -Times 1 -Exactly
      }
    }
    Context 'SupportsShouldProcess' {
      It 'does not process items when WhatIf is specified' {
        Sync-ItemDate -LiteralPath 'C:\dir' -Force -WhatIf

        Should-Invoke -CommandName Set-ItemDate -Times 0 -Exactly
        Should-Invoke -CommandName Sync-DirectoryDate -Times 0 -Exactly
      }
      It 'suppresses ShouldProcess when Force is supplied with Confirm' {
        Sync-ItemDate -LiteralPath 'C:\dir' -Force -Confirm

        Should-Invoke -CommandName Set-ItemDate -Times 2 -Exactly
        Should-Invoke -CommandName Sync-DirectoryDate -Times 2 -Exactly
      }
    }
    Context 'Other parameters' {
      It 'unblocks files and updates timestamps for non-archive items' {
        Sync-ItemDate -LiteralPath 'C:\dir' -Force | Out-Null

        Should-Invoke -CommandName Unblock-File -Times 1 -Exactly
        Should-Invoke -CommandName Set-ItemDate -ParameterFilter { $TimeFix -eq $true } -Times 2 -Exactly
      }
      It 'unblocks PDF files before setting timestamps' {
        Mock -CommandName Test-PdfExtension -MockWith { $true }
        Mock -CommandName Get-ExifDate

        Sync-ItemDate -LiteralPath 'C:\dir\file.txt' -Force | Out-Null

        Should-Invoke -CommandName Unblock-Pdf -Times 1 -Exactly
        Should-Invoke -CommandName Set-ItemDate -ParameterFilter { $TimeFix -eq $true } -Times 1 -Exactly
      }
      It 'uses archive timestamp logic instead of Set-ItemDate for archive files' {
        Mock -CommandName Test-ArchiveExtension -MockWith { $true }
        Mock -CommandName Get-ExifDate

        Sync-ItemDate -LiteralPath 'C:\dir\file.txt' -Force | Out-Null

        Should-Invoke -CommandName Sync-ArchivedItemDate -Times 1 -Exactly
        Should-Invoke -CommandName Set-ItemDate -ParameterFilter { $TimeFix -eq $true } -Times 0 -Exactly
      }
      It 'writes EXIF updates as relative paths for directory roots' {
        Mock -CommandName Resolve-Path -MockWith { '.\\file.txt' }

        Sync-ItemDate -LiteralPath 'C:\dir' -Force | Out-Null

        Should-Invoke -CommandName Resolve-Path -Times 1 -Exactly
        Should-Invoke -CommandName Out-Host -Times 1 -Exactly
      }
      It 'writes EXIF updates as full paths for file roots' {
        Mock -CommandName Test-Path -ParameterFilter { $LiteralPath -eq 'C:\dir\file.txt' -and $PathType -eq 'Container' } -MockWith { $false }

        Sync-ItemDate -LiteralPath 'C:\dir\file.txt' -Force | Out-Null

        Should-Invoke -CommandName Resolve-Path -Times 0 -Exactly
        Should-Invoke -CommandName Out-Host -Times 1 -Exactly
      }
    }
    Context 'Edge cases' {
      It 'does nothing when no target items are found' {
        Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\missing' }

        Sync-ItemDate -LiteralPath 'C:\missing' -Force | Out-Null

        Should-Invoke -CommandName Set-ItemDate -Times 0 -Exactly
        Should-Invoke -CommandName Sync-DirectoryDate -Times 0 -Exactly
      }
      It 'writes a warning when unblocking a file fails' {
        Mock -CommandName Unblock-File -MockWith { throw 'cannot unblock' }
        Mock -CommandName Get-ExifDate

        $warnings = @()
        Sync-ItemDate -LiteralPath 'C:\dir\file.txt' -Force -WarningVariable warnings | Out-Null

        $warnings.Count | Should-Be 1
        $warnings[0].Message | Should-MatchString 'cannot unblock'
      }
      It 'writes a warning when unblocking a PDF fails' {
        Mock -CommandName Test-PdfExtension -MockWith { $true }
        Mock -CommandName Unblock-Pdf -MockWith { throw 'cannot decrypt' }
        Mock -CommandName Get-ExifDate

        $warnings = @()
        Sync-ItemDate -LiteralPath 'C:\dir\file.txt' -Force -WarningVariable warnings | Out-Null

        $warnings.Count | Should-Be 1
        $warnings[0].Message | Should-MatchString 'cannot decrypt'
      }
      It 'skips EXIF updates when no EXIF dates are present' {
        Mock -CommandName Get-ExifDate -MockWith {
          [PSCustomObject]@{
            Path          = 'C:\dir\file.txt'
            CreationTime  = $null
            LastWriteTime = $null
          }
        }

        Sync-ItemDate -LiteralPath 'C:\dir\file.txt' -Force | Out-Null

        Should-Invoke -CommandName Out-Host -Times 0 -Exactly
        Should-Invoke -CommandName Set-ItemDate -ParameterFilter {
          $PSBoundParameters.ContainsKey('CreationTime') -and $PSBoundParameters.ContainsKey('LastWriteTime')
        } -Times 0 -Exactly
      }
    }
  }
  Describe 'Export-ItemDate' {
    BeforeAll {
      Mock -CommandName Set-Content
      Mock -CommandName Test-Path -MockWith { $PathType -ne 'Container' }
      Mock -CommandName Get-FileHash -MockWith { [PSCustomObject]@{ Hash = 'abc123' } }
      Mock -CommandName Get-Item -MockWith {
        [PSCustomObject]@{
          FullName   = $LiteralPath
          IsReadOnly = $false
        }
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -like 'C:\dir\*.json' -or $PSPath -like 'C:\dir\*.json' } -MockWith {
        [PSCustomObject]@{
          FullName   = 'C:\dir\timestamps.json'
          IsReadOnly = $false
        }
      }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\*' } -MockWith {
        [PSCustomObject]@{
          FullName       = 'C:\dir\file.txt'
          PSIsContainer  = $false
          CreationTime   = [datetime]'2025-01-01'
          LastWriteTime  = [datetime]'2025-01-02'
          LastAccessTime = [datetime]'2025-01-03'
        }
      }
      Mock -CommandName Get-Item -ParameterFilter { ($LiteralPath -eq 'C:\dir\file.txt' -or $PSPath -eq 'C:\dir\file.txt') } -MockWith {
        [PSCustomObject]@{
          FullName       = 'C:\dir\file.txt'
          PSIsContainer  = $false
          CreationTime   = [datetime]'2025-01-01'
          LastWriteTime  = [datetime]'2025-01-02'
          LastAccessTime = [datetime]'2025-01-03'
        }
      }
      Mock -CommandName Get-Item -ParameterFilter { ($LiteralPath -eq 'C:\dir' -or $PSPath -eq 'C:\dir') } -MockWith {
        [PSCustomObject]@{
          FullName      = 'C:\dir'
          Name          = 'dir'
          PSIsContainer = $true
        }
      }
      Mock -CommandName Get-ChildItem -ParameterFilter { $File } -MockWith {
        @(
          [PSCustomObject]@{
            FullName       = 'C:\dir\file.txt'
            PSIsContainer  = $false
            CreationTime   = [datetime]'2025-01-01'
            LastWriteTime  = [datetime]'2025-01-02'
            LastAccessTime = [datetime]'2025-01-03'
          }
          [PSCustomObject]@{
            FullName       = 'C:\dir\sub\photo.jpg'
            PSIsContainer  = $false
            CreationTime   = [datetime]'2025-02-01'
            LastWriteTime  = [datetime]'2025-02-02'
            LastAccessTime = [datetime]'2025-02-03'
          }
        )
      }
    }
    Context 'ParameterSetName' {
      It 'exports timestamps by Path with wildcard' {
        Export-ItemDate -Path 'C:\dir\*' -Destination 'C:\dir\timestamps.json'

        Should-Invoke -CommandName Set-Content -Times 1 -Exactly
      }
      It 'exports timestamps by Path with ValueFromPipeline' {
        'C:\dir\*' | Export-ItemDate -Destination 'C:\dir\timestamps.json'

        Should-Invoke -CommandName Set-Content -Times 1 -Exactly
      }
      It 'exports timestamps by Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = 'C:\dir\*' } | Export-ItemDate -Destination 'C:\dir\timestamps.json'

        Should-Invoke -CommandName Set-Content -Times 1 -Exactly
      }
      It 'exports timestamps by LiteralPath for a file' {
        Export-ItemDate -LiteralPath 'C:\dir\file.txt' -Destination 'C:\dir\timestamps.json'

        Should-Invoke -CommandName Set-Content -Times 1 -Exactly -ParameterFilter {
          $null -ne $Value -and
          ($json = $Value | ConvertFrom-Json) -and
          $json.Path -eq 'file.txt' -and
          $json.CreationTime -eq '2025-01-01T00:00:00' -and
          $json.LastWriteTime -eq '2025-01-02T00:00:00' -and
          $json.LastAccessTime -eq '2025-01-03T00:00:00' -and
          $json.Hash -eq 'abc123'
        }
      }
      It 'exports timestamps by LiteralPath for a directory recursively enumerates all files relative to the parent folder' {
        Export-ItemDate -LiteralPath 'C:\dir' -Destination 'C:\dir\timestamps.json'

        Should-Invoke -CommandName Set-Content -Times 1 -Exactly -ParameterFilter {
          $null -ne $Value -and
          ($json = $Value | ConvertFrom-Json) -and
          ($json -is [array]) -and
          $json.Count -eq 2 -and
          ($json[0].Path -eq 'dir\file.txt' -or $json[0].Path -eq 'dir\sub\photo.jpg') -and
          ($json[1].Path -eq 'dir\file.txt' -or $json[1].Path -eq 'dir\sub\photo.jpg')
        }
      }
      It 'exports timestamps by LiteralPath with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ LiteralPath = 'C:\dir\file.txt' } | Export-ItemDate -Destination 'C:\dir\timestamps.json'

        Should-Invoke -CommandName Set-Content -Times 1 -Exactly
      }
    }
    Context 'SupportsShouldProcess' {
      It 'does not write content when WhatIf is specified' {
        Export-ItemDate -Path 'C:\dir\*' -Destination 'C:\dir\timestamps.json' -Force -WhatIf

        Should-Invoke -CommandName Set-Content -Times 0 -Exactly
      }
      It 'writes content when Force is specified with Confirm' {
        Export-ItemDate -Path 'C:\dir\*' -Destination 'C:\dir\timestamps.json' -Force -Confirm

        Should-Invoke -CommandName Set-Content -Times 1 -Exactly
      }
      It 'fails when NoClobber is specified and destination exists' {
        Mock -CommandName Test-Path -ParameterFilter { $LiteralPath -eq 'C:\dir\timestamps.json' } -MockWith { $true }

        { Export-ItemDate -Path 'C:\dir\*' -Destination 'C:\dir\timestamps.json' -NoClobber } | Should-Throw
      }
    }
    Context 'Other parameters' {
      It 'writes JSON containing the item path relative to the input folder and timestamps' {
        Export-ItemDate -Path 'C:\dir\*' -Destination 'C:\dir\timestamps.json'

        Should-Invoke -CommandName Set-Content -Times 1 -Exactly -ParameterFilter {
          $null -ne $Value -and
          ($json = $Value | ConvertFrom-Json) -and
          $json.Path -eq 'file.txt' -and
          $json.CreationTime -eq '2025-01-01T00:00:00' -and
          $json.LastWriteTime -eq '2025-01-02T00:00:00' -and
          $json.LastAccessTime -eq '2025-01-03T00:00:00' -and
          $json.Hash -eq 'abc123'
        }
      }
    }
    Context 'Edge cases' {
      It 'saves to {folder name}.json in the parent folder of the input when Destination is omitted for a directory' {
        Export-ItemDate -LiteralPath 'C:\dir'

        Should-Invoke -CommandName Set-Content -Times 1 -Exactly -ParameterFilter {
          $LiteralPath -eq (Join-Path -Path 'C:\' -ChildPath 'dir.json')
        }
      }
      It 'saves each directory to its own {folder name}.json in its parent folder when Destination is omitted for multiple directories' {
        Mock -CommandName Get-Item -ParameterFilter { ($LiteralPath -is [array]) -and ($LiteralPath -contains 'C:\dir1') -and ($LiteralPath -contains 'C:\dir2') } -MockWith {
          @(
            [PSCustomObject]@{
              FullName      = 'C:\dir1'
              Name          = 'dir1'
              PSIsContainer = $true
            }
            [PSCustomObject]@{
              FullName      = 'C:\dir2'
              Name          = 'dir2'
              PSIsContainer = $true
            }
          )
        }
        Mock -CommandName Get-ChildItem -ParameterFilter { $File -and ($Path -eq 'C:\dir1' -or $LiteralPath -eq 'C:\dir1' -or $PSPath -eq 'C:\dir1') } -MockWith {
          @(
            [PSCustomObject]@{
              FullName       = 'C:\dir1\a.txt'
              PSIsContainer  = $false
              CreationTime   = [datetime]'2025-01-01'
              LastWriteTime  = [datetime]'2025-01-02'
              LastAccessTime = [datetime]'2025-01-03'
            }
          )
        }
        Mock -CommandName Get-ChildItem -ParameterFilter { $File -and ($Path -eq 'C:\dir2' -or $LiteralPath -eq 'C:\dir2' -or $PSPath -eq 'C:\dir2') } -MockWith {
          @(
            [PSCustomObject]@{
              FullName       = 'C:\dir2\b.txt'
              PSIsContainer  = $false
              CreationTime   = [datetime]'2025-03-01'
              LastWriteTime  = [datetime]'2025-03-02'
              LastAccessTime = [datetime]'2025-03-03'
            }
          )
        }
        Export-ItemDate -LiteralPath 'C:\dir1', 'C:\dir2'

        Should-Invoke -CommandName Set-Content -Times 2 -Exactly
        Should-Invoke -CommandName Set-Content -Times 1 -Exactly -ParameterFilter {
          $LiteralPath -eq (Join-Path -Path 'C:\' -ChildPath 'dir1.json')
        }
        Should-Invoke -CommandName Set-Content -Times 1 -Exactly -ParameterFilter {
          $LiteralPath -eq (Join-Path -Path 'C:\' -ChildPath 'dir2.json')
        }
      }
      It 'throws an error when Destination is omitted for a file' {
        { Export-ItemDate -LiteralPath 'C:\dir\file.txt' } | Should-Throw -Because 'Destination is required for a file input'
      }
      It 'throws an error when Destination is omitted for two files' {
        Mock -CommandName Get-Item -ParameterFilter { ($LiteralPath -is [array]) -and ($LiteralPath -contains 'C:\dir\a.txt') -and ($LiteralPath -contains 'C:\dir\b.txt') } -MockWith {
          @(
            [PSCustomObject]@{
              FullName       = 'C:\dir\a.txt'
              Name           = 'a.txt'
              PSIsContainer  = $false
              CreationTime   = [datetime]'2025-01-01'
              LastWriteTime  = [datetime]'2025-01-02'
              LastAccessTime = [datetime]'2025-01-03'
            }
            [PSCustomObject]@{
              FullName       = 'C:\dir\b.txt'
              Name           = 'b.txt'
              PSIsContainer  = $false
              CreationTime   = [datetime]'2025-03-01'
              LastWriteTime  = [datetime]'2025-03-02'
              LastAccessTime = [datetime]'2025-03-03'
            }
          )
        }

        { Export-ItemDate -LiteralPath 'C:\dir\a.txt', 'C:\dir\b.txt' } | Should-Throw -Because 'Destination is required when the input is a file'
      }
      It 'throws an error when Destination is omitted and the first of two paths is a file' {
        Mock -CommandName Get-Item -ParameterFilter { ($LiteralPath -is [array]) -and ($LiteralPath -contains 'C:\dir\file.txt') -and ($LiteralPath -contains 'C:\dir2') } -MockWith {
          @(
            [PSCustomObject]@{
              FullName       = 'C:\dir\file.txt'
              Name           = 'file.txt'
              PSIsContainer  = $false
              CreationTime   = [datetime]'2025-01-01'
              LastWriteTime  = [datetime]'2025-01-02'
              LastAccessTime = [datetime]'2025-01-03'
            }
            [PSCustomObject]@{
              FullName      = 'C:\dir2'
              Name          = 'dir2'
              PSIsContainer = $true
            }
          )
        }

        { Export-ItemDate -LiteralPath 'C:\dir\file.txt', 'C:\dir2' } | Should-Throw -Because 'Destination is required when the input is a file'
      }
      It 'throws an error when Destination is omitted and any input is a file' {
        Mock -CommandName Get-Item -ParameterFilter { ($LiteralPath -is [array]) -and ($LiteralPath -contains 'C:\dir') -and ($LiteralPath -contains 'C:\dir\file.txt') } -MockWith {
          @(
            [PSCustomObject]@{
              FullName      = 'C:\dir'
              Name          = 'dir'
              PSIsContainer = $true
            }
            [PSCustomObject]@{
              FullName       = 'C:\dir\file.txt'
              Name           = 'file.txt'
              PSIsContainer  = $false
              CreationTime   = [datetime]'2025-01-01'
              LastWriteTime  = [datetime]'2025-01-02'
              LastAccessTime = [datetime]'2025-01-03'
            }
          )
        }

        { Export-ItemDate -LiteralPath 'C:\dir', 'C:\dir\file.txt' } | Should-Throw -Because 'Destination is required when the input is a file'
      }
    }
    Context 'Output' {
      It 'returns a single-element array with the destination file path' {
        $result = Export-ItemDate -Path 'C:\dir\*' -Destination 'C:\dir\timestamps.json'

        $result.Count | Should-Be 1
        $result.FullName | Should-BeString 'C:\dir\timestamps.json'
      }
      It 'writes content to exactly one destination file' {
        Export-ItemDate -Path 'C:\dir\*' -Destination 'C:\dir\timestamps.json'

        Should-Invoke -CommandName Set-Content -Times 1 -Exactly
      }
      It 'does not accept an array of destinations because only one output file is produced' {
        { Export-ItemDate -Path 'C:\dir\*' -Destination @('C:\dir\a.json', 'C:\dir\b.json') } | Should-Throw
      }
      It 'returns one destination path per directory when Destination is omitted for multiple directories' {
        Mock -CommandName Get-Item -ParameterFilter { ($LiteralPath -is [array]) -and ($LiteralPath -contains 'C:\dir1') -and ($LiteralPath -contains 'C:\dir2') } -MockWith {
          @(
            [PSCustomObject]@{
              FullName      = 'C:\dir1'
              Name          = 'dir1'
              PSIsContainer = $true
            }
            [PSCustomObject]@{
              FullName      = 'C:\dir2'
              Name          = 'dir2'
              PSIsContainer = $true
            }
          )
        }
        Mock -CommandName Get-ChildItem -ParameterFilter { $File -and ($Path -eq 'C:\dir1' -or $LiteralPath -eq 'C:\dir1' -or $PSPath -eq 'C:\dir1') } -MockWith {
          @(
            [PSCustomObject]@{
              FullName       = 'C:\dir1\a.txt'
              PSIsContainer  = $false
              CreationTime   = [datetime]'2025-01-01'
              LastWriteTime  = [datetime]'2025-01-02'
              LastAccessTime = [datetime]'2025-01-03'
            }
          )
        }
        Mock -CommandName Get-ChildItem -ParameterFilter { $File -and ($Path -eq 'C:\dir2' -or $LiteralPath -eq 'C:\dir2' -or $PSPath -eq 'C:\dir2') } -MockWith {
          @(
            [PSCustomObject]@{
              FullName       = 'C:\dir2\b.txt'
              PSIsContainer  = $false
              CreationTime   = [datetime]'2025-03-01'
              LastWriteTime  = [datetime]'2025-03-02'
              LastAccessTime = [datetime]'2025-03-03'
            }
          )
        }

        $result = @(Export-ItemDate -LiteralPath 'C:\dir1', 'C:\dir2')

        $result.Count | Should-Be 2
        $result.FullName | Should-ContainCollection (Join-Path -Path 'C:\' -ChildPath 'dir1.json')
        $result.FullName | Should-ContainCollection (Join-Path -Path 'C:\' -ChildPath 'dir2.json')
      }
    }
  }
  Describe 'Import-ItemDate' {
    BeforeAll {
      Mock -CommandName Test-Path -ParameterFilter { $PathType -eq 'Container' } -MockWith { $false }
      Mock -CommandName Test-Path -MockWith { $true }
      Mock -CommandName Get-FileHash -MockWith { [PSCustomObject]@{ Hash = 'abc123' } }
      Mock -CommandName Get-Content -ParameterFilter { $LiteralPath -eq 'C:\dir\timestamps.json' } -MockWith {
        '[{"Path":"C:\\dir\\file.txt","CreationTime":"2025-01-01T00:00:00","LastWriteTime":"2025-01-02T00:00:00","LastAccessTime":"2025-01-03T00:00:00","Hash":"abc123"}]'
      }
      Mock -CommandName Get-Item -MockWith {
        [PSCustomObject]@{
          FullName       = $LiteralPath
          PSIsContainer  = $false
          CreationTime   = [datetime]'2025-01-01'
          LastWriteTime  = [datetime]'2025-01-02'
          LastAccessTime = [datetime]'2025-01-03'
        }
      }
      Mock -CommandName Set-ItemProperty
    }
    Context 'ParameterSetName' {
      It 'imports timestamps by Path' {
        Import-ItemDate -Path 'C:\dir\timestamps.json'

        Should-Invoke -CommandName Set-ItemProperty -Times 3 -Exactly
      }
      It 'imports timestamps by Path with ValueFromPipeline' {
        'C:\dir\timestamps.json' | Import-ItemDate

        Should-Invoke -CommandName Set-ItemProperty -Times 3 -Exactly
      }
      It 'imports timestamps by Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = 'C:\dir\timestamps.json' } | Import-ItemDate

        Should-Invoke -CommandName Set-ItemProperty -Times 3 -Exactly
      }
      It 'imports timestamps by FilePath alias' {
        Import-ItemDate -FilePath 'C:\dir\timestamps.json'

        Should-Invoke -CommandName Set-ItemProperty -Times 3 -Exactly
      }
      It 'imports timestamps by FullName alias' {
        Import-ItemDate -FullName 'C:\dir\timestamps.json'

        Should-Invoke -CommandName Set-ItemProperty -Times 3 -Exactly
      }
    }
    Context 'SupportsShouldProcess' {
      It 'does not set properties when WhatIf is specified' {
        Import-ItemDate -Path 'C:\dir\timestamps.json' -WhatIf

        Should-Invoke -CommandName Set-ItemProperty -Times 0 -Exactly
      }
      It 'sets properties when Force is specified with Confirm' {
        Import-ItemDate -Path 'C:\dir\timestamps.json' -Force -Confirm

        Should-Invoke -CommandName Set-ItemProperty -Times 3 -Exactly
      }
    }
    Context 'Other parameters' {
      It 'sets each timestamp property with the value from JSON' {
        Import-ItemDate -Path 'C:\dir\timestamps.json'

        Should-Invoke -CommandName Set-ItemProperty -Times 1 -Exactly -ParameterFilter { $Name -eq 'CreationTime' -and $Value -eq '2025-01-01T00:00:00' }
        Should-Invoke -CommandName Set-ItemProperty -Times 1 -Exactly -ParameterFilter { $Name -eq 'LastWriteTime' -and $Value -eq '2025-01-02T00:00:00' }
        Should-Invoke -CommandName Set-ItemProperty -Times 1 -Exactly -ParameterFilter { $Name -eq 'LastAccessTime' -and $Value -eq '2025-01-03T00:00:00' }
      }
      It 'resolves a relative Path (including the folder name) against the JSON file folder' {
        Mock -CommandName Get-Content -ParameterFilter { $LiteralPath -eq 'C:\dir\relative.json' } -MockWith {
          '[{"Path":"dir\\file.txt","CreationTime":"2025-01-01T00:00:00","LastWriteTime":"2025-01-02T00:00:00","LastAccessTime":"2025-01-03T00:00:00","Hash":"abc123"}]'
        }

        Import-ItemDate -Path 'C:\dir\relative.json'

        Should-Invoke -CommandName Set-ItemProperty -Times 3 -Exactly -ParameterFilter { $LiteralPath -eq 'C:\dir\dir\file.txt' }
      }
      It 'returns the updated FileInfo object when PassThru is specified' {
        $result = Import-ItemDate -Path 'C:\dir\timestamps.json' -PassThru

        $result | Should-NotBeNull
        $result.FullName | Should-BeString 'C:\dir\file.txt'
        Should-Invoke -CommandName Get-Item -Times 1 -Exactly -ParameterFilter { $LiteralPath -eq 'C:\dir\file.txt' }
      }
      It 'does not return output by default' {
        $result = Import-ItemDate -Path 'C:\dir\timestamps.json'

        $result | Should-BeNull
        Should-Invoke -CommandName Get-Item -Times 0 -Exactly
      }
    }
    Context 'Other parameters' {
      It 'imports timestamps from multiple JSON files passed as an array' {
        Mock -CommandName Get-Content -ParameterFilter { $LiteralPath -eq 'C:\dir\second.json' } -MockWith {
          '[{"Path":"C:\\dir\\file2.txt","CreationTime":"2025-02-01T00:00:00","LastWriteTime":"2025-02-02T00:00:00","LastAccessTime":"2025-02-03T00:00:00","Hash":"abc123"}]'
        }

        Import-ItemDate -Path @('C:\dir\timestamps.json', 'C:\dir\second.json')

        Should-Invoke -CommandName Set-ItemProperty -Times 6 -Exactly
      }
    }
    Context 'Other parameters' {
      It 'skips timestamps when file hash does not match' {
        Mock -CommandName Get-FileHash -MockWith { [PSCustomObject]@{ Hash = 'mismatch' } }

        $warnings = @()
        Import-ItemDate -Path 'C:\dir\timestamps.json' -WarningVariable warnings

        Should-Invoke -CommandName Set-ItemProperty -Times 0 -Exactly
        $warnings.Count | Should-Be 1
        $warnings[0].Message | Should -Match 'file hash does not match'
      }
      It 'skips timestamps when target file does not exist' {
        Mock -CommandName Test-Path -ParameterFilter { $LiteralPath -eq 'C:\dir\file.txt' } -MockWith { $false }

        $warnings = @()
        Import-ItemDate -Path 'C:\dir\timestamps.json' -WarningVariable warnings

        Should-Invoke -CommandName Set-ItemProperty -Times 0 -Exactly
        $warnings.Count | Should-Be 1
        $warnings[0].Message | Should -Match 'does not exist'
      }
      It 'skips timestamps when target is a directory' {
        Mock -CommandName Test-Path -ParameterFilter { $LiteralPath -eq 'C:\dir\file.txt' -and -not $PathType } -MockWith { $true }
        Mock -CommandName Test-Path -ParameterFilter { $LiteralPath -eq 'C:\dir\file.txt' -and $PathType -eq 'Container' } -MockWith { $true }
        Mock -CommandName Test-Path -ParameterFilter { $LiteralPath -eq 'C:\dir\file.txt' -and $PathType -eq 'Leaf' } -MockWith { $false }

        $warnings = @()
        Import-ItemDate -Path 'C:\dir\timestamps.json' -WarningVariable warnings

        Should-Invoke -CommandName Set-ItemProperty -Times 0 -Exactly
        $warnings.Count | Should-Be 1
        $warnings[0].Message | Should -Match 'is not a file'
      }
    }
    Context 'Edge cases' {
      It 'does not set properties when the JSON array is empty' {
        Mock -CommandName Get-Content -ParameterFilter { $LiteralPath -eq 'C:\dir\empty.json' } -MockWith { '[]' }

        Import-ItemDate -Path 'C:\dir\empty.json'

        Should-Invoke -CommandName Set-ItemProperty -Times 0 -Exactly
      }
    }
  }
}
