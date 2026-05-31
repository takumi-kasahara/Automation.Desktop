using namespace System.Globalization
using namespace System.IO

Set-StrictMode -Version Latest

function Get-ExifDate {
  <#
  .SYNOPSIS
    Reads Exif timestamp metadata from image files.

  .DESCRIPTION
    Get-ExifDate reads files specified by Path or LiteralPath, invokes `ExifTool.exe`
    to retrieve Exif date metadata, and returns objects containing `Path`,
    `CreationTime`, and `LastWriteTime` values. It supports recursive file
    enumeration with `-Recurse` and JSON output from ExifTool with `-AsJson`.

  .PARAMETER Path
    Specifies wildcard-compatible file paths to inspect.

  .PARAMETER LiteralPath
    Specifies literal file paths to inspect.

  .PARAMETER Recurse
    Recursively scans child files when the path resolves to a directory.

  .PARAMETER AsJson
    Treats ExifTool output as JSON instead of CSV.

  .EXAMPLE
    Get-ExifDate -Path 'C:\Pictures\*.jpg'

  .EXAMPLE
    Get-ExifDate -LiteralPath 'C:\Pictures\IMG_0001.JPG' -AsJson

  .OUTPUTS
    System.Management.Automation.PathInfo.
      Objects containing the full path and Exif date metadata of each file.

  .NOTES
    This function writes ExifTool stderr output to a temporary log file and
    removes the log file when it remains empty.
  #>
  [CmdletBinding(DefaultParameterSetName = 'PathSet')]
  [OutputType([System.Management.Automation.PathInfo])]
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
    [switch]
    $AsJson
  )
  begin {
    $log = $env:TEMP | Join-Path -ChildPath "ExifTool.$(Get-Date -Format 'yyyyMMddHHmmss').log"
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
    ForEach-Object {
      $parent = [WildcardPattern]::Escape($_.FullName) | Split-Path -Parent
      $arguments = @('-AllDates')
      if ($Recurse) {
        $arguments += '-recurse'
      }
      $output = $AsJson ?
      (ExifTool.exe $_ @arguments -json 2>>$log | ConvertFrom-Json) :
      (ExifTool.exe $_ @arguments -csv 2>>$log | ConvertFrom-Csv)
      $output |
      ForEach-Object {
        if ($_.SourceFile -match 'base64:') {
          Write-Verbose -Message 'Convert from Base64.'
          $b = [Convert]::FromBase64String($_.SourceFile -replace 'base64:')
          $_.SourceFile = [Console]::OutputEncoding.GetString($b)
        }
        if (-not ([Path]::IsPathRooted($_.SourceFile))) {
          $_.SourceFile = $parent | Join-Path -ChildPath $_.SourceFile
        }
        $fmt = 'yyyy:M:d H:m:sK'
        if (@($_ | Get-Member -MemberType NoteProperty) -match 'DateTimeOriginal') {
          $parsed = Get-Date
          $_.DateTimeOriginal = ([datetime]::TryParseExact($_.DateTimeOriginal, $fmt, [DateTimeFormatInfo]::InvariantInfo, [DateTimeStyles]::None, [ref]$parsed)) ? $parsed : $null
        }
        else {
          $_ | Add-Member -MemberType NoteProperty -Name 'DateTimeOriginal' -Value $null
        }
        if (@($_ | Get-Member -MemberType NoteProperty) -match 'CreateDate') {
          $parsed = Get-Date
          $_.CreateDate = ([datetime]::TryParseExact($_.CreateDate, $fmt, [DateTimeFormatInfo]::InvariantInfo, [DateTimeStyles]::None, [ref]$parsed)) ? $parsed : $null
        }
        else {
          $_ | Add-Member -MemberType NoteProperty -Name 'CreateDate' -Value $null
        }
        if (@($_ | Get-Member -MemberType NoteProperty) -match 'ModifyDate') {
          $parsed = Get-Date
          $_.ModifyDate = ([datetime]::TryParseExact($_.ModifyDate, $fmt, [DateTimeFormatInfo]::InvariantInfo, [DateTimeStyles]::None, [ref]$parsed)) ? $parsed : $null
        }
        else {
          $_ | Add-Member -MemberType NoteProperty -Name 'ModifyDate' -Value $null
        }
        $result = Resolve-Path -LiteralPath $_.SourceFile
        $result | Add-Member -MemberType NoteProperty -Name 'CreationTime' -Value ($_.DateTimeOriginal ?? $_.CreateDate)
        $result | Add-Member -MemberType NoteProperty -Name 'LastWriteTime' -Value $_.ModifyDate
        return $result
      }
    }
  }
  clean {
    if (Test-Path -LiteralPath $log) {
      if (@(Get-Content -LiteralPath $log).Count -gt 0) {
        "LOG:`t$log" | Out-Host
      }
      else {
        Remove-Item -LiteralPath $log -Force
      }
    }
  }
}
function Set-ExifDate {
  <#
  .SYNOPSIS
    Sets Exif timestamps on image files.

  .DESCRIPTION
    Set-ExifDate updates image files specified by Path or LiteralPath with a
    supplied timestamp. It invokes `ExifTool.exe` with `-AllDates` and supports
    recursive file enumeration with `-Recurse`. The function uses `SupportsShouldProcess`
    to allow previewing changes with `-WhatIf`.

  .PARAMETER Path
    Specifies wildcard-compatible file paths to update.

  .PARAMETER LiteralPath
    Specifies literal file paths to update.

  .PARAMETER Date
    Specifies the timestamp to apply to Exif date fields.

  .PARAMETER Recurse
    Recursively processes files when the path resolves to a directory.

  .PARAMETER Force
    Bypasses confirmation prompts from `ShouldProcess`.

  .EXAMPLE
    Set-ExifDate -Path 'C:\Photos\*.jpg' -Date ([datetime]'2024-01-02 03:04:05') -Force

  .EXAMPLE
    Set-ExifDate -LiteralPath 'C:\Photos\IMG_0001.jpg' -Date ([datetime]'2024-01-02 03:04:05') -WhatIf

  .OUTPUTS
    None.
      Only sets Exif timestamps.

  .NOTES
    This function writes ExifTool stderr output to a temporary log file and
    removes the log file when it remains empty.
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
    [datetime]
    $Date,
    [switch]
    $Recurse,
    [switch]
    $Force
  )
  begin {
    $log = $env:TEMP | Join-Path -ChildPath "ExifTool.$(Get-Date -Format 'yyyyMMddHHmmss').log"
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
    ForEach-Object {
      $target = "Item: $($_.FullName)"
      $action = 'Set Exif `AllDates` tag'
      if (-not (($Force -and -not $WhatIfPreference) -or $PSCmdlet.ShouldProcess($target, $action))) {
        return
      }
      $arguments = @("-AllDates=$($Date.ToString('yyyy:MM:d H:m:s'))")
      if ($Recurse) {
        $arguments += '-recurse'
      }
      ExifTool.exe $_ @arguments 2>>$log
    }
  }
  clean {
    if (Test-Path -LiteralPath $log) {
      if (@(Get-Content -LiteralPath $log).Count -gt 0) {
        "LOG:`t$log" | Out-Host
      }
      else {
        Remove-Item -LiteralPath $log -Force
      }
    }
  }
}
function Remove-ExifDate {
  <#
  .SYNOPSIS
    Removes Exif timestamps from image files.

  .DESCRIPTION
    Remove-ExifDate clears Exif date metadata from files specified by Path or
    LiteralPath. It invokes `ExifTool.exe` with `-AllDates=` to remove Exif date
    tags, supports recursive file enumeration with `-Recurse`, and uses
    `SupportsShouldProcess` so changes can be previewed with `-WhatIf`.

  .PARAMETER Path
    Specifies wildcard-compatible file paths to update.

  .PARAMETER LiteralPath
    Specifies literal file paths to update.

  .PARAMETER Recurse
    Recursively processes files when the path resolves to a directory.

  .PARAMETER Force
    Bypasses confirmation prompts from `ShouldProcess`.

  .EXAMPLE
    Remove-ExifDate -Path 'C:\Photos\*.jpg' -Force

  .EXAMPLE
    Remove-ExifDate -LiteralPath 'C:\Photos\IMG_0001.jpg' -WhatIf

  .OUTPUTS
    None. Only removes Exif timestamps.

  .NOTES
    This function writes ExifTool stderr output to a temporary log file and
    removes the log file when it remains empty.
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
    $Recurse,
    [switch]
    $Force
  )
  begin {
    $log = $env:TEMP | Join-Path -ChildPath "ExifTool.$(Get-Date -Format 'yyyyMMddHHmmss').log"
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
    ForEach-Object {
      $target = "Item: $($_.FullName)"
      $action = 'Remove Exif `AllDates` tag'
      if (-not (($Force -and -not $WhatIfPreference) -or $PSCmdlet.ShouldProcess($target, $action))) {
        return
      }
      $arguments = @('-AllDates=')
      if ($Recurse) {
        $arguments += '-recurse'
      }
      ExifTool.exe $_ @arguments 2>>$log
    }
  }
  clean {
    if (Test-Path -LiteralPath $log) {
      if (@(Get-Content -LiteralPath $log).Count -gt 0) {
        "LOG:`t$log" | Out-Host
      }
      else {
        Remove-Item -LiteralPath $log -Force
      }
    }
  }
}
