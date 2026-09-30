using namespace System.Collections.Generic
using namespace System.Diagnostics.CodeAnalysis
using namespace System.Security.Cryptography
using namespace System.Text

Set-StrictMode -Version Latest

#region Private
class CompareCsvHashGroup {
  [int]$Count
  [List[int]]$Lines
  [List[object]]$Rows
  [string]$Text
  [string]$Path
}
class CompareCsvSimilarityCandidate {
  [string]$Path
  [int[]]$Lines
  [string]$Hash
  [double]$Similarity
  [int]$Distance
  [string[]]$Columns
}

class CompareCsvMismatch {
  [string]$Path
  [int[]]$Lines
  [string]$Hash
  [CompareCsvSimilarityCandidate[]]$SimilarCandidates
}
function Get-CsvRowHash {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [Parameter(Mandatory)]
    [pscustomobject]
    $Row
  )
  $serialized = $Row | ConvertTo-Json -Compress -Depth 100
  $bytes = [Encoding]::UTF8.GetBytes($serialized)
  $hashBytes = [SHA256]::HashData($bytes)
  return [Convert]::ToHexString($hashBytes)
}
function New-CsvHeader {
  [CmdletBinding()]
  [SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'This function only generates headers and does not change state.')]
  param (
    [Parameter(Mandatory)]
    [string]
    $Path,
    [Parameter(Mandatory)]
    [char]
    $Delimiter
  )
  $firstLine = Get-Content -LiteralPath $Path -TotalCount 1
  $separator = [regex]::Escape([string]$Delimiter)
  $columnCount = [regex]::Split($firstLine, $separator).Count
  return 1..$columnCount | ForEach-Object { "Column $_" }
}
function Get-CsvHashGroup {
  [CmdletBinding()]
  [OutputType([hashtable])]
  param (
    [Parameter(Mandatory)]
    [PSCustomObject[]]
    $Rows
  )
  $hashGroups = @{}
  for ($index = 0; $index -lt $Rows.Count; $index++) {
    $lineNumber = $index + 1
    $row = $Rows[$index]
    $serialized = $row | ConvertTo-Json -Compress -Depth 100
    $hash = Get-CsvRowHash -Row $row
    if (-not $hashGroups.ContainsKey($hash)) {
      $group = [CompareCsvHashGroup]::new()
      $group.Count = 0
      $group.Lines = [List[int]]::new()
      $group.Rows = [List[object]]::new()
      $group.Text = $serialized
      $group.Path = $null
      $hashGroups[$hash] = $group
    }
    $hashGroups[$hash].Count++
    $hashGroups[$hash].Lines.Add($lineNumber)
    $hashGroups[$hash].Rows.Add($row)
  }
  return $hashGroups
}
function Get-CsvDifferenceColumn {
  [CmdletBinding()]
  [OutputType([object[]])]
  param (
    [Parameter(Mandatory)]
    [pscustomobject]
    $ReferenceRow,
    [Parameter(Mandatory)]
    [pscustomobject]
    $DifferenceRow
  )
  $allNames = @(
    $ReferenceRow.PSObject.Properties.Name
  )
  foreach ($name in $DifferenceRow.PSObject.Properties.Name) {
    if ($allNames -notcontains $name) {
      $allNames += $name
    }
  }
  $differentNames = foreach ($name in $allNames) {
    $referenceValue = $ReferenceRow.$name
    $differenceValue = $DifferenceRow.$name
    if (($null -eq $referenceValue -and $null -eq $differenceValue) -or ($referenceValue -eq $differenceValue)) {
      continue
    }
    $name
  }
  return @($differentNames)
}
function Get-SimilarHashMatch {
  [CmdletBinding()]
  [OutputType([object[]])]
  param (
    [Parameter(Mandatory)]
    [CompareCsvHashGroup]
    $SourceGroup,
    [Parameter(Mandatory)]
    [hashtable]
    $TargetGroups
  )
  if ($TargetGroups.Count -eq 0) {
    return @()
  }
  $targetHashes = @($TargetGroups.Keys)
  $candidates = foreach ($index in 0..($targetHashes.Count - 1)) {
    $targetHash = $targetHashes[$index]
    $targetGroup = $TargetGroups[$targetHash]

    Write-Progress -Id 2 -Activity 'Finding similar candidates' -Status "Comparing candidate group $($index + 1) of $($targetHashes.Count)" -CurrentOperation "Hash: $targetHash" -PercentComplete ([int](($index + 1) / $targetHashes.Count * 100))

    $targetPairs = @(foreach ($sourceRow in @($SourceGroup.Rows)) {
        foreach ($targetRow in @($targetGroup.Rows)) {
          $distance = [StringMetrics.Levenshtein]::Distance(($sourceRow | ConvertTo-Json -Compress -Depth 100), ($targetRow | ConvertTo-Json -Compress -Depth 100))
          $similarity = [StringMetrics.Levenshtein]::Similarity(($sourceRow | ConvertTo-Json -Compress -Depth 100), ($targetRow | ConvertTo-Json -Compress -Depth 100))
          $columns = Get-CsvDifferenceColumn -ReferenceRow $sourceRow -DifferenceRow $targetRow
          $candidate = [CompareCsvSimilarityCandidate]::new()
          $candidate.Path = $TargetGroups[$targetHash].Path
          $candidate.Lines = @($targetGroup.Lines)
          $candidate.Hash = $targetHash
          $candidate.Similarity = $similarity
          $candidate.Distance = $distance
          $candidate.Columns = @($columns)
          $candidate
        }
      })
    if ($null -eq $targetPairs -or $targetPairs.Count -eq 0) {
      continue
    }
    $sortedPairs = @(
      $targetPairs |
      Sort-Object -Property @(
        @{
          Expression = 'Similarity'
          Descending = $true
        }
        @{
          Expression = 'Distance'
          Descending = $false
        }
        @{
          Expression = 'Hash'
          Descending = $false
        }
      )
    )
    $bestMatch = @($sortedPairs | Select-Object -First ([Math]::Max(1, [Math]::Ceiling([Math]::Sqrt($sortedPairs.Count)))))
    if ($bestMatch.Count -eq 0) {
      continue
    }
    $firstMatch = $bestMatch[0]

    $candidate = [CompareCsvSimilarityCandidate]::new()
    $candidate.Path = $TargetGroups[$targetHash].Path
    $candidate.Lines = @($targetGroup.Lines)
    $candidate.Hash = $targetHash
    $candidate.Similarity = $firstMatch.Similarity
    $candidate.Distance = $firstMatch.Distance
    $candidate.Columns = @($firstMatch.Columns)
    $candidate
  }
  Write-Progress -Id 2 -Activity 'Finding similar candidates' -Completed
  return @(
    $candidates |
    Sort-Object -Property @(
      @{
        Expression = 'Similarity'
        Descending = $true
      },
      @{
        Expression = 'Distance'
        Descending = $false
      },
      @{
        Expression = 'Hash'
        Descending = $false
      }
    )
  )
}
#endregion
#region Public
function Compare-Csv {
  <#
  .SYNOPSIS
    Compares two CSV files by row hash and returns mismatch summaries.

  .DESCRIPTION
    Imports two CSV files, computes a SHA-256 hash for each row, and groups rows by hash.
    For hashes present in both files, this function compares occurrence counts and reports mismatches with line positions.
    For hashes present in only one file, this function reports the side and line positions.
    When NoHeader is specified, the function generates headers (Column 1, Column 2, ...) from the first line of each file.

  .PARAMETER ReferencePath
    The path to the reference CSV file.

  .PARAMETER DifferencePath
    The path to the difference CSV file to compare against the reference file.

  .PARAMETER Delimiter
    The delimiter character used in both CSV files.
    The default delimiter is a comma (,).

  .PARAMETER NoHeader
    Indicates that input CSV files do not have a header row.
    When specified, headers are generated automatically from the first line column count.

  .EXAMPLE
    ```powershell
    Compare-Csv -ReferencePath '.\reference.csv' -DifferencePath '.\difference.csv'
    ```

    Compares two comma-delimited CSV files and returns mismatch records.

  .EXAMPLE
    ```powershell
    Compare-Csv -ReferencePath '.\reference.tsv' -DifferencePath '.\difference.tsv' -Delimiter "`t"
    ```

    Compares two tab-delimited files and returns mismatch records.

  .EXAMPLE
    ```powershell
    Compare-Csv -ReferencePath '.\reference-no-header.csv' -DifferencePath '.\difference-no-header.csv' -NoHeader
    ```

    Compares two headerless CSV files using generated column names.

  .OUTPUTS
    CompareCsvMismatch[].
      Each object contains Path, Lines, Hash, and SimilarCandidates properties for a detected mismatch.

  .NOTES
    One-sided mismatches include similarity candidates ordered by Levenshtein-based similarity.
  #>
  [OutputType([CompareCsvMismatch[]])]
  param (
    [Parameter(Mandatory, Position = 0)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]
    $ReferencePath,
    [Parameter(Mandatory, Position = 1)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]
    $DifferencePath,
    [switch]
    $OnlyReference,
    [switch]
    $OnlyDifference,
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [char]
    $Delimiter = ',',
    [switch]
    $NoHeader
  )
  if ($OnlyReference -and $OnlyDifference) {
    throw 'OnlyReference and OnlyDifference cannot be specified together.'
  }

  Write-Progress -Id 1 -Activity 'Comparing CSV files' -Status 'Importing CSV rows' -CurrentOperation "Reference: $ReferencePath"
  $referenceRows = if ($NoHeader) {
    $header = New-CsvHeader -Path $ReferencePath -Delimiter $Delimiter
    Import-Csv -Path $ReferencePath -Delimiter $Delimiter -Header $header
  } else {
    Import-Csv -Path $ReferencePath -Delimiter $Delimiter
  }

  Write-Progress -Id 1 -Activity 'Comparing CSV files' -Status 'Importing CSV rows' -CurrentOperation "Difference: $DifferencePath"
  $differenceRows = if ($NoHeader) {
    $header = New-CsvHeader -Path $DifferencePath -Delimiter $Delimiter
    Import-Csv -Path $DifferencePath -Delimiter $Delimiter -Header $header
  } else {
    Import-Csv -Path $DifferencePath -Delimiter $Delimiter
  }

  Write-Progress -Id 1 -Activity 'Comparing CSV files' -Status 'Hashing rows by group' -CurrentOperation 'Building reference groups'
  $referenceGroups = Get-CsvHashGroup -Rows @($referenceRows)
  foreach ($key in $referenceGroups.Keys) {
    $referenceGroups[$key].Path = $ReferencePath
  }

  Write-Progress -Id 1 -Activity 'Comparing CSV files' -Status 'Hashing rows by group' -CurrentOperation 'Building difference groups'
  $differenceGroups = Get-CsvHashGroup -Rows @($differenceRows)
  foreach ($key in $differenceGroups.Keys) {
    $differenceGroups[$key].Path = $DifferencePath
  }

  $result = [List[object]]::new()
  $allHashes = @($referenceGroups.Keys + $differenceGroups.Keys | Sort-Object -Unique)

  foreach ($index in 0..($allHashes.Count - 1)) {
    $hash = $allHashes[$index]
    $hasReference = $referenceGroups.ContainsKey($hash)
    $hasDifference = $differenceGroups.ContainsKey($hash)

    $progressPercent = [int](($index + 1) / $allHashes.Count * 100)
    Write-Progress -Id 1 -Activity 'Comparing CSV files' -Status 'Comparing hash groups' -CurrentOperation "Processing hash $hash ($($index + 1) of $($allHashes.Count))" -PercentComplete $progressPercent
    if ($hasReference -and $hasDifference) {
      $referenceCount = $referenceGroups[$hash].Count
      $differenceCount = $differenceGroups[$hash].Count

      if ($referenceCount -ne $differenceCount) {
        $referenceLines = @($referenceGroups[$hash].Lines)
        $differenceLines = @($differenceGroups[$hash].Lines)

        if ($OnlyReference -or $referenceCount -lt $differenceCount) {
          $selectedPath = $ReferencePath
          $selectedLines = @($referenceLines)
          $selectedSourceGroup = $referenceGroups[$hash]
          $selectedTargetGroups = $differenceGroups
        } elseif ($OnlyDifference -or $differenceCount -lt $referenceCount) {
          $selectedPath = $DifferencePath
          $selectedLines = @($differenceLines)
          $selectedSourceGroup = $differenceGroups[$hash]
          $selectedTargetGroups = $referenceGroups
        }

        $similarMatches = @(Get-SimilarHashMatch -SourceGroup $selectedSourceGroup -TargetGroups $selectedTargetGroups)
        $mismatch = [CompareCsvMismatch]::new()
        $mismatch.Hash = $hash
        $mismatch.Path = $selectedPath
        $mismatch.Lines = @($selectedLines)
        $mismatch.SimilarCandidates = @($similarMatches)
        $result.Add($mismatch)
      }
      continue
    }
    if ($hasReference) {
      if ($OnlyDifference) {
        continue
      }
      $referenceLines = @($referenceGroups[$hash].Lines)
      $similarMatches = @(Get-SimilarHashMatch -SourceGroup $referenceGroups[$hash] -TargetGroups $differenceGroups)
      $mismatch = [CompareCsvMismatch]::new()
      $mismatch.Path = $ReferencePath
      $mismatch.Lines = $referenceLines
      $mismatch.Hash = $hash
      $mismatch.SimilarCandidates = @($similarMatches)
      $result.Add($mismatch)
      continue
    }
    if ($hasDifference) {
      if ($OnlyReference) {
        continue
      }
      $differenceLines = @($differenceGroups[$hash].Lines)
      $similarMatches = @(Get-SimilarHashMatch -SourceGroup $differenceGroups[$hash] -TargetGroups $referenceGroups)
      $mismatch = [CompareCsvMismatch]::new()
      $mismatch.Path = $DifferencePath
      $mismatch.Lines = $differenceLines
      $mismatch.Hash = $hash
      $mismatch.SimilarCandidates = @($similarMatches)
      $result.Add($mismatch)
    }
  }
  return @($result)
}
#endregion
