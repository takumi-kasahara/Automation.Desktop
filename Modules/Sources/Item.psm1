using namespace System.Globalization
using namespace System.IO
using namespace System.Text

Set-StrictMode -Version Latest

#region Private
class ItemDate {
  [string]$Path
  [Nullable[datetime]]$CreationTime
  [Nullable[datetime]]$LastWriteTime
  [Nullable[datetime]]$LastAccessTime
  [string]$Hash
}
class MeasureDirectoryInfo {
  [FileSystemInfo[]]$RecentCreatedFiles
  [FileSystemInfo[]]$RecentCreatedDirectories
  [FileSystemInfo[]]$RecentModifiedFiles
  [FileSystemInfo[]]$RecentModifiedDirectories
  [FileSystemInfo[]]$LargeFiles
  [FileSystemInfo[]]$LargeDirectories
  [FileSystemInfo[]]$LongNames
  [SimilarDirectoryInfo[]]$SimilarNames
}
class SimilarDirectoryInfo {
  [DirectoryInfo]$OlderItem
  [DirectoryInfo]$NewerItem
  [double]$Similarity
}
function ConvertTo-FileSystemInfo {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [object]
    $InputObject
  )
  if ($InputObject -is [FileSystemInfo]) {
    return $InputObject
  }
  $path = $InputObject.FullName ?? $InputObject.Path
  if (-not $path) {
    return $InputObject
  }
  $isDirectory = $InputObject.PSObject.Properties.Name -contains 'PSIsContainer' ? [bool]$InputObject.PSIsContainer : $false
  $item = $isDirectory ? [DirectoryInfo]::new($path) : [FileInfo]::new($path)
  foreach ($property in $InputObject.PSObject.Properties) {
    $item | Add-Member -MemberType NoteProperty -Name $property.Name -Value $property.Value -Force
  }
  return $item
}
#endregion
#region Public
function Get-DuplicateFile {
  <#
  .SYNOPSIS
    Finds duplicate files in directories by extension, size, and hash.

  .DESCRIPTION
    Get-DuplicateFile scans one or more directories, groups files by extension and length, computes
    SHA256 hashes for matching candidates, and returns duplicate file objects.
    The command sorts each duplicate group according to the specified properties and skips the first item
    in each group, so only duplicate copies are returned.

  .PARAMETER Path
    Specifies directory paths to search. Supports wildcards.

  .PARAMETER LiteralPath
    Specifies literal directory paths to search. Wildcards are not interpreted.

  .PARAMETER Recurse
    Searches child directories recursively.

  .PARAMETER Property
    Specifies one or more file properties used to sort duplicates before skipping the first item.

  .PARAMETER Descending
    Sorts by the specified property values in descending order.

  .PARAMETER Skip
    Skips the first N items in each duplicate group and returns the rest.

  .EXAMPLE
    ``` powershell
    Get-DuplicateFile -Path 'C:\dir\*' -Recurse
    ```

    Returns duplicate files found recursively below C:\dir.

  .EXAMPLE
    ``` powershell
    Get-DuplicateFile -LiteralPath 'C:\Temp' -Property 'CreationTime','LastWriteTime' -Descending -Skip 2
    ```

  .OUTPUTS
    System.IO.FileInfo
      Objects for duplicate files only.
  #>
  [CmdletBinding(DefaultParameterSetName = 'PathSet')]
  [OutputType([System.IO.FileInfo])]
  param (
    [Parameter(Mandatory, ParameterSetName = 'PathSet', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [SupportsWildcards()]
    [ValidateScript({ Test-Path -Path $_ })]
    [string[]]
    $Path,
    [Alias('PSPath', 'LP')]
    [Parameter(Mandatory, ParameterSetName = 'LiteralPathSet', ValueFromPipelineByPropertyName)]
    [ValidateScript({ Test-Path -LiteralPath $_ })]
    [string[]]
    $LiteralPath,
    [switch]
    $Recurse,
    [string[]]
    $Property = @(
      'LastWriteTime'
      'CreationTime'
    ),
    [switch]
    $Descending,
    [int]
    $Skip = 1
  )
  begin {
    Write-Progress -Activity 'Collect duplicate files.'
  }
  process {
    $items = @(
      switch -Exact -CaseSensitive ($PSCmdlet.ParameterSetName) {
        'PathSet' {
          Get-Item -Path $Path -Force
        }
        'LiteralPathSet' {
          Get-Item -LiteralPath $LiteralPath -Force
        }
      }
    )
    $items |
    Where-Object -Property PSIsContainer |
    Get-ChildItem -File -Recurse:$Recurse -Force |
    Group-Object -Property Extension, Length |
    Where-Object -Property Count -GT 1 |
    Sort-Object -Property Count |
    Select-Object -ExpandProperty Group |
    ForEach-Object {
      return [PSCustomObject]@{
        Hash = ($_ | Get-FileHash -Algorithm SHA256).Hash
        Item = $_
      }
    } |
    Group-Object -Property Hash |
    Where-Object -Property Count -GT 1 |
    ForEach-Object {
      $_.Group |
      Select-Object -ExpandProperty Item |
      Sort-Object -Property:$Property -Descending:$Descending |
      Select-Object -Skip:$Skip
    }
  }
  clean {
    Write-Progress -Completed
  }
}
function Get-EmptyDirectory {
  <#
  .SYNOPSIS
    Gets empty directories from one or more paths.

  .DESCRIPTION
    Get-EmptyDirectory returns directories that contain no child items.
    It accepts wildcards or literal paths and can search recursively when the
    -Recurse switch is specified.

  .PARAMETER Path
    Specifies directory paths to search. Supports wildcards.

  .PARAMETER LiteralPath
    Specifies literal directory paths to search. Wildcards are not interpreted.

  .PARAMETER Recurse
    Searches child directories recursively.

  .EXAMPLE
    ``` powershell
    Get-EmptyDirectory -Path 'C:\dir\*'
    ```

    Returns empty directories directly below C:\dir.

  .EXAMPLE
    ``` powershell
    Get-EmptyDirectory -LiteralPath 'C:\dir' -Recurse
    ```

  .OUTPUTS
    System.IO.DirectoryInfo
      Objects for directories that have no child items.
  #>
  [CmdletBinding(DefaultParameterSetName = 'PathSet')]
  [OutputType([System.IO.DirectoryInfo])]
  param (
    [Parameter(Mandatory, ParameterSetName = 'PathSet', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [SupportsWildcards()]
    [ValidateScript({ Test-Path -Path $_ })]
    [string[]]
    $Path,
    [Alias('PSPath', 'LP')]
    [Parameter(Mandatory, ParameterSetName = 'LiteralPathSet', ValueFromPipelineByPropertyName)]
    [string[]]
    [ValidateScript({ Test-Path -LiteralPath $_ })]
    $LiteralPath,
    [switch]
    $Recurse
  )
  begin {
    Write-Progress -Activity 'Collect empty directories.'
  }
  process {
    $items = @(
      switch -Exact -CaseSensitive ($PSCmdlet.ParameterSetName) {
        'PathSet' {
          Get-Item -Path $Path -Force
        }
        'LiteralPathSet' {
          Get-Item -LiteralPath $LiteralPath -Force
        }
      }
    )
    $items |
    Where-Object -Property PSIsContainer |
    Get-ChildItem -Directory -Recurse:$Recurse -Force |
    Where-Object { @($_ | Get-ChildItem -Force).Count -eq 0 }
  }
  clean {
    Write-Progress -Completed
  }
}
function Measure-Directory {
  <#
  .SYNOPSIS
    Calculates directory statistics and metadata summaries.

  .DESCRIPTION
    Measure-Directory evaluates one or more directories and returns
    a `MeasureDirectoryInfo` object containing requested statistics such as recent
    file and directory listings, large files, long names, and similar directory names.
    It supports wildcard-aware `-Path` input and exact `-LiteralPath` input.

  .PARAMETER Path
    Specifies one or more directory paths to analyze. Wildcards are supported.

  .PARAMETER LiteralPath
    Specifies one or more exact directory paths. Wildcards are not interpreted.

  .PARAMETER Recurse
    Searches child directories recursively.

  .PARAMETER Depth
    Limits recursion depth when searching directories.

  .PARAMETER AllStats
    Calculates all available statistics.

  .PARAMETER LongNames
  　Returns files with the longest names.

  .PARAMETER LargeDirectories
    Returns directories with the largest total file sizes.

  .PARAMETER LargeFiles
    Returns the largest files.

  .PARAMETER RecentCreatedDirectories
    Returns directories with the most recent creation times.

  .PARAMETER RecentCreatedFiles
    Returns files with the most recent creation times.

  .PARAMETER RecentModifiedDirectories
    Returns directories with the most recent modification times.

  .PARAMETER RecentModifiedFiles
    Returns files with the most recent modification times.

  .PARAMETER SimilarNames
    Returns directory pairs with similar names.

  .EXAMPLE
    ``` powershell
    Measure-Directory -Path 'C:\dir\*' -RecentModifiedFiles
    ```

    Measures child directories and includes their most recently modified files.

  .EXAMPLE
    ``` powershell
    Measure-Directory -LiteralPath 'C:\dir' -AllStats -Recurse -Depth 2
    ```

  .OUTPUTS
    MeasureDirectoryInfo
      Objects containing requested directory statistics and metadata summaries.

  .NOTES
    Returns `MeasureDirectoryInfo` objects containing one or more statistics arrays.
  #>
  [CmdletBinding(DefaultParameterSetName = 'PathSet')]
  [OutputType([MeasureDirectoryInfo])]
  param (
    [Parameter(Mandatory, ParameterSetName = 'PathSet', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [SupportsWildcards()]
    [ValidateScript({ Test-Path -Path $_ })]
    [string[]]
    $Path,
    [Alias('PSPath', 'LP')]
    [Parameter(Mandatory, ParameterSetName = 'LiteralPathSet', ValueFromPipelineByPropertyName)]
    [ValidateScript({ Test-Path -LiteralPath $_ })]
    [string[]]
    $LiteralPath,
    [switch]
    $Recurse,
    [uint]
    $Depth,
    [switch]
    $AllStats,
    [switch]
    $LongNames,
    [switch]
    $LargeDirectories,
    [switch]
    $LargeFiles,
    [switch]
    $RecentCreatedDirectories,
    [switch]
    $RecentCreatedFiles,
    [switch]
    $RecentModifiedDirectories,
    [switch]
    $RecentModifiedFiles,
    [switch]
    $SimilarNames
  )
  process {
    $items = @(
      switch -Exact -CaseSensitive ($PSCmdlet.ParameterSetName) {
        'PathSet' {
          Get-Item -Path $Path -Force
        }
        'LiteralPathSet' {
          Get-Item -LiteralPath $LiteralPath -Force
        }
      }
    )
    $items |
    Where-Object -Property PSIsContainer |
    ForEach-Object {
      $measure = [MeasureDirectoryInfo]::new()
      $id = 0
      if ($AllStats -or $RecentCreatedFiles) {
        $id++
        Write-Progress -Activity 'Calculate recent created files' -Id $id
        $result = $_ | Get-ChildItem -File -Recurse:$Recurse -Force -Depth:$Depth | ForEach-Object { ConvertTo-FileSystemInfo -InputObject $_ }
        $measure.RecentCreatedFiles = $result | Sort-Object -Property CreationTime -Descending -Top ([Math]::Max(1, [Math]::Ceiling([Math]::Sqrt(@($result).Count))))
      }
      if ($AllStats -or $RecentCreatedDirectories) {
        $id++
        Write-Progress -Activity 'Calculate recent created directories' -Id $id
        $result = $_ | Get-ChildItem -Directory -Recurse:$Recurse -Force -Depth:$Depth | ForEach-Object { ConvertTo-FileSystemInfo -InputObject $_ }
        $measure.RecentCreatedDirectories = $result | Sort-Object -Property CreationTime -Descending -Top ([Math]::Max(1, [Math]::Ceiling([Math]::Sqrt(@($result).Count))))
      }
      if ($AllStats -or $RecentModifiedFiles) {
        $id++
        Write-Progress -Activity 'Calculate recent modified files' -Id $id
        $result = $_ | Get-ChildItem -File -Recurse:$Recurse -Force -Depth:$Depth | ForEach-Object { ConvertTo-FileSystemInfo -InputObject $_ }
        $measure.RecentModifiedFiles = $result | Sort-Object -Property LastWriteTime -Descending -Top ([Math]::Max(1, [Math]::Ceiling([Math]::Sqrt(@($result).Count))))
      }
      if ($AllStats -or $RecentModifiedDirectories) {
        $id++
        Write-Progress -Activity 'Calculate recent modified directories' -Id $id
        $result = $_ | Get-ChildItem -Directory -Recurse:$Recurse -Force -Depth:$Depth | ForEach-Object { ConvertTo-FileSystemInfo -InputObject $_ }
        $measure.RecentModifiedDirectories = $result | Sort-Object -Property LastWriteTime -Descending -Top ([Math]::Max(1, [Math]::Ceiling([Math]::Sqrt(@($result).Count))))
      }
      if ($AllStats -or $LargeFiles) {
        $id++
        Write-Progress -Activity 'Calculate large files' -Id $id
        $result = $_ | Get-ChildItem -File -Recurse:$Recurse -Force -Depth:$Depth | ForEach-Object { ConvertTo-FileSystemInfo -InputObject $_ }
        $measure.LargeFiles = $result | Sort-Object -Property Length -Descending -Top ([Math]::Max(1, [Math]::Ceiling([Math]::Sqrt(@($result).Count))))
      }
      if ($AllStats -or $LargeDirectories) {
        $id++
        Write-Progress -Activity 'Calculate large directories' -Id $id
        $result = $_ | Get-ChildItem -Directory -Recurse:$Recurse -Force -Depth:$Depth |
        ForEach-Object {
          $size = ($_ | Get-ChildItem -File -Recurse -Force | Measure-Object -Property Length -Sum)?.Sum
          $_ | Add-Member -NotePropertyName TotalSize -NotePropertyValue ($size ?? 0) -Force
          return $_
        } |
        ForEach-Object { ConvertTo-FileSystemInfo -InputObject $_ }
        $measure.LargeDirectories = $result | Sort-Object -Property TotalSize -Descending -Top ([Math]::Max(1, [Math]::Ceiling([Math]::Sqrt(@($result).Count))))
      }
      if ($AllStats -or $LongNames) {
        $id++
        Write-Progress -Activity 'Calculate long names' -Id $id
        $result = $_ | Get-ChildItem -Recurse:$Recurse -Force -Depth:$Depth | ForEach-Object { ConvertTo-FileSystemInfo -InputObject $_ }
        $measure.LongNames = $result | Sort-Object { $_.Name.Length } -Descending -Top ([Math]::Ceiling([Math]::Sqrt(@($result).Count)))
      }
      if ($AllStats -or $SimilarNames) {
        $directories = $_ |
        Get-ChildItem -Directory -Force |
        ForEach-Object { ConvertTo-FileSystemInfo -InputObject $_ } |
        Sort-Object -Property CreationTime, LastWriteTime
        if (@($directories).Count -lt 2) {
          continue
        }
        $id++
        $total = $directories.Count * ($directories.Count - 1) / 2
        $k = 0
        $pairs = for ($i = 0; $i -lt $directories.Count; $i++) {
          for ($j = $i + 1; $j -lt $directories.Count; $j++) {
            $k++
            Write-Progress -Activity 'Calculate similarity' -Status "Processing $k of $total" -Id $id -PercentComplete ($k / $total * 100)
            $olderItem = $directories[$i]
            $newerItem = $directories[$j]
            [SimilarDirectoryInfo]@{
              Similarity = [StringMetrics.LCS]::Similarity($olderItem.Name, $newerItem.Name)
              OlderItem  = $olderItem
              NewerItem  = $newerItem
            }
          }
        }
        $measure.SimilarNames = $pairs | Sort-Object -Property Similarity -Descending -Top ([Math]::Max(1, [Math]::Ceiling([Math]::Sqrt(@($pairs).Count))))
      }
      return $measure
    }
  }
  clean {
    Write-Progress -Completed
  }
}
function Set-ItemAttribute {
  <#
  .SYNOPSIS
    Sets one or more file or directory attributes.

  .DESCRIPTION
    Set-ItemAttribute updates the specified item's file attributes by adding the
    requested attribute flags. It supports wildcards via `-Path` and literal paths
    via `-LiteralPath`, and uses `ShouldProcess` so that `-WhatIf` is supported.

  .PARAMETER Path
    Specifies one or more paths to files or directories. Wildcards are supported.

  .PARAMETER LiteralPath
    Specifies one or more literal paths to files or directories.

  .PARAMETER Attribute
    The file attribute flag(s) to add to the target item.

  .PARAMETER Force
    Forces the attribute update even if the item already has the requested attribute. If not specified, skips items that already have the attribute.

  .EXAMPLE
    ``` powershell
    Set-ItemAttribute -Path 'C:\dir\*' -Attribute ReadOnly
    ```

    Sets the ReadOnly attribute on every matching item.

  .EXAMPLE
    ``` powershell
    Set-ItemAttribute -LiteralPath 'C:\dir\file.txt' -Attribute Hidden -Force
    ```

  .OUTPUTS
    None.

  .NOTES
    This cmdlet modifies file system object attributes and does not emit output when the operation succeeds.
  #>
  [CmdletBinding(DefaultParameterSetName = 'PathSet', SupportsShouldProcess)]
  [OutputType([void])]
  param (
    [Parameter(Mandatory, ParameterSetName = 'PathSet', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [SupportsWildcards()]
    [ValidateScript({ Test-Path -Path $_ })]
    [string[]]
    $Path,
    [Alias('PSPath', 'LP')]
    [Parameter(Mandatory, ParameterSetName = 'LiteralPathSet', ValueFromPipelineByPropertyName)]
    [ValidateScript({ Test-Path -LiteralPath $_ })]
    [string[]]
    $LiteralPath,
    [Parameter(Mandatory, Position = 1)]
    [FileAttributes]
    $Attribute,
    [switch]
    $Force
  )
  process {
    $items = @(
      switch -Exact -CaseSensitive ($PSCmdlet.ParameterSetName) {
        'PathSet' {
          Get-Item -Path $Path -Force
        }
        'LiteralPathSet' {
          Get-Item -LiteralPath $LiteralPath -Force
        }
      }
    )
    $items |
    ForEach-Object {
      $attributes = $_.Attributes -bor $Attribute
      if ($_.Attributes -eq $attributes -and -not $Force) {
        Write-Warning -Message "$_ already has the specified attributes."
        return
      }
      $target = @(
        "Item: $($_.FullName)"
        "Attribute: $(([enum]::GetValues([FileAttributes]) | Where-Object { $attributes.HasFlag($_) }) -join ',')"
      ) -join ', '
      $action = "Set Attribute $($_.PSIsContainer ? 'Directory' : 'File')"
      if (-not (($Force -and -not $WhatIfPreference) -or $PSCmdlet.ShouldProcess($target, $action))) {
        return
      }
      $_.Attributes = $attributes
    }
  }
}
function Remove-ItemAttribute {
  <#
  .SYNOPSIS
    Removes one or more file or directory attributes.

  .DESCRIPTION
    Remove-ItemAttribute clears the specified attribute flags from the target item.
    It supports wildcards via `-Path` and literal paths via `-LiteralPath`,
    and honors `ShouldProcess` so that `-WhatIf` can be used safely.

  .PARAMETER Path
    Specifies one or more paths to files or directories. Wildcards are supported.

  .PARAMETER LiteralPath
    Specifies one or more literal paths to files or directories.

  .PARAMETER Attribute
    The file attribute flag(s) to remove from the target item.

  .PARAMETER Force
    Forces the attribute removal even if the item does not have the requested attribute. If not specified, skips items that do not have the attribute.

  .EXAMPLE
    ``` powershell
    Remove-ItemAttribute -Path 'C:\dir\*' -Attribute ReadOnly
    ```

    Removes the ReadOnly attribute from every matching item.

  .EXAMPLE
    ``` powershell
    Remove-ItemAttribute -LiteralPath 'C:\dir\file.txt' -Attribute Hidden -Force
    ```

  .OUTPUTS
    None.

  .NOTES
    This cmdlet modifies file system object attributes and does not emit output when the operation succeeds.
  #>
  [CmdletBinding(DefaultParameterSetName = 'PathSet', SupportsShouldProcess)]
  [OutputType([void])]
  param (
    [Parameter(Mandatory, ParameterSetName = 'PathSet', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [SupportsWildcards()]
    [string[]]
    $Path,
    [Alias('PSPath', 'LP')]
    [Parameter(Mandatory, ParameterSetName = 'LiteralPathSet', ValueFromPipelineByPropertyName)]
    [string[]]
    $LiteralPath,
    [Parameter(Mandatory)]
    [FileAttributes]
    $Attribute,
    [switch]
    $Force
  )
  process {
    $items = @(
      switch -Exact -CaseSensitive ($PSCmdlet.ParameterSetName) {
        'PathSet' {
          Get-Item -Path $Path -Force
        }
        'LiteralPathSet' {
          Get-Item -LiteralPath $LiteralPath -Force
        }
      }
    )
    $items |
    ForEach-Object {
      $attributes = $_.Attributes -band (-bnot $Attribute)
      if ($_.Attributes -eq $attributes -and -not $Force) {
        Write-Warning -Message "$_ no longer has the specified attributes."
        return
      }
      $target = @(
        "Item: $($_.FullName)"
        "Attribute: $(([enum]::GetValues([FileAttributes]) | Where-Object { $attributes.HasFlag($_) }) -join ',')"
      ) -join ', '
      $action = "Remove Attribute $($_.PSIsContainer ? 'Directory' : 'File')"
      if (-not (($Force -and -not $WhatIfPreference) -or $PSCmdlet.ShouldProcess($target, $action))) {
        return
      }
      $_.Attributes = $attributes
    }
  }
}
function Set-ItemDate {
  <#
  .SYNOPSIS
    Sets or fixes file and directory timestamps, optionally using EXIF data.

  .DESCRIPTION
    The Set-ItemDate command sets CreationTime, LastWriteTime, and LastAccessTime for files or directories. You can set all timestamps at once, set them individually, or update them from EXIF metadata. Supports wildcards and literal paths. If CreationTime is later than LastWriteTime, TimeFix will automatically correct it.

  .PARAMETER Path
    Path(s) to the target file(s) or directory(ies). Wildcards supported.

  .PARAMETER LiteralPath
    Literal path(s) to the target file(s) or directory(ies). Wildcards are not interpreted.

  .PARAMETER Date
    Sets all timestamps (CreationTime, LastWriteTime, LastAccessTime) to the specified date and time.

  .PARAMETER CreationTime
    Sets only the CreationTime property.

  .PARAMETER LastWriteTime
    Sets only the LastWriteTime property.

  .PARAMETER LastAccessTime
    Sets only the LastAccessTime property.

  .PARAMETER TimeFix
    If CreationTime is later than LastWriteTime, sets CreationTime to LastWriteTime.

  .PARAMETER UseExif
    Updates timestamps from EXIF metadata for supported files (e.g., images with EXIF data).

  .PARAMETER Force
    Forces setting timestamps even if the item is read-only or otherwise protected.

  .EXAMPLE
    ``` powershell
    Set-ItemDate -Path 'C:\file.txt' -Date (Get-Date)
    ```
    Sets all timestamps of file.txt to the current date and time.

  .EXAMPLE
    ``` powershell
    Set-ItemDate -Path 'C:\image.jpg' -UseExif
    ```
    Sets timestamps of image.jpg from its EXIF metadata.

  .OUTPUTS
    None.

  .NOTES
    This function supports ShouldProcess and can be used with-WhatIf and -Confirm.
  #>
  [CmdletBinding(DefaultParameterSetName = 'AllDatesPathSet', SupportsShouldProcess)]
  [OutputType([void])]
  param (
    [Parameter(Mandatory, ParameterSetName = 'AllDatesPathSet', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Parameter(Mandatory, ParameterSetName = 'EachDatePathSet', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Parameter(Mandatory, ParameterSetName = 'ExifDatePathSet', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [SupportsWildcards()]
    [ValidateScript({ Test-Path -Path $_ })]
    [string[]]
    $Path,
    [Alias('PSPath', 'LP')]
    [Parameter(Mandatory, ParameterSetName = 'AllDatesLiteralPathSet', ValueFromPipelineByPropertyName)]
    [Parameter(Mandatory, ParameterSetName = 'EachDateLiteralPathSet', ValueFromPipelineByPropertyName)]
    [Parameter(Mandatory, ParameterSetName = 'ExifDateLiteralPathSet', ValueFromPipelineByPropertyName)]
    [ValidateScript({ Test-Path -LiteralPath $_ })]
    [string[]]
    $LiteralPath,
    [Parameter(Mandatory, ParameterSetName = 'AllDatesPathSet', Position = 1)]
    [Parameter(Mandatory, ParameterSetName = 'AllDatesLiteralPathSet', Position = 1)]
    [datetime]
    $Date,
    [Parameter(ParameterSetName = 'EachDatePathSet')]
    [Parameter(ParameterSetName = 'EachDateLiteralPathSet')]
    [Nullable[datetime]]
    $CreationTime,
    [Parameter(ParameterSetName = 'EachDatePathSet')]
    [Parameter(ParameterSetName = 'EachDateLiteralPathSet')]
    [Nullable[datetime]]
    $LastWriteTime,
    [Parameter(ParameterSetName = 'EachDatePathSet')]
    [Parameter(ParameterSetName = 'EachDateLiteralPathSet')]
    [Nullable[datetime]]
    $LastAccessTime,
    [Parameter(ParameterSetName = 'AllDatesPathSet')]
    [Parameter(ParameterSetName = 'AllDatesLiteralPathSet')]
    [Parameter(ParameterSetName = 'EachDatePathSet')]
    [Parameter(ParameterSetName = 'EachDateLiteralPathSet')]
    [switch]
    $TimeFix,
    [Parameter(ParameterSetName = 'ExifDatePathSet')]
    [Parameter(ParameterSetName = 'ExifDateLiteralPathSet')]
    [switch]
    $UseExif,
    [switch]
    $Force
  )
  process {
    if ($PSCmdlet.ParameterSetName -in 'AllDatesPathSet', 'AllDatesLiteralPathSet') {
      $CreationTime = $Date
      $LastWriteTime = $Date
      $LastAccessTime = $Date
    }
    $items = @(
      switch -Exact -CaseSensitive ($PSCmdlet.ParameterSetName) {
        { $_ -in 'AllDatesPathSet', 'EachDatePathSet', 'ExifDatePathSet' } {
          Get-Item -Path $Path -Force
        }
        { $_ -in 'AllDatesLiteralPathSet', 'EachDateLiteralPathSet', 'ExifDateLiteralPathSet' } {
          Get-Item -LiteralPath $LiteralPath -Force
        }
      }
    )
    $target = if ($PSCmdlet.ParameterSetName -in 'AllDatesPathSet', 'EachDatePathSet', 'ExifDatePathSet') {
      $Path -join ', '
    } else {
      $LiteralPath -join ', '
    }
    if ($UseExif) {
      if (-not (($Force -and -not $WhatIfPreference) -or $PSCmdlet.ShouldProcess($target, 'Set timestamps from EXIF data.'))) {
        return
      }
      $items |
      Get-ExifDate |
      ForEach-Object {
        if ($_.CreationTime) {
          Set-ItemProperty -LiteralPath $_.Path -Name 'CreationTime' -Value $_.CreationTime -Force:$Force -WhatIf:$WhatIfPreference -Confirm:$false
        }
        if ($_.LastWriteTime) {
          Set-ItemProperty -LiteralPath $_.Path -Name 'LastWriteTime' -Value $_.LastWriteTime -Force:$Force -WhatIf:$WhatIfPreference -Confirm:$false
        }
      }
    } else {
      if ($CreationTime) {
        $target += ", CreationTime: $CreationTime"
      }
      if ($LastWriteTime) {
        $target += ", LastWriteTime: $LastWriteTime"
      }
      if ($LastAccessTime) {
        $target += ", LastAccessTime: $LastAccessTime"
      }
      if (-not (($Force -and -not $WhatIfPreference) -or $PSCmdlet.ShouldProcess($target, 'Set specified timestamps.'))) {
        return
      }
      if ($CreationTime) {
        $items |
        Set-ItemProperty -Name 'CreationTime' -Value $CreationTime -Force:$Force -WhatIf:$WhatIfPreference -Confirm:$false
      }
      if ($LastWriteTime) {
        $items |
        Set-ItemProperty -Name 'LastWriteTime' -Value $LastWriteTime -Force:$Force -WhatIf:$WhatIfPreference -Confirm:$false
      }
      if ($LastAccessTime) {
        $items |
        Set-ItemProperty -Name 'LastAccessTime' -Value $LastAccessTime -Force:$Force -WhatIf:$WhatIfPreference -Confirm:$false
      }
    }
    if ($TimeFix) {
      $items |
      ForEach-Object {
        $fixedCreationTime = $CreationTime ?? (Get-ItemPropertyValue -LiteralPath $_ -Name 'CreationTime')
        $fixedLastWriteTime = $LastWriteTime ?? (Get-ItemPropertyValue -LiteralPath $_ -Name 'LastWriteTime')
        if ($fixedCreationTime -gt $fixedLastWriteTime) {
          $_ | Set-ItemProperty -Name 'CreationTime' -Value $fixedLastWriteTime -Force:$Force -WhatIf:$WhatIfPreference -Confirm:$false
        }
      }
    }
  }
}
function Sync-DirectoryDate {
  <#
  .SYNOPSIS
    Synchronizes directory timestamps from child file timestamps.

  .DESCRIPTION
    Sync-DirectoryDate updates the CreationTime, LastWriteTime, and LastAccessTime of one or more directories
    based on the timestamps of child files. The command computes the earliest CreationTime and the latest
    LastWriteTime and LastAccessTime among all nested files, then applies those values to each target directory.
    If a directory contains no files, the command writes a warning and does not modify that directory.

  .PARAMETER Path
    Path(s) to target directories. Wildcards supported.

  .PARAMETER LiteralPath
    Literal path(s) to target directories. Wildcards are not interpreted.

  .PARAMETER Force
    Forces child enumeration and timestamp sync for protected files.

  .EXAMPLE
    ``` powershell
    Sync-DirectoryDate -Path 'C:\dir\*'
    ```

    Synchronizes timestamps for every matching directory.

  .EXAMPLE
    ``` powershell
    Sync-DirectoryDate -LiteralPath 'C:\dir\subdir' -Force
    ```

  .OUTPUTS
    None.
  #>
  [CmdletBinding(DefaultParameterSetName = 'PathSet', SupportsShouldProcess)]
  [OutputType([void])]
  param (
    [Parameter(Mandatory, ParameterSetName = 'PathSet', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [SupportsWildcards()]
    [ValidateScript({ Test-Path -Path $_ })]
    [string[]]
    $Path,
    [Alias('PSPath', 'LP')]
    [Parameter(Mandatory, ParameterSetName = 'LiteralPathSet', ValueFromPipelineByPropertyName)]
    [ValidateScript({ Test-Path -LiteralPath $_ })]
    [string[]]
    $LiteralPath,
    [switch]
    $Force
  )
  process {
    $items = @(
      switch -Exact -CaseSensitive ($PSCmdlet.ParameterSetName) {
        'PathSet' {
          Get-Item -Path $Path -Force
        }
        'LiteralPathSet' {
          Get-Item -LiteralPath $LiteralPath -Force
        }
      }
    )
    $items |
    ForEach-Object {
      $children = @($_ | Get-ChildItem -File -Recurse -Force:$Force)
      if ($children.Count -eq 0) {
        Write-Warning -Message "$_ is empty."
        return
      }
      $creationTime = ($children | Measure-Object -Property 'CreationTime' -Minimum)?.Minimum
      $lastWriteTime = ($children | Measure-Object -Property 'LastWriteTime' -Maximum)?.Maximum
      $lastAccessTime = ($children | Measure-Object -Property 'LastAccessTime' -Maximum)?.Maximum
      if (-not (($Force -and -not $WhatIfPreference) -or $PSCmdlet.ShouldProcess("$_", 'Sync directory timestamps from child items'))) {
        return
      }
      $_ | Set-ItemDate -CreationTime $creationTime -LastWriteTime $lastWriteTime -LastAccessTime $lastAccessTime -TimeFix -Force:$Force
    }
  }
}
function Sync-ItemDate {
  <#
  .SYNOPSIS
    Bulk synchronizes and fixes timestamps for files and directories.

  .DESCRIPTION
    Sync-ItemDate unblocks and fixes timestamps for files or directories, updates file timestamps using EXIF data when available, and synchronizes directory timestamps to match nested child items. The command processes each target path, updates file timestamps, and then refreshes directory timestamps for any nested directories.

  .PARAMETER Path
    Path(s) to the target file(s) or directory(ies). Wildcards supported.

  .PARAMETER LiteralPath
    Literal path(s) to the target file(s) or directory(ies). Wildcards are not interpreted.

  .PARAMETER Force
    Forces timestamp synchronization for protected items and suppresses ShouldProcess confirmation.

  .EXAMPLE
    ``` powershell
    Sync-ItemDate -LiteralPath 'C:\dir\subdir'
    ```

    Synchronizes the timestamp of subdir with its contents.

  .EXAMPLE
    ``` powershell
    Sync-ItemDate -Path 'C:\dir\*' -Force
    ```

  .OUTPUTS
    None.

  .NOTES
    This function supports ShouldProcess and can be used with-WhatIf and -Confirm. When -Force is provided, the operation proceeds without confirmation.
  #>
  [CmdletBinding(DefaultParameterSetName = 'PathSet', SupportsShouldProcess)]
  [OutputType([void])]
  param (
    [Parameter(Mandatory, ParameterSetName = 'PathSet', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [SupportsWildcards()]
    [ValidateScript({ Test-Path -Path $_ })]
    [string[]]
    $Path,
    [Alias('PSPath', 'LP')]
    [Parameter(Mandatory, ParameterSetName = 'LiteralPathSet', ValueFromPipelineByPropertyName)]
    [ValidateScript({ Test-Path -LiteralPath $_ })]
    [string[]]
    $LiteralPath,
    [switch]
    $Force
  )
  process {
    $items = @(
      switch -Exact -CaseSensitive ($PSCmdlet.ParameterSetName) {
        'PathSet' {
          Get-Item -Path $Path -Force
        }
        'LiteralPathSet' {
          Get-Item -LiteralPath $LiteralPath -Force
        }
      }
    )
    if (-not (($Force -and -not $WhatIfPreference) -or $PSCmdlet.ShouldProcess("Processing $($items.Count) item(s)", 'Bulk synchronize and fix timestamps'))) {
      return
    }
    $id = 0
    $files = @(
      $items |
      ForEach-Object {
        $item = $_ | Get-Item -Force:$Force
        if ($item.PSIsContainer) {
          $_ | Get-ChildItem -File -Recurse -Force:$Force
        } else {
          $item
        }
      }
    )
    $directories = @(
      $items |
      Where-Object { $_.PSIsContainer } |
      ForEach-Object {
        , ($_ | Get-Item -Force:$Force) + ($_ | Get-ChildItem -Directory -Recurse -Force:$Force)
      }
    )
    # Step 1: Unblock files and set file timestamps.
    $id++
    $count = 0
    $digit = ([string]$files.Count).Length
    $files |
    ForEach-Object {
      $status = "{0:D$digit} / {1:D$digit}" -f $count++, $files.Count
      $percent = $count / $files.Count * 100
      Write-Progress -Activity "#$id Unblock files." -Status $status -Id $id -PercentComplete $percent
      try {
        Unblock-File -LiteralPath $_
      } catch {
        Write-Warning -Message $_.Exception.Message
      }
      if (Test-PdfExtension -LiteralPath $_) {
        try {
          Unblock-Pdf -LiteralPath $_
        } catch {
          Write-Warning -Message $_.Exception.Message
        }
      }
      try {
        if (Test-ArchiveExtension -LiteralPath $_) {
          try {
            Sync-ArchivedItemDate -LiteralPath $_
          } catch {
            Write-Warning -Message $_.Exception.Message
          }
        } else {
          Set-ItemDate -LiteralPath $_ -TimeFix -Force:$Force
        }
      } catch {
        Write-Warning -Message $_.Exception.Message
      }
    }
    # Step 2: Update file timestamps based on EXIF data.
    $id++
    $count = 0
    $digit = ([string]$items.Count).Length
    $items |
    ForEach-Object {
      $status = "{0:D$digit} / {1:D$digit}" -f $count++, $items.Count
      $percent = $count / $items.Count * 100
      Write-Progress -Activity "#$id Update file timestamps." -Status $status -Id $id -PercentComplete $percent
      return $_
    } -PipelineVariable root |
    Get-ExifDate -Recurse |
    Where-Object { Test-Path -LiteralPath $_.Path } |
    ForEach-Object {
      if ($_.CreationTime -or $_.LastWriteTime) {
        if (-not (Test-Path -LiteralPath $root.FullName -PathType Container)) {
          $_.Path | Out-Host
        } else {
          Resolve-Path -LiteralPath $_.Path -Relative -RelativeBasePath ([WildcardPattern]::Escape($root.FullName)) | Out-Host
        }
        Set-ItemDate -LiteralPath $_.Path -CreationTime $_.CreationTime -LastWriteTime $_.LastWriteTime -TimeFix -Force:$Force
      }
    }
    # Step 3: Update directory timestamps based on child item timestamps.
    $id++
    $count = 0
    $digit = ([string]$directories.Count).Length
    $directories |
    ForEach-Object {
      $status = "{0:D$digit} / {1:D$digit}" -f $count++, $directories.Count
      $percent = $count / $directories.Count * 100
      Write-Progress -Activity "#$id Update directory timestamps." -Status $status -Id $id -PercentComplete $percent
      try {
        Sync-DirectoryDate -LiteralPath $_ -Force:$Force
      } catch {
        Write-Warning -Message $_.Exception.Message
      }
    }
  }
}
function Export-ItemDate {
  <#
  .SYNOPSIS
    Exports file and directory timestamps to a JSON file.

  .DESCRIPTION
    Export-ItemDate reads the CreationTime, LastWriteTime, and LastAccessTime of one or more
    files or directories specified by Path or LiteralPath and writes them to a JSON file
    specified by Destination. The command supports wildcards via -Path and literal paths via
    -LiteralPath. When an input item is a directory, the command recursively enumerates every
    file within it, including files in subfolders, and exports each file's timestamps. The
    Path property in the JSON output is written as a path relative to a base directory.
    When the input is a directory, the base directory is the parent of that directory, so the
    exported paths include the directory name (for example 'dir\file.txt'). When the input is
    one or more files, the base directory is their common parent directory, so the data can be
    re-applied on another machine or under a different root. Use -Force to overwrite an existing
    destination file, or -NoClobber to fail if the destination already exists.

  .PARAMETER Path
    Path(s) to the target file(s) or directory(ies). Wildcards supported. When a directory is
    specified, all files within it are exported recursively, including files in subfolders.

  .PARAMETER LiteralPath
    Literal path(s) to the target file(s) or directory(ies). Wildcards are not interpreted.
    When a directory is specified, all files within it are exported recursively, including
    files in subfolders.

  .PARAMETER Destination
    Specifies the path of the JSON file to write the timestamp data to. When -Destination is
    supplied, all inputs are written to that single file. When -Destination is omitted, each
    input directory is written to its own '{folder name}.json' in the parent folder of that
    directory, and the function returns one path per directory. If any input is a file,
    -Destination is mandatory and omitting it throws an error.

  .PARAMETER Force
    If specified, overwrites the destination file if it already exists.

  .PARAMETER NoClobber
    If specified, the function will fail if the destination file already exists.

  .EXAMPLE
    ``` powershell
    Export-ItemDate -Path 'C:\dir\*' -Destination 'C:\Temp\timestamps.json'
    ```

    Exports timestamps for every matching item to a JSON file.

  .EXAMPLE
    ``` powershell
    Export-ItemDate -LiteralPath 'C:\dir\file.txt' -Destination 'C:\Temp\timestamps.json' -Force
    ```

    Exports file.txt timestamps and overwrites an existing JSON file.

  .EXAMPLE
    ``` powershell
    Export-ItemDate -LiteralPath 'C:\dir' -Destination 'C:\Temp\timestamps.json'
    ```

    Exports the CreationTime, LastWriteTime, and LastAccessTime of every file under C:\dir,
    including files in subfolders, to a single JSON file.

  .OUTPUTS
    System.IO.FileInfo[]. Returns one FileInfo object per output file. When -Destination is
    supplied, a single-element array is returned. When -Destination is omitted, one element is
    returned per input directory.

  .NOTES
    This function supports ShouldProcess and can be used with -WhatIf and -Confirm.
  #>
  [CmdletBinding(DefaultParameterSetName = 'PathSet', SupportsShouldProcess)]
  [OutputType([System.IO.FileInfo[]])]
  param (
    [Parameter(Mandatory, ParameterSetName = 'PathSet', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [SupportsWildcards()]
    [ValidateScript({ Test-Path -Path $_ })]
    [string[]]
    $Path,
    [Alias('PSPath', 'LP')]
    [Parameter(Mandatory, ParameterSetName = 'LiteralPathSet', ValueFromPipelineByPropertyName)]
    [ValidateScript({ Test-Path -LiteralPath $_ })]
    [string[]]
    $LiteralPath,
    [ValidateScript({ (Test-Path -LiteralPath $_ -IsValid) -and -not (Test-Path -LiteralPath $_ -PathType Container) })]
    [string]
    $Destination,
    [switch]
    $Force,
    [switch]
    $NoClobber
  )
  process {
    $roots = @(
      switch -Exact -CaseSensitive ($PSCmdlet.ParameterSetName) {
        'PathSet' {
          Get-Item -Path $Path -Force
        }
        'LiteralPathSet' {
          Get-Item -LiteralPath $LiteralPath -Force
        }
      }
    )
    if ([string]::IsNullOrEmpty($Destination)) {
      if ($roots | Where-Object { -not $_.PSIsContainer }) {
        $PSCmdlet.ThrowTerminatingError([ErrorRecord]::new(
            [ArgumentException]::new('Destination is required when the input is a file. Specify -Destination or export a directory instead.')
            , 'DestinationRequiredForFile'
            , [ErrorCategory]::InvalidArgument
            , $roots
          ))
      }
    }
    $target = if ($PSCmdlet.ParameterSetName -eq 'PathSet') {
      $Path -join ', '
    } else {
      $LiteralPath -join ', '
    }
    if (-not (($Force -and -not $WhatIfPreference) -or $PSCmdlet.ShouldProcess($target, 'Export item timestamps to JSON'))) {
      return
    }
    $results = @()
    foreach ($root in $roots) {
      $outputPath = if ([string]::IsNullOrEmpty($Destination)) {
        Join-Path -Path ([Path]::GetDirectoryName($root.FullName)) -ChildPath "$($root.Name).json"
      } else {
        $Destination
      }
      if ((Test-Path -LiteralPath $outputPath -PathType Container) -or ((Test-Path -LiteralPath $outputPath -PathType Leaf) -and $NoClobber)) {
        $PSCmdlet.ThrowTerminatingError([ErrorRecord]::new(
            [IOException]::new("$outputPath already exists. Use -Force to overwrite the file.")
            , 'ItemAlreadyExists'
            , [ErrorCategory]::ResourceExists
            , $outputPath
          ))
      }
      $isReadOnly = (Test-Path -LiteralPath $outputPath -PathType Leaf) -and (Get-Item -LiteralPath $outputPath -Force).IsReadOnly
      if ($isReadOnly -and $Force) {
        (Get-Item -LiteralPath $outputPath -Force).IsReadOnly = $false
      }
      $items = if ($root.PSIsContainer) {
        $root | Get-ChildItem -File -Recurse -Force:$Force
      } else {
        $root
      }
      $directory = [Path]::GetDirectoryName($root.FullName)
      $records = @(
        $items |
        ForEach-Object {
          [ItemDate]@{
            Path           = [Path]::GetRelativePath($directory, $_.FullName)
            CreationTime   = $_.CreationTime
            LastWriteTime  = $_.LastWriteTime
            LastAccessTime = $_.LastAccessTime
            Hash           = ($_ | Get-FileHash -Algorithm SHA256).Hash
          }
        }
      )
      $json = $records | ConvertTo-Json
      $json | Set-Content -LiteralPath $outputPath -Encoding UTF8 -Force:$Force -WhatIf:$WhatIfPreference -Confirm:$false
      if ($isReadOnly -and $Force) {
        (Get-Item -LiteralPath $outputPath -Force).IsReadOnly = $true
      }
      $results += Get-Item -LiteralPath $outputPath -Force
    }
    return $results
  }
}
function Import-ItemDate {
  <#
  .SYNOPSIS
    Imports file and directory timestamps from a JSON file.

  .DESCRIPTION
    Import-ItemDate reads one or more JSON files produced by Export-ItemDate and applies the
    CreationTime, LastWriteTime, and LastAccessTime values to each corresponding
    file or directory. When a record's Path property is a relative path, it is
    interpreted as relative to the folder that contains the JSON file, so the data
    exported by Export-ItemDate can be re-applied under the same relative layout.
    The command supports -WhatIf and -Confirm via ShouldProcess, and -Force to set
    timestamps on read-only items. By default the command does not emit output; use
    -PassThru to return each successfully updated file as a FileInfo object.

  .PARAMETER Path
    Path(s) to the JSON file(s) that contain the timestamp data. Accepts an array of paths.

  .PARAMETER Force
    If specified, sets timestamps on read-only items.

  .PARAMETER PassThru
    If specified, returns the FileInfo object for each successfully updated file.

  .EXAMPLE
    ``` powershell
    Import-ItemDate -Path 'C:\Temp\timestamps.json'
    ```

    Restores timestamps from timestamps.json.

  .EXAMPLE
    ``` powershell
    Import-ItemDate -Path 'C:\Temp\timestamps.json' -Force
    ```

    Restores timestamps from timestamps.json, including protected files.

  .EXAMPLE
    ``` powershell
    Import-ItemDate -Path @('C:\Temp\a.json', 'C:\Temp\b.json')
    ```

    Restores timestamps from both JSON files.

  .EXAMPLE
    ``` powershell
    Import-ItemDate -Path 'C:\Temp\timestamps.json' -PassThru
    ```

    Applies the timestamp data and returns the FileInfo objects for the updated files.

  .OUTPUTS
    None by default. When -PassThru is specified, returns System.IO.FileInfo objects
    for each successfully updated file.

  .NOTES
    This function supports ShouldProcess and can be used with -WhatIf and -Confirm.
  #>
  [CmdletBinding(DefaultParameterSetName = 'PathSet', SupportsShouldProcess)]
  [OutputType([void])]
  param (
    [Alias('FilePath', 'FullName')]
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateScript({ Test-Path -LiteralPath $_ })]
    [string[]]
    $Path,
    [switch]
    $Force,
    [switch]
    $PassThru
  )
  process {
    foreach ($file in $Path) {
      if (-not (($Force -and -not $WhatIfPreference) -or $PSCmdlet.ShouldProcess($file, 'Import item timestamps from JSON'))) {
        continue
      }
      $records = @(Get-Content -LiteralPath $file -Raw | ConvertFrom-Json)
      $directory = [Path]::GetDirectoryName([Path]::GetFullPath($file))
      foreach ($record in $records) {
        $target = if ([Path]::IsPathRooted($record.Path)) {
          $record.Path
        } else {
          [Path]::Combine($directory, $record.Path)
        }
        if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
          Write-Warning -Message "Skipping '$target' because it does not exist or is not a file."
          continue
        }
        $actualHash = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash
        if ($actualHash -ne $record.Hash) {
          Write-Warning -Message "Skipping '$target' because the file hash does not match (expected: $($record.Hash), actual: $actualHash)."
          continue
        }
        if ($record.CreationTime) {
          Set-ItemProperty -LiteralPath $target -Name 'CreationTime' -Value $record.CreationTime -Force:$Force -WhatIf:$WhatIfPreference -Confirm:$false
        }
        if ($record.LastWriteTime) {
          Set-ItemProperty -LiteralPath $target -Name 'LastWriteTime' -Value $record.LastWriteTime -Force:$Force -WhatIf:$WhatIfPreference -Confirm:$false
        }
        if ($record.LastAccessTime) {
          Set-ItemProperty -LiteralPath $target -Name 'LastAccessTime' -Value $record.LastAccessTime -Force:$Force -WhatIf:$WhatIfPreference -Confirm:$false
        }
        if ($PassThru) {
          Get-Item -LiteralPath $target -Force
        }
      }
    }
  }
}
#endregion
