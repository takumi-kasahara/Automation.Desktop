[CmdletBinding()]
param ()

Import-Module -Name ($PSScriptRoot | Join-Path -ChildPath '..\Automation.Desktop.psm1') -Force
Set-StrictMode -Version Latest

InModuleScope 'Compare' {
  Describe 'Compare-Csv' {
    BeforeAll {
      Mock -CommandName Test-Path -MockWith { $true }
    }
    Context 'ParameterSetName' {

    }
    Context 'Output' {
      It 'returns Hash and Description when duplicate counts differ' {
        Mock -CommandName Import-Csv -ParameterFilter { $Path -eq 'ref.csv' } -MockWith {
          @(
            [PSCustomObject]@{ Col1 = 'A'; Col2 = '1' }
          )
        }
        Mock -CommandName Import-Csv -ParameterFilter { $Path -eq 'diff.csv' } -MockWith {
          @(
            [PSCustomObject]@{ Col1 = 'A'; Col2 = '1' }
            [PSCustomObject]@{ Col1 = 'A'; Col2 = '1' }
          )
        }

        $result = Compare-Csv -ReferencePath 'ref.csv' -DifferencePath 'diff.csv' -Delimiter ','

        $result | Should-BeCollection -Count 1
        $result[0].PSObject.Properties.Name | Should-ContainCollection 'Hash'
        $result[0].PSObject.Properties.Name | Should-ContainCollection 'Path'
        $result[0].PSObject.Properties.Name | Should-ContainCollection 'Lines'
        $result[0].Path | Should-Be 'ref.csv'
        $result[0].Lines | Should-BeCollection -Count 1
        $result[0].Lines | Should-ContainCollection 1
      }
      It 'returns line-based mismatches for hashes that exist in only one file' {
        Mock -CommandName Import-Csv -ParameterFilter { $Path -eq 'ref.csv' } -MockWith {
          @(
            [PSCustomObject]@{ Col1 = 'A'; Col2 = '1' }
          )
        }
        Mock -CommandName Import-Csv -ParameterFilter { $Path -eq 'diff.csv' } -MockWith {
          @(
            [PSCustomObject]@{ Col1 = 'B'; Col2 = '2' }
          )
        }

        $result = Compare-Csv -ReferencePath 'ref.csv' -DifferencePath 'diff.csv' -Delimiter ','

        $result | Should-BeCollection -Count 2
        @($result.Path) | Should-ContainCollection 'ref.csv'
        @($result.Path) | Should-ContainCollection 'diff.csv'
        @($result.Lines | ForEach-Object { $_ }) | Should-ContainCollection 1
      }
      It 'returns the difference-side mismatch when OnlyDifference is specified for same-hash count differences' {
        Mock -CommandName Import-Csv -ParameterFilter { $Path -eq 'ref.csv' } -MockWith {
          @(
            [PSCustomObject]@{ Col1 = 'A'; Col2 = '1' }
            [PSCustomObject]@{ Col1 = 'A'; Col2 = '1' }
          )
        }
        Mock -CommandName Import-Csv -ParameterFilter { $Path -eq 'diff.csv' } -MockWith {
          @(
            [PSCustomObject]@{ Col1 = 'A'; Col2 = '1' }
          )
        }

        $result = Compare-Csv -ReferencePath 'ref.csv' -DifferencePath 'diff.csv' -Delimiter ',' -OnlyDifference

        $result | Should-BeCollection -Count 1
        $result[0].Path | Should-Be 'diff.csv'
        $result[0].Lines | Should-BeCollection -Count 1
        $result[0].SimilarCandidates | Should-BeCollection -Count 1
      }
      It 'returns only reference-only mismatches when OnlyReference is specified' {
        Mock -CommandName Import-Csv -ParameterFilter { $Path -eq 'ref.csv' } -MockWith {
          @(
            [PSCustomObject]@{ Col1 = 'A'; Col2 = '1' }
            [PSCustomObject]@{ Col1 = 'C'; Col2 = '3' }
          )
        }
        Mock -CommandName Import-Csv -ParameterFilter { $Path -eq 'diff.csv' } -MockWith {
          @(
            [PSCustomObject]@{ Col1 = 'A'; Col2 = '1' }
            [PSCustomObject]@{ Col1 = 'B'; Col2 = '2' }
          )
        }

        $result = Compare-Csv -ReferencePath 'ref.csv' -DifferencePath 'diff.csv' -Delimiter ',' -OnlyReference

        $result | Should-BeCollection -Count 1
        $result[0].Path | Should-Be 'ref.csv'
        $result[0].Hash | Should -Not -BeNullOrEmpty
      }
      It 'returns only difference-only mismatches when OnlyDifference is specified' {
        Mock -CommandName Import-Csv -ParameterFilter { $Path -eq 'ref.csv' } -MockWith {
          @(
            [PSCustomObject]@{ Col1 = 'A'; Col2 = '1' }
            [PSCustomObject]@{ Col1 = 'C'; Col2 = '3' }
          )
        }
        Mock -CommandName Import-Csv -ParameterFilter { $Path -eq 'diff.csv' } -MockWith {
          @(
            [PSCustomObject]@{ Col1 = 'A'; Col2 = '1' }
            [PSCustomObject]@{ Col1 = 'B'; Col2 = '2' }
          )
        }

        $result = Compare-Csv -ReferencePath 'ref.csv' -DifferencePath 'diff.csv' -Delimiter ',' -OnlyDifference

        $result | Should-BeCollection -Count 1
        $result[0].Path | Should-Be 'diff.csv'
        $result[0].Hash | Should -Not -BeNullOrEmpty
      }
      It 'throws when OnlyReference and OnlyDifference are both specified' {
        Mock -CommandName Import-Csv -ParameterFilter { $Path -eq 'ref.csv' } -MockWith {
          @(
            [PSCustomObject]@{ Col1 = 'A'; Col2 = '1' }
          )
        }
        Mock -CommandName Import-Csv -ParameterFilter { $Path -eq 'diff.csv' } -MockWith {
          @(
            [PSCustomObject]@{ Col1 = 'B'; Col2 = '2' }
          )
        }

        { Compare-Csv -ReferencePath 'ref.csv' -DifferencePath 'diff.csv' -Delimiter ',' -OnlyReference -OnlyDifference } | Should-Throw 'OnlyReference and OnlyDifference cannot be specified together.'
      }
      It 'enumerates all line numbers for duplicate same-hash similar candidates' {
        Mock -CommandName Import-Csv -ParameterFilter { $Path -eq 'ref.csv' } -MockWith {
          @(
            [PSCustomObject]@{ Col1 = 'ABCX'; Col2 = '1' }
          )
        }
        Mock -CommandName Import-Csv -ParameterFilter { $Path -eq 'diff.csv' } -MockWith {
          @(
            [PSCustomObject]@{ Col1 = 'ABCY'; Col2 = '1' }
            [PSCustomObject]@{ Col1 = 'ABCY'; Col2 = '1' }
            [PSCustomObject]@{ Col1 = 'ZZZZ'; Col2 = '9' }
          )
        }

        $result = Compare-Csv -ReferencePath 'ref.csv' -DifferencePath 'diff.csv' -Delimiter ','
        $referenceOnly = @($result | Where-Object { $_.Path -eq 'ref.csv' })

        $referenceOnly | Should-BeCollection -Count 1
        $referenceOnly[0].SimilarCandidates | Should-BeCollection -Count 2
        $referenceOnly[0].SimilarCandidates[0].Lines | Should-BeCollection -Count 2
        $referenceOnly[0].SimilarCandidates[0].Lines | Should-ContainCollection 1
        $referenceOnly[0].SimilarCandidates[0].Lines | Should-ContainCollection 2
      }
      It 'lists differing column names for similar mismatched rows' {
        Mock -CommandName Import-Csv -ParameterFilter { $Path -eq 'ref.csv' } -MockWith {
          @(
            [PSCustomObject]@{ Name = 'Alice'; Value = '100'; Status = 'OK' }
          )
        }
        Mock -CommandName Import-Csv -ParameterFilter { $Path -eq 'diff.csv' } -MockWith {
          @(
            [PSCustomObject]@{ Name = 'Alice'; Value = '200'; Status = 'FAIL' }
          )
        }

        $result = Compare-Csv -ReferencePath 'ref.csv' -DifferencePath 'diff.csv' -Delimiter ','

        $result | Should-BeCollection -Count 2
        $allColumns = @($result.SimilarCandidates.Columns)
        $allColumns | Should-ContainCollection 'Value'
        $allColumns | Should-ContainCollection 'Status'
      }
      It 'returns structured similar candidates as an object array' {
        Mock -CommandName Import-Csv -ParameterFilter { $Path -eq 'ref.csv' } -MockWith {
          @(
            [PSCustomObject]@{ Col1 = 'ABCX'; Col2 = '1' }
          )
        }
        Mock -CommandName Import-Csv -ParameterFilter { $Path -eq 'diff.csv' } -MockWith {
          @(
            [PSCustomObject]@{ Col1 = 'ABCY'; Col2 = '1' }
            [PSCustomObject]@{ Col1 = 'ABCY'; Col2 = '1' }
            [PSCustomObject]@{ Col1 = 'ZZZZ'; Col2 = '9' }
          )
        }

        $result = Compare-Csv -ReferencePath 'ref.csv' -DifferencePath 'diff.csv' -Delimiter ','
        $referenceOnly = @($result | Where-Object { $_.Path -eq 'ref.csv' })

        $referenceOnly | Should-BeCollection -Count 1
        $referenceOnly[0].PSObject.Properties.Name | Should-ContainCollection 'SimilarCandidates'
        $referenceOnly[0].SimilarCandidates | Should-BeCollection -Count 2
        $referenceOnly[0].SimilarCandidates[0].PSObject.Properties.Name | Should-ContainCollection 'Hash'
        $referenceOnly[0].SimilarCandidates[0].PSObject.Properties.Name | Should-ContainCollection 'Similarity'
        $referenceOnly[0].SimilarCandidates[0].PSObject.Properties.Name | Should-ContainCollection 'Lines'
        $referenceOnly[0].SimilarCandidates[0].PSObject.Properties.Name | Should-ContainCollection 'Columns'
      }
      It 'returns no mismatches when all hashes and counts are equal' {
        Mock -CommandName Import-Csv -ParameterFilter { $Path -eq 'ref.csv' } -MockWith {
          @(
            [PSCustomObject]@{ Col1 = 'A'; Col2 = '1' }
            [PSCustomObject]@{ Col1 = 'B'; Col2 = '2' }
          )
        }
        Mock -CommandName Import-Csv -ParameterFilter { $Path -eq 'diff.csv' } -MockWith {
          @(
            [PSCustomObject]@{ Col1 = 'A'; Col2 = '1' }
            [PSCustomObject]@{ Col1 = 'B'; Col2 = '2' }
          )
        }

        $result = Compare-Csv -ReferencePath 'ref.csv' -DifferencePath 'diff.csv' -Delimiter ','

        $result | Should-BeCollection -Count 0
      }
    }
    Context 'Other parameters' {
      It 'passes custom Delimiter to Import-Csv for both files' {
        Mock -CommandName Import-Csv -ParameterFilter { $Path -eq 'ref.csv' } -MockWith {
          @(
            [PSCustomObject]@{ Col1 = 'A'; Col2 = '1' }
          )
        }
        Mock -CommandName Import-Csv -ParameterFilter { $Path -eq 'diff.csv' } -MockWith {
          @(
            [PSCustomObject]@{ Col1 = 'A'; Col2 = '1' }
          )
        }

        $result = Compare-Csv -ReferencePath 'ref.csv' -DifferencePath 'diff.csv' -Delimiter ';'

        $result | Should-BeCollection -Count 0
        Should-Invoke -CommandName Import-Csv -ParameterFilter {
          $Path -eq 'ref.csv' -and
          $Delimiter -eq ';'
        } -Times 1 -Exactly
        Should-Invoke -CommandName Import-Csv -ParameterFilter {
          $Path -eq 'diff.csv' -and
          $Delimiter -eq ';'
        } -Times 1 -Exactly
      }
      It 'counts columns from first line and passes generated headers to Import-Csv' {
        Mock -CommandName Get-Content -ParameterFilter { $LiteralPath -eq 'ref.csv' } -MockWith { 'a,b,c' }
        Mock -CommandName Get-Content -ParameterFilter { $LiteralPath -eq 'diff.csv' } -MockWith { 'x,y,z' }
        Mock -CommandName Import-Csv -ParameterFilter { $Path -eq 'ref.csv' } -MockWith {
          @(
            [PSCustomObject]@{ 'Column 1' = 'a'; 'Column 2' = 'b'; 'Column 3' = 'c' }
          )
        }
        Mock -CommandName Import-Csv -ParameterFilter { $Path -eq 'diff.csv' } -MockWith {
          @(
            [PSCustomObject]@{ 'Column 1' = 'a'; 'Column 2' = 'b'; 'Column 3' = 'c' }
          )
        }

        $result = Compare-Csv -ReferencePath 'ref.csv' -DifferencePath 'diff.csv' -Delimiter ',' -NoHeader

        $result | Should-BeCollection -Count 0
        Should-Invoke -CommandName Import-Csv -ParameterFilter {
          $Path -eq 'ref.csv' -and
          $Delimiter -eq ',' -and
          $Header.Count -eq 3 -and
          $Header[0] -eq 'Column 1' -and
          $Header[1] -eq 'Column 2' -and
          $Header[2] -eq 'Column 3'
        } -Times 1 -Exactly
        Should-Invoke -CommandName Import-Csv -ParameterFilter {
          $Path -eq 'diff.csv' -and
          $Delimiter -eq ',' -and
          $Header.Count -eq 3 -and
          $Header[0] -eq 'Column 1' -and
          $Header[1] -eq 'Column 2' -and
          $Header[2] -eq 'Column 3'
        } -Times 1 -Exactly
      }
    }
    Context 'Edge cases' {
      It 'handles double-quoted CSV fields that contain delimiters' {
        $referencePath = Join-Path -Path $TestDrive -ChildPath 'quoted-reference.csv'
        $differencePath = Join-Path -Path $TestDrive -ChildPath 'quoted-difference.csv'

        @(
          '"Name","Comment"'
          '"Alice","hello,world"'
          '"Bob","x,y,z"'
        ) | Set-Content -LiteralPath $referencePath

        @(
          '"Name","Comment"'
          '"Alice","hello,world"'
          '"Bob","x,y,z"'
        ) | Set-Content -LiteralPath $differencePath

        $result = Compare-Csv -ReferencePath $referencePath -DifferencePath $differencePath -Delimiter ','

        $result | Should-BeCollection -Count 0
      }
      It 'reports mismatches when rows have different column counts' {
        $referencePath = Join-Path -Path $TestDrive -ChildPath 'varying-columns-reference.csv'
        $differencePath = Join-Path -Path $TestDrive -ChildPath 'varying-columns-difference.csv'

        @(
          'A,B,C'
          '1,2,3'
          '4,5'
        ) | Set-Content -LiteralPath $referencePath
        @(
          'A,B,C'
          '1,2,3'
          '4,5,6'
        ) | Set-Content -LiteralPath $differencePath

        $result = Compare-Csv -ReferencePath $referencePath -DifferencePath $differencePath -Delimiter ','

        $result | Should-BeCollection -Count 2
        @($result.Path) | Should-ContainCollection $referencePath
        @($result.Path) | Should-ContainCollection $differencePath
        @($result.Lines) | Should-ContainCollection 2
      }
    }
  }
}
