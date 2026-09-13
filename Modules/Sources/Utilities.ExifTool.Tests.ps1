[CmdletBinding()]
param ()

Import-Module -Name ($PSScriptRoot | Join-Path -ChildPath '..\Automation.Desktop.psm1') -Force
Set-StrictMode -Version Latest

InModuleScope 'Utilities.ExifTool' {
  Describe 'Get-ExifDate' {
    BeforeAll {
      Mock -CommandName Get-Content
      Mock -CommandName Remove-Item
      Mock -CommandName Test-Path -MockWith { $true }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\Photos\*.jpg' } -MockWith {
        [PSCustomObject]@{ FullName = 'C:\Photos\IMG_0001.jpg' }
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\Photos\IMG_0001.jpg' } -MockWith {
        [PSCustomObject]@{ FullName = 'C:\Photos\IMG_0001.jpg' }
      }
      Mock -CommandName Resolve-Path -MockWith {
        [PSCustomObject]@{ Path = 'C:\Photos\IMG_0001.jpg' }
      }
    }
    Context 'ParameterSetName' {
      It 'parses Exif dates from CSV ExifTool output by Path with wildcards' {
        Mock -CommandName ExifTool.exe -MockWith {
          [PSCustomObject]@{
            SourceFile       = 'IMG_0001.jpg'
            DateTimeOriginal = '2025-01-02T03:04:05+09:00'
            CreateDate       = '2025-01-02T03:04:05+09:00'
            ModifyDate       = '2025-01-02T06:07:08+09:00'
          } | ConvertTo-Csv
        }
        Get-ExifDate -Path 'C:\Photos\*.jpg' | Should-BeCollection -Count 1
      }
      It 'parses Exif dates from CSV ExifTool output by Path with ValueFromPipeline' {
        Mock -CommandName ExifTool.exe -MockWith {
          [PSCustomObject]@{
            SourceFile       = 'IMG_0001.jpg'
            DateTimeOriginal = '2025-01-02T03:04:05+09:00'
            CreateDate       = '2025-01-02T03:04:05+09:00'
            ModifyDate       = '2025-01-02T06:07:08+09:00'
          } | ConvertTo-Csv
        }
        'C:\Photos\*.jpg' | Get-ExifDate | Should-BeCollection -Count 1
      }
      It 'parses Exif dates from CSV ExifTool output by Path with ValueFromPipelineByPropertyName' {
        Mock -CommandName ExifTool.exe -MockWith {
          [PSCustomObject]@{
            SourceFile       = 'IMG_0001.jpg'
            DateTimeOriginal = '2025-01-02T03:04:05+09:00'
            CreateDate       = '2025-01-02T03:04:05+09:00'
            ModifyDate       = '2025-01-02T06:07:08+09:00'
          } | ConvertTo-Csv
        }
        [PSCustomObject]@{ Path = 'C:\Photos\*.jpg' } | Get-ExifDate | Should-BeCollection -Count 1
      }
      It 'parses Exif dates from JSON ExifTool output by LiteralPath' {
        Mock -CommandName ExifTool.exe -MockWith {
          [PSCustomObject]@{
            SourceFile       = 'IMG_0001.jpg'
            DateTimeOriginal = '2025-01-02T03:04:05+09:00'
            CreateDate       = '2025-01-02T03:04:05+09:00'
            ModifyDate       = '2025-01-02T06:07:08+09:00'
          } | ConvertTo-Json -Compress
        }
        Mock -CommandName ConvertFrom-Json -MockWith {
          [PSCustomObject]@{
            SourceFile       = 'IMG_0001.jpg'
            DateTimeOriginal = '2025-01-02T03:04:05+09:00'
            CreateDate       = '2025-01-02T03:04:05+09:00'
            ModifyDate       = '2025-01-02T06:07:08+09:00'
          }
        }
        Get-ExifDate -LiteralPath 'C:\Photos\IMG_0001.jpg' -AsJson | Should-BeCollection -Count 1
      }
      It 'parses Exif dates from JSON ExifTool output by LiteralPath with ValueFromPipelineByPropertyName' {
        Mock -CommandName ExifTool.exe -MockWith {
          [PSCustomObject]@{
            SourceFile       = 'IMG_0001.jpg'
            DateTimeOriginal = '2025-01-02T03:04:05+09:00'
            CreateDate       = '2025-01-02T03:04:05+09:00'
            ModifyDate       = '2025-01-02T06:07:08+09:00'
          } | ConvertTo-Json -Compress
        }
        Mock -CommandName ConvertFrom-Json -MockWith {
          [PSCustomObject]@{
            SourceFile       = 'IMG_0001.jpg'
            DateTimeOriginal = '2025-01-02T03:04:05+09:00'
            CreateDate       = '2025-01-02T03:04:05+09:00'
            ModifyDate       = '2025-01-02T06:07:08+09:00'
          }
        }
        [PSCustomObject]@{ LiteralPath = 'C:\Photos\IMG_0001.jpg' } | Get-ExifDate -AsJson | Should-BeCollection -Count 1
      }
    }
    Context 'Output' {
      It 'returns Exif dates with Path and timestamp properties' {
        Mock -CommandName ExifTool.exe -MockWith {
          [PSCustomObject]@{
            SourceFile       = 'IMG_0001.jpg'
            DateTimeOriginal = '2025-01-02T03:04:05+09:00'
            CreateDate       = '2025-01-02T03:04:05+09:00'
            ModifyDate       = '2025-01-02T06:07:08+09:00'
          } | ConvertTo-Csv
        }
        $result = Get-ExifDate -Path 'C:\Photos\*.jpg'
        $result | Should-BeCollection -Count 1
        $result[0].Path | Should-BeString 'C:\Photos\IMG_0001.jpg'
        $result[0].CreationTime | Should-Be ([datetime]'2025-01-02 03:04:05')
        $result[0].LastWriteTime | Should-Be ([datetime]'2025-01-02 06:07:08')
      }
      It 'returns Exif dates with Path property by LiteralPath' {
        Mock -CommandName ExifTool.exe -MockWith {
          [PSCustomObject]@{
            SourceFile       = 'IMG_0001.jpg'
            DateTimeOriginal = '2025-01-02T03:04:05+09:00'
            CreateDate       = '2025-01-02T03:04:05+09:00'
            ModifyDate       = '2025-01-02T06:07:08+09:00'
          } | ConvertTo-Json -Compress
        }
        Mock -CommandName ConvertFrom-Json -MockWith {
          [PSCustomObject]@{
            SourceFile       = 'IMG_0001.jpg'
            DateTimeOriginal = '2025-01-02T03:04:05+09:00'
            CreateDate       = '2025-01-02T03:04:05+09:00'
            ModifyDate       = '2025-01-02T06:07:08+09:00'
          }
        }

        $result = Get-ExifDate -LiteralPath 'C:\Photos\IMG_0001.jpg' -AsJson

        $result | Should-BeCollection -Count 1
        $result[0].Path | Should-BeString 'C:\Photos\IMG_0001.jpg'
      }
    }
    Context 'Other parameters' {
      It 'passes recurse to ExifTool.exe when requested' {
        Mock -CommandName ExifTool.exe -MockWith {
          [PSCustomObject]@{
            SourceFile       = 'IMG_0001.jpg'
            DateTimeOriginal = '2025-01-02T03:04:05+09:00'
            CreateDate       = '2025-01-02T03:04:05+09:00'
            ModifyDate       = '2025-01-02T06:07:08+09:00'
          } | ConvertTo-Csv
        }

        Get-ExifDate -Path 'C:\Photos\*.jpg' -Recurse | Out-Null

        Should-Invoke -CommandName ExifTool.exe -ParameterFilter { $args -contains '-recurse' } -Times 1 -Exactly
      }
    }
    Context 'Edge cases' {
      It 'returns no objects when ExifTool returns no metadata rows' {
        Mock -CommandName ExifTool.exe -MockWith {
          'SourceFile,DateTimeOriginal,CreateDate,ModifyDate'
        }

        $result = Get-ExifDate -Path 'C:\Photos\*.jpg'

        $result | Should-BeNull
      }
    }
  }
  Describe 'Set-ExifDate' {
    BeforeAll {
      Mock -CommandName ExifTool.exe
      Mock -CommandName Sync-ItemDate
      Mock -CommandName Get-Content
      Mock -CommandName Out-File
      Mock -CommandName Remove-Item
      Mock -CommandName Test-Path -MockWith { $true }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\Photos\*.jpg' } -MockWith {
        [PSCustomObject]@{ FullName = 'C:\Photos\IMG_0001.jpg' }
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\Photos\IMG_0001.jpg' } -MockWith {
        [PSCustomObject]@{ FullName = 'C:\Photos\IMG_0001.jpg' }
      }
    }
    Context 'ParameterSetName' {
      It 'calls ExifTool.exe by Path with wildcards' {
        Set-ExifDate -Path 'C:\Photos\*.jpg' -Date ([datetime]'2025-01-02 03:04:05')

        Should-Invoke -CommandName ExifTool.exe -Times 1 -Exactly
        Should-Invoke -CommandName Sync-ItemDate -Times 1 -Exactly
      }
      It 'calls ExifTool.exe by Path with ValueFromPipeline' {
        'C:\Photos\*.jpg' | Set-ExifDate -Date ([datetime]'2025-01-02 03:04:05')

        Should-Invoke -CommandName ExifTool.exe -Times 1 -Exactly
        Should-Invoke -CommandName Sync-ItemDate -Times 1 -Exactly
      }
      It 'calls ExifTool.exe by Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = 'C:\Photos\*.jpg' } | Set-ExifDate -Date ([datetime]'2025-01-02 03:04:05')

        Should-Invoke -CommandName ExifTool.exe -Times 1 -Exactly
        Should-Invoke -CommandName Sync-ItemDate -Times 1 -Exactly
      }
      It 'calls ExifTool.exe by LiteralPath' {
        Set-ExifDate -LiteralPath 'C:\Photos\IMG_0001.jpg' -Date ([datetime]'2025-01-02 03:04:05')

        Should-Invoke -CommandName ExifTool.exe -Times 1 -Exactly
        Should-Invoke -CommandName Sync-ItemDate -Times 1 -Exactly
      }
      It 'calls ExifTool.exe by LiteralPath with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ LiteralPath = 'C:\Photos\IMG_0001.jpg' } | Set-ExifDate -Date ([datetime]'2025-01-02 03:04:05')

        Should-Invoke -CommandName ExifTool.exe -Times 1 -Exactly
        Should-Invoke -CommandName Sync-ItemDate -Times 1 -Exactly
      }
    }
    Context 'SupportsShouldProcess' {
      It 'does not call ExifTool.exe when WhatIf is specified' {
        Set-ExifDate -LiteralPath 'C:\Photos\IMG_0001.jpg' -Date ([datetime]'2025-01-02 03:04:05') -Force -WhatIf

        Should-Invoke -CommandName ExifTool.exe -Times 0 -Exactly
        Should-Invoke -CommandName Sync-ItemDate -Times 0 -Exactly
      }
    }
    Context 'Other parameters' {
      It 'passes recurse to ExifTool.exe when requested' {
        Set-ExifDate -Path 'C:\Photos\*.jpg' -Date ([datetime]'2025-01-02 03:04:05') -Recurse

        Should-Invoke -CommandName ExifTool.exe -ParameterFilter { $args -contains '-recurse' } -Times 1 -Exactly
      }
    }
    Context 'Edge cases' {
    }
  }
  Describe 'Remove-ExifDate' {
    BeforeAll {
      Mock -CommandName ExifTool.exe
      Mock -CommandName Get-Content
      Mock -CommandName Out-File
      Mock -CommandName Remove-Item
      Mock -CommandName Test-Path -MockWith { $true }
      Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\Photos\*.jpg' } -MockWith {
        [PSCustomObject]@{ FullName = 'C:\Photos\IMG_0001.jpg' }
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\Photos\IMG_0001.jpg' } -MockWith {
        [PSCustomObject]@{ FullName = 'C:\Photos\IMG_0001.jpg' }
      }
    }
    Context 'ParameterSetName' {
      It 'calls ExifTool.exe by Path with wildcards' {
        Remove-ExifDate -Path 'C:\Photos\*.jpg'

        Should-Invoke -CommandName ExifTool.exe -Times 1 -Exactly
      }
      It 'calls ExifTool.exe by Path with ValueFromPipeline' {
        'C:\Photos\*.jpg' | Remove-ExifDate

        Should-Invoke -CommandName ExifTool.exe -Times 1 -Exactly
      }
      It 'calls ExifTool.exe by Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = 'C:\Photos\*.jpg' } | Remove-ExifDate

        Should-Invoke -CommandName ExifTool.exe -Times 1 -Exactly
      }
      It 'calls ExifTool.exe by LiteralPath' {
        Remove-ExifDate -LiteralPath 'C:\Photos\IMG_0001.jpg'

        Should-Invoke -CommandName ExifTool.exe -Times 1 -Exactly
      }
      It 'calls ExifTool.exe by LiteralPath with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ LiteralPath = 'C:\Photos\IMG_0001.jpg' } | Remove-ExifDate

        Should-Invoke -CommandName ExifTool.exe -Times 1 -Exactly
      }
    }
    Context 'SupportsShouldProcess' {
      It 'does not call ExifTool.exe when WhatIf is specified' {
        Remove-ExifDate -LiteralPath 'C:\Photos\IMG_0001.jpg' -Force -WhatIf

        Should-Invoke -CommandName ExifTool.exe -Times 0 -Exactly
      }
      It 'calls ExifTool.exe when Force is specified' {
        Remove-ExifDate -LiteralPath 'C:\Photos\IMG_0001.jpg' -Force -Confirm

        Should-Invoke -CommandName ExifTool.exe -Times 1 -Exactly
      }
    }
    Context 'Other parameters' {
      It 'passes recurse to ExifTool.exe when requested' {
        Remove-ExifDate -Path 'C:\Photos\*.jpg' -Recurse

        Should-Invoke -CommandName ExifTool.exe -ParameterFilter { $args -contains '-recurse' } -Times 1 -Exactly
      }
    }
    Context 'Edge cases' {
    }
  }
}
