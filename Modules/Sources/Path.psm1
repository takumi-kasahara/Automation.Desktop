using namespace Microsoft.VisualBasic
using namespace System.Globalization
using namespace System.IO
using namespace System.Management.Automation
using namespace System.Text

Set-StrictMode -Version Latest

function Compress-EnvironmentVariable {
  <#
  .SYNOPSIS
    Replaces environment variable values in a string with %NAME% tokens.

  .DESCRIPTION
    Compress-EnvironmentVariable scans the input string for environment variable values
    and replaces each occurrence with the corresponding variable name wrapped in percent
    signs (for example, %PATH%). It uses all environment variables from the Env: provider,
    sorting them by the length of their value in descending order to ensure longer values
    are replaced before shorter substrings.

  .PARAMETER InputString
    The string to compress by replacing environment variable values.

  .EXAMPLE
    Compress-EnvironmentVariable -InputString 'Path is C:\Users\User; temp is C:\Temp'

  .EXAMPLE
    Compress-EnvironmentVariable -InputString 'My home is C:\Users\User and path is C:\Users'

  .OUTPUTS
    System.String. The compressed string with environment variables replaced.

  .NOTES
    Empty environment variable values are ignored.
  #>
  [CmdletBinding()]
  [OutputType([string])]
  param(
    [string]
    $InputString
  )
  $envVars = @(Get-ChildItem -LiteralPath Env: | Sort-Object { $_.Value.Length } -Descending)
  foreach ($var in $envVars) {
    if (-not [string]::IsNullOrEmpty($var.Value)) {
      $InputString = $InputString -replace [regex]::Escape($var.Value), "%$($var.Name)%"
    }
  }
  return $InputString
}
function Expand-EnvironmentVariable {
  <#
  .SYNOPSIS
    Expands environment variable references in a string.

  .DESCRIPTION
    Expand-EnvironmentVariable replaces percent-wrapped environment variable names
    like %USERPROFILE% with their current values from the environment.
    If a referenced variable does not exist, the Source token remains unchanged.

  .PARAMETER InputString
    The string containing environment variable references to expand.

  .EXAMPLE
    Expand-EnvironmentVariable -InputString '%USERPROFILE%\Documents'

  .EXAMPLE
    Expand-EnvironmentVariable -InputString 'Path is %PATH%'

  .OUTPUTS
    System.String. The expanded string with environment variables replaced by their values.

  .NOTES
    This function uses the .NET Environment.ExpandEnvironmentVariables method.
  #>
  [CmdletBinding()]
  [OutputType([string])]
  param(
    [string]
    $InputString
  )
  return [Environment]::ExpandEnvironmentVariables($InputString)
}
function ConvertTo-LocalPath {
  <#
  .SYNOPSIS
    Converts a network share path to its local filesystem path.

  .DESCRIPTION
    ConvertTo-LocalPath accepts a UNC path that begins with a share name and
    converts it to the corresponding local path on the current computer.
    When a matching Win32 share is found, the share prefix is replaced with the
    share's local path. Non-UNC paths are returned unchanged after optional
    environment-variable compression.

  .PARAMETER Path
    Specifies wildcard-compatible UNC or local paths to convert.

  .PARAMETER LiteralPath
    Specifies literal UNC or local paths to convert.

  .EXAMPLE
    ConvertTo-LocalPath -Path '\\MYPC\Share\Folder\File.txt'

  .EXAMPLE
    ConvertTo-LocalPath -LiteralPath '\\MYPC\Share\Folder\File.txt'

  .OUTPUTS
    System.String. The converted local path.

  .NOTES
    This function uses Win32 share information from Get-CimInstance.
    It also delegates environment-variable compression to Compress-EnvironmentVariable.
  #>
  [CmdletBinding(DefaultParameterSetName = 'PathSet')]
  [OutputType([string])]
  param (
    [Parameter(Mandatory, ParameterSetName = 'PathSet', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [SupportsWildcards()]
    [string[]]
    $Path,
    [Alias('PSPath', 'LP')]
    [Parameter(Mandatory, ParameterSetName = 'LiteralPathSet', ValueFromPipelineByPropertyName)]
    [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
    [string[]]
    $LiteralPath
  )
  begin {
    try {
      $shares = @(Get-CimInstance -ClassName Win32_Share | Sort-Object { $_.Path.Length } -Descending)
    }
    catch {
      $shares = @()
    }
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
      if ($_.FullName.StartsWith('\\')) {
        foreach ($share in $shares) {
          $shareName = "\\$env:COMPUTERNAME\$($share.Name)"
          if ($_.FullName -like "$shareName\*") {
            $regex = [regex]::Escape("$shareName")
            $substitute = $share.Path.TrimEnd('\')
            $replaced = $_.FullName -replace $regex, $substitute
            return Compress-EnvironmentVariable -InputString $replaced
          }
        }
      }
      return Compress-EnvironmentVariable -InputString $_.FullName
    }
  }
}
function ConvertTo-NetworkPath {
  <#
  .SYNOPSIS
    Converts a local filesystem path to a network share path.

  .DESCRIPTION
    ConvertTo-NetworkPath accepts a local path that begins with a shared folder path and
    converts it to the corresponding UNC path on the current computer.
    If the local path does not match a defined Win32 share, the Source path is returned.

  .PARAMETER Path
    Specifies wildcard-compatible local or UNC paths to convert.

  .PARAMETER LiteralPath
    Specifies literal local or UNC paths to convert.

  .EXAMPLE
    ConvertTo-NetworkPath -Path 'C:\Shared\Folder\File.txt'

  .EXAMPLE
    ConvertTo-NetworkPath -LiteralPath 'C:\Shared\Folder\File.txt'

  .OUTPUTS
    System.String. The converted UNC network path.

  .NOTES
    This function uses Win32 share information from Get-CimInstance.
  #>
  [CmdletBinding(DefaultParameterSetName = 'PathSet')]
  [OutputType([string])]
  param (
    [Parameter(Mandatory, ParameterSetName = 'PathSet', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [SupportsWildcards()]
    [string[]]
    $Path,
    [Alias('PSPath', 'LP')]
    [Parameter(Mandatory, ParameterSetName = 'LiteralPathSet', ValueFromPipelineByPropertyName)]
    [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
    [string[]]
    $LiteralPath
  )
  begin {
    try {
      $shares = @(Get-CimInstance -ClassName Win32_Share | Sort-Object { $_.Path.Length } -Descending)
    }
    catch {
      $shares = @()
    }
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
      if (-not $_.FullName.StartsWith('\\')) {
        foreach ($share in $shares) {
          if ($_.FullName -like "$($share.Path.TrimEnd('\'))\*") {
            $shareName = "\\$env:COMPUTERNAME\$($share.Name)"
            $regex = [regex]::Escape($share.Path.TrimEnd('\'))
            $substitute = $shareName
            $replaced = $_.FullName -replace $regex, $substitute
            return $replaced
          }
        }
      }
      return $_.FullName
    }
  }
}
function ConvertTo-WSLPath {
  <#
  .SYNOPSIS
    Converts a Windows path to a WSL path.

  .DESCRIPTION
    ConvertTo-WSLPath converts a Windows filesystem path into the corresponding
    WSL (Windows Subsystem for Linux) path by invoking `wsl.exe wslpath -a -u`.
    It accepts wildcard and literal paths and returns the converted path string(s).

  .PARAMETER Path
    Specifies wildcard-compatible Windows paths to convert.

  .PARAMETER LiteralPath
    Specifies literal Windows paths to convert.

  .PARAMETER ArgumentList
    Specifies additional arguments passed to `wsl.exe` before `wslpath`.

  .EXAMPLE
    ConvertTo-WSLPath -Path 'C:\Users\User\file.txt'

  .EXAMPLE
    ConvertTo-WSLPath -LiteralPath 'C:\Users\User\file.txt' -ArgumentList '--quiet'

  .NOTES
    This function uses `Get-Item` to resolve the input path and delegates path
    conversion to WSL via `wsl.exe`.

  .OUTPUTS
    String. The converted WSL path.
  #>
  [CmdletBinding(DefaultParameterSetName = 'PathSet')]
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
    [string[]]
    $ArgumentList = @()
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
      wsl.exe @ArgumentList wslpath -a -u $_.FullName.Replace([Path]::DirectorySeparatorChar, [Path]::AltDirectorySeparatorChar)
    }
  }
}
function Get-NormalizedPath {
  <#
  .SYNOPSIS
    Normalizes Windows file and directory paths.

  .DESCRIPTION
    Get-NormalizedPath normalizes each input path by resolving the target item
    and normalizing the final path component. It preserves parent directories and
    converts invalid file name characters as needed. Use `-Compatible` for
    compatibility normalization forms and `-Decompose` to decompose Unicode
    characters before re-composition.

  .PARAMETER Path
    Specifies wildcard-compatible paths to normalize.

  .PARAMETER LiteralPath
    Specifies literal paths to normalize.

  .PARAMETER Decompose
    Decomposes Unicode characters before normalization.

  .PARAMETER Compatible
    Uses compatibility normalization forms for path component normalization.

  .EXAMPLE
    Get-NormalizedPath -Path 'C:\Users\Public\Document.txt'

  .EXAMPLE
    Get-NormalizedPath -LiteralPath 'C:\Users\Public\Document.txt' -Compatible

  .OUTPUTS
    System.String. The normalized path.

  .NOTES
    This function uses Get-Item to resolve paths and only changes the final
    path component when normalization is required.
  #>
  [CmdletBinding(DefaultParameterSetName = 'PathSet')]
  [OutputType([string])]
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
    $Decompose,
    [switch]
    $Compatible
  )
  begin {
    $PreCompose = $Compatible ?
    ($Decompose ? [NormalizationForm]::FormKD : [NormalizationForm]::FormKC) :
    ($Decompose ? [NormalizationForm]::FormD :  [NormalizationForm]::FormC)
    $Compose = $Compatible ? [NormalizationForm]::FormKC : [NormalizationForm]::FormC
    $LCID = [CultureInfo]::GetCultureInfo('ja-JP').LCID
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
      $parent = $_.PSIsContainer ? $_.Parent : $_.Directory
      if ($null -eq $parent) {
        return $_.FullName
      }
      $escaped = -join (
        ($_.Name -replace '\s+', ' ').
        Trim().
        Normalize($PreCompose).
        ToCharArray() |
        Where-Object {
          [CharUnicodeInfo]::GetUnicodeCategory($_) -notin @(
            [UnicodeCategory]::NonSpacingMark
            [UnicodeCategory]::SpacingCombiningMark
            [UnicodeCategory]::Format
            [UnicodeCategory]::Control
          )
        } |
        ForEach-Object {
          switch -CaseSensitive ($_) {
            '\' {
              '＼'
            } # REVERSE SOLIDUS -> FULLWIDTH REVERSE SOLIDUS
            { $_ -eq [char]0x301C } {
              [char]0xFF5E
            } # WAVE DASH -> FULLWIDTH TILDE
            default {
              $_
            }
          }
        } |
        ForEach-Object {
          switch -CaseSensitive ($_) {
            { $_ -in [Path]::GetInvalidFileNameChars() } {
              [Strings]::StrConv($_, [VbStrConv]::Wide, $LCID)
            }
            default {
              $_
            }
          }
        }
      )
      $normalized = $Decompose ? $escaped.Normalize($Compose) : $escaped
      return $parent.FullName | Join-Path -ChildPath $normalized
    } |
    ForEach-Object {
      if (-not (Test-Path -LiteralPath $_ -IsValid)) {
        throw [ArgumentException]::new("$_ is not valid.")
      }
      return $_
    }
  }
}
function Move-NormalizedPath {
  <#
  .SYNOPSIS
    Moves items using normalized paths.

  .DESCRIPTION
    Move-NormalizedPath resolves each specified path, normalizes the final path
    component, and moves the item to the normalized destination when the path
    changes. It supports wildcard and literal paths, and it uses ShouldProcess
    support to allow previewing changes with `-WhatIf`.

  .PARAMETER Path
    Specifies wildcard-compatible paths to move and normalize.

  .PARAMETER LiteralPath
    Specifies literal paths to move and normalize.

  .PARAMETER Recurse
    Includes child items when resolving the source path.

  .PARAMETER Force
    Bypasses confirmation and moves items even if they already exist.

  .PARAMETER PassThru
    Returns moved items when the operation succeeds.

  .EXAMPLE
    Move-NormalizedPath -Path 'C:\Temp\*' -WhatIf

  .EXAMPLE
    Move-NormalizedPath -LiteralPath 'C:\Temp\file.txt' -Force

  .OUTPUTS
    PSObject when PassThru is specified; otherwise, none.

  .NOTES
    This function uses Get-NormalizedPath internally and supports `-WhatIf`.
  #>
  [CmdletBinding(DefaultParameterSetName = 'PathSet', SupportsShouldProcess)]
  [OutputType([void], [PSObject])]
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
    $Force,
    [switch]
    $PassThru
  )
  begin {
    Write-Progress -Activity 'Move normalized paths.'
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
    Get-ChildItem -Recurse:$Recurse -Force |
    ForEach-Object {
      return [PSCustomObject]@{
        Source      = $_.FullName
        Destination = Get-NormalizedPath -LiteralPath $_.FullName -Compatible
        ItemType    = $_.PSIsContainer ? 'Directory' : 'File'
      }
    } |
    Where-Object { -not $_.Source.Equals($_.Destination) } |
    ForEach-Object {
      $target = "Source: $($_.Source), Destination: $($_.Destination)"
      $action = "Move $($_.ItemType)"
      if (-not (($Force -and -not $WhatIfPreference) -or $PSCmdlet.ShouldProcess($target, $action))) {
        return
      }
      if (Test-Path -LiteralPath $_.Destination) {
        Write-Warning -Message "$($_.Destination) already exists."
        if (Test-Path -LiteralPath $_.Source -PathType Container) {
          Get-ChildItem -LiteralPath $_.Source -Force |
          Move-Item -Destination $_.Destination -PassThru:$PassThru -WhatIf:$WhatIfPreference -Confirm:$false
        }
      }
      else {
        Move-Item -LiteralPath $_.Source -Destination $_.Destination -PassThru:$PassThru -WhatIf:$WhatIfPreference -Confirm:$false
      }
    }
  }
  clean {
    Write-Progress -Completed
  }
}
function Test-ArchiveExtension {
  [CmdletBinding(DefaultParameterSetName = 'PathSet')]
  [OutputType([bool])]
  param (
    [Parameter(Mandatory, ParameterSetName = 'PathSet', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [SupportsWildcards()]
    [string[]]
    $Path,
    [Alias('PSPath', 'LP')]
    [Parameter(Mandatory, ParameterSetName = 'LiteralPathSet', ValueFromPipelineByPropertyName)]
    [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
    [string[]]
    $LiteralPath
  )
  process {
    try {
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
    }
    catch [ItemNotFoundException] {
      return $false
    }
    return @(
      $items |
      Where-Object {
        if (-not (Test-Path -LiteralPath $_ -PathType Leaf)) {
          return $false
        }
        return ([WildcardPattern]::Escape($_.FullName) | Split-Path -Extension) -imatch '^\.(7z|ace|arj|bz2|cab|gz|gzip|jar|r00|r01|r02|r03|r04|r05|r06|r07|r08|r09|r10|r11|r12|r13|r14|r15|r16|r17|r18|r19|r20|r21|r22|r23|r24|r25|r26|r27|r28|r29|rar|tar|tgz|z|zip)$'
      }
    ).Count -gt 0
  }
}
function Test-PdfExtension {
  [CmdletBinding(DefaultParameterSetName = 'PathSet')]
  [OutputType([bool])]
  param (
    [Parameter(Mandatory, ParameterSetName = 'PathSet', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [SupportsWildcards()]
    [string[]]
    $Path,
    [Alias('PSPath', 'LP')]
    [Parameter(Mandatory, ParameterSetName = 'LiteralPathSet', ValueFromPipelineByPropertyName)]
    [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
    [string[]]
    $LiteralPath
  )
  process {
    try {
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
    }
    catch [ItemNotFoundException] {
      return $false
    }
    return @(
      $items |
      Where-Object {
        if (-not (Test-Path -LiteralPath $_ -PathType Leaf)) {
          return $false
        }
        return ([WildcardPattern]::Escape($_.FullName) | Split-Path -Extension) -imatch '^\.pdf$'
      }
    ).Count -gt 0
  }
}
function Test-PictureExtension {
  [CmdletBinding(DefaultParameterSetName = 'PathSet')]
  [OutputType([bool])]
  param (
    [Parameter(Mandatory, ParameterSetName = 'PathSet', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [SupportsWildcards()]
    [string[]]
    $Path,
    [Alias('PSPath', 'LP')]
    [Parameter(Mandatory, ParameterSetName = 'LiteralPathSet', ValueFromPipelineByPropertyName)]
    [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
    [string[]]
    $LiteralPath
  )
  process {
    try {
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
    }
    catch [ItemNotFoundException] {
      return $false
    }
    return @(
      $items |
      Where-Object {
        if (-not (Test-Path -LiteralPath $_ -PathType Leaf)) {
          return $false
        }
        return ([WildcardPattern]::Escape($_.FullName) | Split-Path -Extension) -imatch '^\.(ani|bmp|gif|ico|jpe|jpeg|jpg|pcx|png|psd|tga|tif|tiff|webp|wmf)$'
      }
    ).Count -gt 0
  }
}
