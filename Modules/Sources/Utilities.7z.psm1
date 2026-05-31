using namespace System.Text

Set-StrictMode -Version Latest

#region Classes
class ArchivedItem {
  [string]$Path
  [Nullable[datetime]]$CreationTime
  [Nullable[datetime]]$LastWriteTime
  [Nullable[datetime]]$LastAccessTime
}
#endregion
#region Public
function Get-ArchivedItem {
  <#
  .SYNOPSIS
    Reads archived file metadata from a 7-Zip archive.

  .DESCRIPTION
    Get-ArchivedItem inspects archive files specified by Path or LiteralPath and
    returns metadata for the items contained in each archive. It invokes
    `7z.exe l -ba -slt -sccUTF-8` to obtain a machine-readable listing, then parses
    each entry's `Path`, `Created`, `Modified`, and `Accessed` values.

  .PARAMETER Path
    Specifies wildcard-compatible archive paths to inspect.

  .PARAMETER LiteralPath
    Specifies literal archive paths to inspect.

  .PARAMETER Encoding
    Specifies the text encoding to use for 7-Zip output.
    When provided, the function passes `-mcp=<codepage>` to `7z.exe`.

  .EXAMPLE
    Get-ArchivedItem -Path 'C:\Archives\*.7z'

  .EXAMPLE
    Get-ArchivedItem -LiteralPath 'C:\Archives\release.7z' -Encoding ([System.Text.Encoding]::UTF8)

  .OUTPUTS
    ArchivedItem. Objects containing the relative path and timestamps of each archived item.

  .NOTES
    This function writes 7-Zip stderr output to a temporary log file and removes
    the log file when it remains empty. It returns `$false` when the archive path
    cannot be found.
  #>
  [CmdletBinding(DefaultParameterSetName = 'PathSet')]
  [OutputType([ArchivedItem])]
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
    [Encoding]
    $Encoding
  )
  begin {
    $log = $env:TEMP | Join-Path -ChildPath "7z.$(Get-Date -Format 'yyyyMMddHHmmss').log"
  }
  process {
    $created = $null
    $modified = $null
    $accessed = $null
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
      $arguments = @('l', $_.FullName, '-ba', '-slt', '-sccUTF-8')
      if ($Encoding) {
        $arguments += "-mcp=$($Encoding.CodePage)"
      }
      7z.exe @arguments 2>>$log |
      ForEach-Object {
        switch -Regex ($_) {
          '^Path = ' {
            $relativePath = $_ -replace $Matches[0], [string]::Empty
          }
          '^Created = ' {
            $created = $_ -replace $Matches[0], [string]::Empty
          }
          '^Modified = ' {
            $modified = $_ -replace $Matches[0], [string]::Empty
          }
          '^Accessed = ' {
            $accessed = $_ -replace $Matches[0], [string]::Empty
          }
          '^$' {
            try {
              return [ArchivedItem]@{
                Path           = $relativePath
                CreationTime   = -not [string]::IsNullOrEmpty($created) ? [datetime]::Parse($created) : $null
                LastWriteTime  = -not [string]::IsNullOrEmpty($modified) ? [datetime]::Parse($modified) : $null
                LastAccessTime = -not [string]::IsNullOrEmpty($accessed) ? [datetime]::Parse($accessed) : $null
              }
            }
            finally {
              $created = $null
              $modified = $null
              $accessed = $null
            }
          }
        }
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
function Sync-ArchivedItemDate {
  <#
  .SYNOPSIS
    Updates a file's timestamp from archive metadata.

  .DESCRIPTION
    Sync-ArchivedItemDate reads archive metadata from Get-ArchivedItem and applies
    the reported creation, modification, and access times to the archive file
    itself. It supports wildcard and literal paths and honors the built-in
    `-WhatIf` common parameter.

  .PARAMETER Path
    Specifies wildcard-compatible archive paths to update.

  .PARAMETER LiteralPath
    Specifies literal archive paths to update.

  .EXAMPLE
    Sync-ArchivedItemDate -Path 'C:\Archive\*.7z'

  .EXAMPLE
    Sync-ArchivedItemDate -LiteralPath 'C:\Archive\release.7z' -WhatIf

  .OUTPUTS
    None. Only updates archive file timestamps.

  .NOTES
    This function uses Get-ArchivedItem to read archive metadata and Set-ItemDate
    to apply timestamps to the archive file.
  #>
  [CmdletBinding(DefaultParameterSetName = 'PathSet', SupportsShouldProcess)]
  [OutputType([void])]
  param (
    [Parameter(Mandatory, ParameterSetName = 'PathSet', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string[]]
    $Path,
    [Alias('PSPath', 'LP')]
    [Parameter(Mandatory, ParameterSetName = 'LiteralPathSet', ValueFromPipelineByPropertyName)]
    [string[]]
    $LiteralPath
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
      $children = @(Get-ArchivedItem -LiteralPath $_)
      if ($children.Count -eq 0) {
        Write-Warning -Message "$($_.FullName) is empty."
        return
      }
      $created = ($children | Measure-Object -Property 'CreationTime' -Minimum)?.Minimum
      $modified = ($children | Measure-Object -Property 'LastWriteTime' -Maximum)?.Maximum
      $accessed = ($children | Measure-Object -Property 'LastAccessTime' -Maximum)?.Maximum
      Set-ItemDate -LiteralPath $_ -CreationTime $created -LastWriteTime $modified -LastAccessTime $accessed -TimeFix -WhatIf:$WhatIfPreference -Confirm:$false
    }
  }
}
#endregion
