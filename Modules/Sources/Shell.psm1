using namespace System.Collections.ObjectModel
using namespace System.IO
using namespace System.Management.Automation

Set-StrictMode -Version Latest

#region Classes
class ItemDetail {
  [int]$Index
  [string]$Name
  [object]$Value
}
class ShellFolder {
  [string]$Name
  [string]$Path
}
class StartupItem {
  [string]$Name
  [string]$CommandLine
}
#endregion
#region Public
function Get-ItemDetail {
  <#
  .SYNOPSIS
    Retrieves Windows shell property details for files and folders.

  .DESCRIPTION
    Resolves each specified item and enumerates shell metadata for the item using the Windows Shell.Application COM interface.
    Returns `ItemDetail` objects containing the detail index, property name, and corresponding value.

  .PARAMETER Path
    Specifies one or more item paths to search. Wildcards are supported.

  .PARAMETER LiteralPath
    Specifies one or more literal item paths to search. Wildcards are not interpreted.

  .PARAMETER Min
    The minimum detail index to include. Defaults to 0.

  .PARAMETER Max
    The maximum detail index to include. Defaults to 1024.

  .EXAMPLE
    ``` powershell
    Get-ItemDetail -Path 'C:\dir\file.txt' -Min 0 -Max 10
    ```

  .OUTPUTS
    ItemDetail.
      Objects for all non-empty shell detail fields in the requested index range.

  .LINK
    https://learn.microsoft.com/en-us/windows/win32/shell/folder-getdetailsof
  #>
  [CmdletBinding(DefaultParameterSetName = 'PathSet')]
  [OutputType([ItemDetail])]
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
    [int]
    $Min = 0,
    [int]
    $Max = [Math]::Pow(2, 10)
  )
  begin {
    if ($Min -lt 0) {
      throw [ArgumentOutOfRangeException]::new('`-Min` must be greater than or equal to 0')
    }
    if ($Max -lt 0) {
      throw [ArgumentOutOfRangeException]::new('`-Max` must be greater than or equal to 0')
    }
    if ($Min -gt $Max) {
      throw [ArgumentOutOfRangeException]::new("`-Min` must be less than `-Max`.")
    }
    $shell = New-Object -ComObject 'Shell.Application'
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
      $resolved = (Resolve-Path -LiteralPath $_).Path
      $folder = $shell.Namespace(([WildcardPattern]::Escape($resolved) | Split-Path -Parent))
      $file = $folder.ParseName(([WildcardPattern]::Escape($resolved) | Split-Path -Leaf))

      $count = 0
      for ($index = $Min; $index -le $Max; $index++) {
        $count++
        Write-Progress -Activity "Collect details: $resolved" -Status "Processing $count of $($Max - $Min + 1)" -PercentComplete ($count / ($Max - $Min + 1) * 100)
        $name = $folder.GetDetailsOf($null, $index) -replace '\p{C}'
        if (-not $name) {
          break
        }
        $value = $folder.GetDetailsOf($file, $index) -replace '\p{C}'
        if (-not $value) {
          break
        }
        [ItemDetail]@{
          Index = $index
          Name  = $name
          Value = $value
        }
      }
    }
  }
  clean {
    Get-Variable |
    Where-Object -Property Value -Is [__ComObject] |
    Clear-Variable -Force -WhatIf:$false
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
    Write-Progress -Completed
  }
}
function Find-Application {
  <#
  .SYNOPSIS
    Finds an application by name in PATH, Program Files, or registered apps.

  .OUTPUTS
    System.String[]
      Path(s) to the found application(s).
  #>
  [CmdletBinding()]
  [OutputType([string[]])]
  param (
    [Parameter(Mandatory)]
    [string]
    $Name
  )
  try {
    $found = [string[]]@(where.exe $Name 2>$null)
    if ($found.Count -gt 0) {
      return $found
    }
    Write-Progress -Activity 'Searching in Program Files (x64) directories'
    $programFilesX64 = [string[]]@(where.exe /r $env:ProgramFiles $Name 2>$null)
    if ($programFilesX64.Count -gt 0) {
      return $programFilesX64
    }
    Write-Progress -Activity 'Searching in Program Files (x86) directories'
    $programFilesX86 = [string[]]@(where.exe /r ${env:ProgramFiles(x86)} $Name 2>$null)
    if ($programFilesX86.Count -gt 0) {
      return $programFilesX86
    }
    Write-Progress -Activity 'Searching in registered applications'
    $applications = [string[]]@(Get-Application | Where-Object -Property Name -Like $Name | Select-Object -ExpandProperty Path)
    if ($applications.Count -gt 0) {
      return $applications
    }
  } finally {
    Write-Progress -Completed
  }
}
function Get-Application {
  [CmdletBinding()]
  [OutputType([ShellFolder])]
  param ()
  <#
  .SYNOPSIS
    Gets registered Windows applications from App Paths.

  .OUTPUTS
    ShellFolder. Application name and path.

  .LINK
    [Application Registration](https://learn.microsoft.com/en-us/windows/win32/shell/app-registration)
  #>
  dynamicparam {
    $parameter = [Parameter]::new()
    $attributeCollection = [Collection[Attribute]]::new()
    $attributeCollection.Add($parameter)
    $validateSet = [ValidateSet]::new(
      (
        @(
          'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths'
          'HKCU:\Software\Microsoft\Windows\CurrentVersion\App Paths'
        ) |
        Get-ChildItem |
        ForEach-Object { $_.PSChildName }
      ) -split "`n"
    )
    $attributeCollection.Add($validateSet)
    $parameterName = 'Name'
    $dynamic = [RuntimeDefinedParameter]::new($parameterName, [string], $attributeCollection)
    $dict = [RuntimeDefinedParameterDictionary]::new()
    $dict.Add($parameterName, $dynamic)
    return $dict
  }
  begin {
    $applications = @(
      'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths'
      'HKCU:\Software\Microsoft\Windows\CurrentVersion\App Paths'
    ) |
    Get-ChildItem |
    ForEach-Object { $_ } -PipelineVariable regKey |
    ForEach-Object {
      try {
        $defaultValue = $_.GetValue($null).Trim('"')
        return [ShellFolder]@{
          Name = $regKey.PSChildName
          Path = (Test-Path -LiteralPath $defaultValue) ? $defaultValue : [Environment]::ExpandEnvironmentVariables($defaultValue)
        }
      } catch {
        Write-Warning -Message "$regKey`t$($_.Exception.Message)"
      }
    } |
    Where-Object {
      if (-not (Test-Path -LiteralPath $_.Path)) {
        Write-Warning -Message "$($_.Path) not found."
        return $false
      }
      return $true
    }
  }
  process {
    $Name = $PSBoundParameters[$parameterName]
    if ($Name) {
      return $applications | Where-Object -Property Name -Like $Name
    } else {
      return $applications
    }
  }
}
function Get-SpecialFolder {
  <#
  .SYNOPSIS
    Gets special Windows folders by known folder ID.

  .OUTPUTS
    ShellFolder. Folder name and path.
    System.String. Path string if found by name.

  .LINK
    [Known Folder IDs](https://learn.microsoft.com/en-us/windows/win32/shell/knownfolderid)
  #>
  [CmdletBinding()]
  [OutputType([ShellFolder], [string])]
  param ()
  dynamicparam {
    $parameter = [Parameter]::new()
    $attributeCollection = [Collection[Attribute]]::new()
    $attributeCollection.Add($parameter)
    $validateSet = [ValidateSet]::new(
      (
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions' |
        Get-ChildItem |
        ForEach-Object { $_.GetValue('Name') } |
        Where-Object { $_ }
      ) -split "`n"
    )
    $attributeCollection.Add($validateSet)
    $parameterName = 'Name'
    $dynamic = [RuntimeDefinedParameter]::new($parameterName, [string], $attributeCollection)
    $dict = [RuntimeDefinedParameterDictionary]::new()
    $dict.Add($parameterName, $dynamic)
    return $dict
  }
  begin {
    $shell = New-Object -ComObject 'Shell.Application'
    $Name = $PSBoundParameters[$parameterName]
  }
  process {
    if ($Name) {
      $folder = $shell.NameSpace('shell:{0}' -f $Name)
      return $folder ? $folder.Self.Path : $null
    } else {
      $validateSet.ValidValues |
      ForEach-Object {
        $folder = $shell.NameSpace('shell:{0}' -f $_)
        return [ShellFolder]@{
          Name = $_
          Path = $folder ? $folder.Self.Path : $null
        }
      }
    }
  }
  clean {
    Get-Variable |
    Where-Object -Property Value -Is [__ComObject] |
    Clear-Variable -Force -WhatIf:$false
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
  }
}
function Get-Startup {
  <#
  .SYNOPSIS
    Gets all startup items from Startup folders and registry.

  .OUTPUTS
    StartupItem. Startup item name and command line.
  #>
  [CmdletBinding()]
  [OutputType([StartupItem])]
  param ()
  @(
    Get-ChildItem -LiteralPath (Get-SpecialFolder -Name 'Startup')
    Get-ChildItem -LiteralPath (Get-SpecialFolder -Name 'Common Startup')
    Get-Item -LiteralPath 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
    Get-Item -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'
  ) |
  ForEach-Object {
    if ($_.PSProvider.Name -eq 'Registry') {
      $reg = $_
      $_.GetValueNames() |
      ForEach-Object {
        return [StartupItem]@{
          Name        = $_
          CommandLine = $reg.GetValue($_)
        }
      }
    } elseif ($_.PSProvider.Name -eq 'FileSystem') {
      if ($_.Extension -eq '.lnk') {
        $lnk = Get-Shortcut -LiteralPath $_.FullName
        return [StartupItem]@{
          Name        = $_.BaseName
          CommandLine = "`"$($lnk.TargetPath)`" $($lnk.Arguments)"
        }
      } else {
        return [StartupItem]@{
          Name        = $_.BaseName
          CommandLine = $_.FullName
        }
      }
    }
  }
}
function Move-ItemToRecycleBin {
  <#
  .SYNOPSIS
    Moves files or directories to the Windows Recycle Bin.

  .DESCRIPTION
    Sends the specified items to the Recycle Bin using the Windows `Shell.Application` COM interface.
    Supports wildcards via `-Path` and literal paths via `-LiteralPath`.

  .PARAMETER Path
    Specifies one or more paths to files or directories. Wildcards are supported.

  .PARAMETER LiteralPath
    Specifies one or more literal paths to files or directories.

  .EXAMPLE
    ``` powershell
    Move-ItemToRecycleBin -Path 'C:\dir\*'
    ```

    Moves every item in C:\dir to the Recycle Bin.

  .EXAMPLE
    ``` powershell
    Move-ItemToRecycleBin -LiteralPath 'C:\dir\file.txt'
    ```

  .NOTES
    This cmdlet moves items to the Recycle Bin and does not return any object on success.

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
    $LiteralPath
  )
  begin {
    $shell = New-Object -ComObject 'Shell.Application'
    $RecycleBin = $shell.NameSpace('shell:RecycleBinFolder')
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
      if (-not $PSCmdlet.ShouldProcess($target, 'Move to Recycle Bin')) {
        return
      }
      # https://learn.microsoft.com/ja-jp/windows/win32/shell/folder-movehere
      $RecycleBin.MoveHere($_.FullName)
      "Removed:`t$($_.FullName)" | Out-Host
    }
  }
  clean {
    Get-Variable |
    Where-Object -Property Value -Is [__ComObject] |
    Clear-Variable -Force -WhatIf:$false
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
  }
}
function New-Shortcut {
  <#
  .SYNOPSIS
    Creates a Windows shortcut file (.lnk).

  .DESCRIPTION
    Creates a Windows Shell shortcut at the specified destination.
    If the destination path does not end with `.lnk`, the cmdlet appends the extension automatically.

  .PARAMETER Path
    Specifies the shortcut file path to create. If the path has no extension, `.lnk` is appended automatically.

  .PARAMETER TargetPath
    Specifies the target file or URL for the shortcut. If the path exists, it is resolved to the canonical path.

  .PARAMETER WorkingDirectory
    Specifies the working directory for the shortcut.

  .PARAMETER Arguments
    Specifies command-line arguments for the shortcut target.

  .PARAMETER Description
    Specifies the shortcut description.

  .PARAMETER IconLocation
    Specifies the icon location for the shortcut. Defaults to `,0`.

  .PARAMETER HotKey
    Specifies the shortcut hotkey. Accepts F1–F12 or single alphanumeric keys.

  .PARAMETER WindowStyle
    Specifies the window style for the shortcut: Normal, Maximum, or Minimum.

  .PARAMETER Force
    Overwrites an existing shortcut file if it already exists.

  .EXAMPLE
    ``` powershell
    New-Shortcut -Path 'C:\Users\Public\Desktop\Example.lnk' -TargetPath 'C:\Windows\System32\notepad.exe'
    ```

    Creates a public desktop shortcut to Notepad.

  .EXAMPLE
    ``` powershell
    New-Shortcut -Path 'C:\Users\Public\Desktop\Example' -TargetPath 'C:\Windows\System32\notepad.exe' -WorkingDirectory 'C:\Temp' -Arguments '/A /B' -Description 'Example shortcut' -IconLocation 'C:\Windows\System32\shell32.dll,1' -HotKey 'F5' -WindowStyle Maximum -Force
    ```

  .OUTPUTS
    System.IO.FileInfo
      The created shortcut file.

  .NOTES
    Returns the created shortcut file object.

  .LINK
    https://learn.microsoft.com/en-us/troubleshoot/windows-client/admin-development/create-desktop-shortcut-with-wsh
  #>
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([System.IO.FileInfo])]
  param (
    [Alias('FullName')]
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
    [string]
    $Path,
    [Parameter(Mandatory, Position = 1)]
    [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
    [string]
    $TargetPath,
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string]
    $WorkingDirectory,
    [string]
    $Arguments,
    [string]
    $Description,
    [string]
    $IconLocation = ',0',
    [ValidatePattern('[a-z0-9]|F[1-9]|F1[0-2]', Options = 'IgnoreCase')]
    [string]
    $HotKey,
    [ValidateSet(
      'Normal'
      , 'Maximum'
      , 'Minimum'
    )]
    [string]
    $WindowStyle,
    [switch]
    $Force
  )
  $ext = [WildcardPattern]::Escape($Path) | Split-Path -Extension
  if ($ext -ne '.lnk') {
    $Path += '.lnk'
  }
  $target = "Destination: $($ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path))"
  if (-not (($Force -and -not $WhatIfPreference) -or $PSCmdlet.ShouldProcess($target, 'Create Shortcut'))) {
    return
  }
  try {
    if ($Force) {
      Remove-Item -LiteralPath $Path -Force -ErrorAction Ignore
    }
    $wshShell = New-Object -ComObject 'WScript.Shell'
    $wshShortcut = $wshShell.CreateShortcut($Path)
    $wshShortcut.TargetPath = $TargetPath
    $wshShortcut.WorkingDirectory = $WorkingDirectory
    $wshShortcut.Arguments = $Arguments
    $wshShortcut.Description = $Description
    $wshShortcut.IconLocation = $IconLocation
    if ($HotKey) {
      $wshShortcut.HotKey = "Ctrl+Alt+$HotKey"
    }
    if ($WindowStyle) {
      $styles = @{
        'Normal'  = 1
        'Maximum' = 3
        'Minimum' = 7
      }
      $wshShortcut.WindowStyle = $styles[$WindowStyle]
    }
    $wshShortcut.Save()
    Get-Item -LiteralPath $Path -Force
  } finally {
    Get-Variable |
    Where-Object -Property Value -Is [__ComObject] |
    Clear-Variable -Force -WhatIf:$false
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
  }
}
function New-UrlShortcut {
  <#
  .SYNOPSIS
    Creates an Internet shortcut file (.url).

  .DESCRIPTION
    Creates a Windows Internet Shortcut file that points to a well-formed absolute URI.
    If the destination path does not end with `.url`, the cmdlet appends the extension automatically.

  .PARAMETER Path
    Specifies the shortcut file path to create. If the path has no extension,
    `.url` is appended automatically.

  .PARAMETER TargetPath
    Specifies the destination URI for the shortcut. Must be an absolute URL.

  .PARAMETER Force
    Overwrites an existing shortcut if one already exists.

  .EXAMPLE
    ``` powershell
    New-UrlShortcut -Path 'C:\Users\Public\Desktop\Example.url' -TargetPath 'https://example.com'
    ```

    Creates a public desktop shortcut to the specified website.

  .EXAMPLE
    ``` powershell
    New-UrlShortcut -Path 'C:\Users\Public\Desktop\Example' -TargetPath 'https://example.com' -Force
    ```

  .OUTPUTS
    System.IO.FileInfo
      The created .url shortcut file.

  .NOTES
    Returns the created shortcut file object.
  #>
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([System.IO.FileInfo])]
  param (
    [Alias('FullName')]
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
    [string]
    $Path,
    [Parameter(Mandatory, Position = 1)]
    [ValidateScript({ [uri]::IsWellFormedUriString($_, [UriKind]::Absolute) })]
    [string]
    $TargetPath,
    [switch]
    $Force
  )
  $ext = [WildcardPattern]::Escape($Path) | Split-Path -Extension
  if ($ext -ne '.url') {
    $Path += '.url'
  }
  $target = "Destination: $Path"
  if (-not (($Force -and -not $WhatIfPreference) -or $PSCmdlet.ShouldProcess($target, 'Create Shortcut'))) {
    return
  }
  try {
    if ($Force) {
      Remove-Item -LiteralPath $Path -Force -WhatIf:$WhatIfPreference -Confirm:$false
    }
    $wshShell = New-Object -ComObject 'WScript.Shell'
    $wshShortcut = $wshShell.CreateShortcut($Path)
    $wshShortcut.TargetPath = $TargetPath
    $wshShortcut.Save()
    Get-Item -LiteralPath $Path -Force
  } finally {
    Get-Variable |
    Where-Object -Property Value -Is [__ComObject] |
    Clear-Variable -Force -WhatIf:$false
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
  }
}
function Get-Shortcut {
  <#
  .SYNOPSIS
    Returns a Windows shortcut object for the specified file path.

  .DESCRIPTION
    Resolves the specified shortcut path and returns a
    `WScript.Shell` shortcut object. Supports both wildcard-aware
    `-Path` input and literal `-LiteralPath` input.

  .PARAMETER Path
    Specifies one or more shortcut file paths, with wildcard support.

  .PARAMETER LiteralPath
    Specifies one or more exact shortcut file paths.

  .EXAMPLE
    ``` powershell
    Get-Shortcut -Path 'C:\Users\Public\Desktop\Example.lnk'
    ```

    Returns the properties of the matching shortcut.

  .EXAMPLE
    ``` powershell
    Get-Shortcut -LiteralPath 'C:\Users\Public\Desktop\Example.lnk'
    ```

  .OUTPUTS
    System.__ComObject
      The shortcut COM object.

  .NOTES
    Returns the COM shortcut object created by `WScript.Shell`.
  #>
  [CmdletBinding(DefaultParameterSetName = 'PathSet')]
  [OutputType([System.__ComObject])]
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
    $LiteralPath
  )
  begin {
    $wshShell = New-Object -ComObject 'WScript.Shell'
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
    ForEach-Object { return $wshShell.CreateShortcut($_.FullName) }
  }
  clean {
    Get-Variable |
    Where-Object -Property Value -Is [__ComObject] |
    Clear-Variable -Force -WhatIf:$false
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
  }
}
function Test-Shortcut {
  <#
  .SYNOPSIS
    Verifies that a shortcut points to an existing target.

  .DESCRIPTION
    Resolves the specified shortcut file path, reads the target path
    from the shortcut, and returns `True` when the shortcut target exists.
    Supports wildcard-aware `-Path` input and exact `-LiteralPath` input.

  .PARAMETER Path
    Specifies one or more shortcut file paths, with wildcard support.

  .PARAMETER LiteralPath
    Specifies one or more exact shortcut file paths.

  .EXAMPLE
    ``` powershell
    Test-Shortcut -Path 'C:\Users\Public\Desktop\Example.lnk'
    ```

    Tests whether the matching shortcut target is valid.

  .EXAMPLE
    ``` powershell
    Test-Shortcut -LiteralPath 'C:\Users\Public\Desktop\Example.lnk'
    ```

  .NOTES
    Returns a boolean value indicating whether the shortcut target exists.

  .OUTPUTS
    System.Boolean
      True if the shortcut target exists; otherwise, False.
  #>
  [CmdletBinding(DefaultParameterSetName = 'PathSet')]
  [OutputType([bool])]
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
    } catch [ItemNotFoundException] {
      return $false
    }
    return @(
      $items |
      Get-Shortcut |
      Where-Object { Test-Path -LiteralPath $_.TargetPath }
    ).Count -gt 0
  }
}
function New-NetworkDrive {
  <#
  .SYNOPSIS
    Creates a persistent mapped network drive.

  .DESCRIPTION
    Maps a network location to a drive letter using a persistent PowerShell drive.
    If the drive letter is already in use, specifying `-Force` removes the existing mapping before creating the new one.

  .PARAMETER Name
    Specifies the drive letter to assign to the network location.

  .PARAMETER Root
    Specifies the network root path to map, such as `\\server\share`.

  .PARAMETER Force
    Removes the existing mapped drive before creating the new mapping.

  .EXAMPLE
    ``` powershell
    New-NetworkDrive -Name Z -Root '\\server\share'
    ```

    Maps the server share to drive Z.

  .EXAMPLE
    ``` powershell
    New-NetworkDrive -Name Z -Root '\\server\share' -Force
    ```

  .OUTPUTS
    None.

  .NOTES
    Creates a persistent drive mapping in the current user session.
  #>
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([void])]
  param (
    [ValidatePattern('[A-Z]')]
    [string]
    $Name,
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string]
    $Root,
    [switch]
    $Force
  )
  if ($Force) {
    Remove-PSDrive -Name $Name -Scope Global -Force -ErrorAction Ignore -WhatIf:$WhatIfPreference -Confirm:$false
  }
  New-PSDrive -Name $Name -PSProvider fileSystem -Root $Root -Scope Global -Persist -WhatIf:$WhatIfPreference -Confirm:$false
}
function New-NetworkShortcut {
  <#
  .SYNOPSIS
    Creates a Network Shortcuts folder item that points to a specified path.

  .DESCRIPTION
    Creates a folder under the Windows Network Shortcuts
    folder and configures it with the required desktop.ini settings. Also
    creates a target shortcut inside the new folder. If the destination already
    exists, `-Force` removes it before recreating it.

  .PARAMETER Path
    Specifies the network share or folder path that the shortcut will point to.

  .PARAMETER Force
    Removes the existing network shortcut before creating a new one.

  .EXAMPLE
    ``` powershell
    New-NetworkShortcut -Path '\\server\share'
    ```

    Creates a network shortcut for the server share.

  .EXAMPLE
    ``` powershell
    New-NetworkShortcut -Path '\\server\share' -Force
    ```

  .OUTPUTS
  System.IO.DirectoryInfo
    The created network shortcut folder.

  .NOTES
  The created shortcut is placed in the Windows Network Shortcuts folder.
  #>
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([System.IO.DirectoryInfo])]
  param (
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
    [string]
    $Path,
    [switch]
    $Force
  )
  $networkShortcuts = [Environment]::GetFolderPath([Environment+SpecialFolder]::NetworkShortcuts)
  $destination = $networkShortcuts | Join-Path -ChildPath ([WildcardPattern]::Escape($Path) | Split-Path -Leaf)
  $target = "Destination: $destination"
  if (-not (($Force -and -not $WhatIfPreference) -or $PSCmdlet.ShouldProcess($target, 'Create Network Shortcut'))) {
    return
  }
  if (Test-Path -LiteralPath $destination) {
    Remove-Item -LiteralPath $destination -Recurse -Force:$Force -WhatIf:$WhatIfPreference -Confirm:$false
  } else {
    New-Item -Path $destination -ItemType Directory -Force:$Force -WhatIf:$WhatIfPreference -Confirm:$false | Out-Null
  }
  $ini = $destination | Join-Path -ChildPath 'desktop.ini'
  @'
[.ShellClassInfo]
CLSID2={0AFACED1-E828-11D1-9187-B532F1E9575D}
Flags=2
'@ | Out-File -LiteralPath $ini -WhatIf:$WhatIfPreference -Confirm:$false
  Set-ItemProperty -LiteralPath $ini -Name Attributes -Value ([FileAttributes]::Hidden -bor [FileAttributes]::System -bor [FileAttributes]::Archive) -WhatIf:$WhatIfPreference -Confirm:$false
  New-Shortcut -Path ($destination | Join-Path -ChildPath 'target.lnk') -TargetPath $Path -WhatIf:$WhatIfPreference -Confirm:$false
  Set-ItemProperty -LiteralPath $destination -Name Attributes -Value ([FileAttributes]::ReadOnly) -WhatIf:$WhatIfPreference -Confirm:$false
  return Get-Item -LiteralPath $destination -Force
}
#endregion
