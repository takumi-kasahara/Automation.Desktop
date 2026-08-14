using namespace System.IO
using namespace System.Management.Automation
using namespace System.Net
using namespace System.Security

Set-StrictMode -Version Latest

function Export-PdfDump {
  <#
  .SYNOPSIS
    Exports PDF metadata dump information using PDFtk.

  .DESCRIPTION
    Export-PdfDump reads a PDF file specified by FilePath and
    invokes `pdftk.exe` to write PDF metadata dump output in UTF-8 format to the
    specified Destination. Standard error output from PDFtk is collected to a temporary
    log file and the log is removed when it is empty.

  .PARAMETER Path
    Specifies the path of the PDF file to export metadata from.

  .PARAMETER Destination
    Specifies the path of the file to write the metadata dump output to.

  .PARAMETER Force
    If specified, overwrites the destination file if it already exists.

  .PARAMETER NoClobber
    If specified, the function will fail if the destination file already exists.

  .PARAMETER OwnerPassword
    Specifies the owner password for the PDF file. Use a SecureString for secure input.

  .PARAMETER UserPassword
    Specifies the user password for the PDF file. Use a SecureString for secure input.

  .EXAMPLE
    ``` powershell
  Export-PdfDump -Path 'C:\Docs\manual.pdf' -Destination 'C:\Temp\dump.txt'
  ```

  Exports metadata from manual.pdf to a text dump.

  .EXAMPLE
    ``` powershell
    $ownerPw = ConvertTo-SecureString -String 'ownerpass' -AsPlainText -Force
    $userPw = ConvertTo-SecureString -String 'userpass' -AsPlainText -Force
    Export-PdfDump -Path 'C:\Docs\manual.pdf' -Destination 'C:\Temp\dump.txt' -OwnerPassword $ownerPw -UserPassword $userPw
    ```

  .OUTPUTS
    None. Only exports PDF metadata dump.

  .NOTES
    This function requires `pdftk.exe` to be available in the system PATH.
  #>
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([void])]
  param (
    [Alias('FilePath', 'FullName')]
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]
    $Path,
    [Parameter(Mandatory)]
    [ValidateScript({ (Test-Path -LiteralPath $_ -IsValid) -and -not (Test-Path -LiteralPath $_ -PathType Container) })]
    [string]
    $Destination,
    [switch]
    $Force,
    [switch]
    $NoClobber,
    [SecureString]
    $OwnerPassword,
    [SecureString]
    $UserPassword
  )
  begin {
    $log = $env:TEMP | Join-Path -ChildPath "PDFtk.$(Get-Date -Format 'yyyyMMddHHmmss').log"
  }
  process {
    $item = Get-Item -LiteralPath $Path -Force
    if (-not (($Force -and -not $WhatIfPreference) -or $PSCmdlet.ShouldProcess($item.FullName, 'Export PDF metadata dump'))) {
      return
    }
    if ((Test-Path -LiteralPath $Destination -PathType Container) -or ((Test-Path -LiteralPath $Destination -PathType Leaf) -and $NoClobber)) {
      $PSCmdlet.ThrowTerminatingError([ErrorRecord]::new(
          [IOException]::new("$Destination already exists. Use -Force to overwrite the file.")
          , 'ItemAlreadyExists'
          , [ErrorCategory]::ResourceExists
          , $Destination
        ))
    }
    $isReadOnly = (Test-Path -LiteralPath $Destination -PathType Leaf) -and (Get-Item -LiteralPath $Destination -Force).IsReadOnly
    if ($isReadOnly -and $Force) {
      (Get-Item -LiteralPath $Destination -Force).IsReadOnly = $false
    }
    $passwordArgs = @()
    if ($PSBoundParameters.ContainsKey('OwnerPassword')) {
      $passwordArgs += 'owner_pw', [NetworkCredential]::new([string]::Empty, $OwnerPassword).Password
    }
    if ($PSBoundParameters.ContainsKey('UserPassword')) {
      $passwordArgs += 'user_pw', [NetworkCredential]::new([string]::Empty, $UserPassword).Password
    }
    # https://www.pdflabs.com/docs/pdftk-man-page/#dest-op-dump-data
    $pdftkArgs = @($item.FullName) + $passwordArgs + @('dump_data_utf8', 'output', $Destination)
    pdftk.exe @pdftkArgs 2>>$log
    if ($isReadOnly -and $Force) {
      (Get-Item -LiteralPath $Destination -Force).IsReadOnly = $true
    }
  }
  clean {
    if (Test-Path -LiteralPath $log) {
      if (@(Get-Content -LiteralPath $log).Count -gt 0) {
        "LOG:`t$log" | Out-Host
      } else {
        Remove-Item -LiteralPath $log -Force
      }
    }
  }
}
function Import-PdfDump {
  <#
  .SYNOPSIS
    Imports PDF metadata dump information into PDF files using PDFtk.

  .DESCRIPTION
    Import-PdfDump reads a PDF file specified by FilePath
    and applies metadata from a PDF dump file to the target PDF using
    `pdftk.exe update_info_utf8`. The command supports `-WhatIf` through
    `SupportsShouldProcess` so metadata changes can be previewed without writing.

  .PARAMETER Path
    Specifies the path of the PDF file to update.

  .PARAMETER Source
    Specifies the PDF dump file that contains the metadata to import.

  .PARAMETER Destination
    Specifies the output path for the updated PDF file.

  .PARAMETER Force
    If specified, overwrites the destination file if it already exists, including read-only files.

  .PARAMETER OwnerPassword
    Specifies the owner password for the PDF file. Use a SecureString for secure input.

  .PARAMETER UserPassword
    Specifies the user password for the PDF file. Use a SecureString for secure input.

  .EXAMPLE
    ``` powershell
  Import-PdfDump -Path 'C:\Docs\manual.pdf' -Source 'C:\Temp\meta.dump' -Destination 'C:\Temp\updated.pdf'
  ```

  Applies metadata from meta.dump and writes the updated PDF to C:\Temp.

  .EXAMPLE
    ``` powershell
    $ownerPw = ConvertTo-SecureString -String 'ownerpass' -AsPlainText -Force
    $userPw = ConvertTo-SecureString -String 'userpass' -AsPlainText -Force
    Import-PdfDump -Path 'C:\Docs\manual.pdf' -Source 'C:\Temp\meta.dump' -Destination 'C:\Temp\updated.pdf' -OwnerPassword $ownerPw -UserPassword $userPw
    ```

  .OUTPUTS
    None. Only imports PDF metadata dump.

  .NOTES
    This function requires `pdftk.exe` to be available in the system PATH.
    Standard error output from PDFtk is collected to a temporary log file and the
    log file is removed when it remains empty.
  #>
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([void])]
  param (
    [Alias('FilePath', 'FullName')]
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]
    $Path,
    [Parameter(Mandatory)]
    [ValidateScript({ (Test-Path -LiteralPath $_ -IsValid) -and -not (Test-Path -LiteralPath $_ -PathType Container) })]
    [string]
    $Source,
    [Parameter(Mandatory)]
    [ValidateScript({ (Test-Path -LiteralPath $_ -IsValid) -and -not (Test-Path -LiteralPath $_ -PathType Container) })]
    [string]
    $Destination,
    [switch]
    $Force,
    [SecureString]
    $OwnerPassword,
    [SecureString]
    $UserPassword
  )
  begin {
    $log = $env:TEMP | Join-Path -ChildPath "PDFtk.$(Get-Date -Format 'yyyyMMddHHmmss').log"
  }
  process {
    $item = Get-Item -LiteralPath $Path -Force
    # https://www.pdflabs.com/docs/pdftk-man-page/#dest-op-update-info
    if (-not (($Force -and -not $WhatIfPreference) -or $PSCmdlet.ShouldProcess($item.FullName, "Import metadata from $Source"))) {
      return
    }
    $isReadOnly = (Test-Path -LiteralPath $Destination -PathType Leaf) -and (Get-Item -LiteralPath $Destination -Force).IsReadOnly
    if ($isReadOnly -and $Force) {
      (Get-Item -LiteralPath $Destination -Force).IsReadOnly = $false
    }
    $passwordArgs = @()
    if ($PSBoundParameters.ContainsKey('OwnerPassword')) {
      $passwordArgs += 'owner_pw', [NetworkCredential]::new([string]::Empty, $OwnerPassword).Password
    }
    if ($PSBoundParameters.ContainsKey('UserPassword')) {
      $passwordArgs += 'user_pw', [NetworkCredential]::new([string]::Empty, $UserPassword).Password
    }
    pdftk.exe $item.FullName update_info_utf8 $Source @passwordArgs output $Destination 2>>$log
    if ($isReadOnly -and $Force) {
      (Get-Item -LiteralPath $Destination -Force).IsReadOnly = $true
    }
  }
  clean {
    if (Test-Path -LiteralPath $log) {
      if (@(Get-Content -LiteralPath $log).Count -gt 0) {
        "LOG:`t$log" | Out-Host
      } else {
        Remove-Item -LiteralPath $log -Force
      }
    }
  }
}
function Join-Pdf {
  <#
  .SYNOPSIS
    Joins PDF files into a single PDF by using PDFtk.

  .DESCRIPTION
    Join-Pdf accepts either Path or LiteralPath and resolves it to one or more
    items. If all resolved items are PDF files, those files are joined in the
    resolved order. When Path contains wildcard characters, Join-Pdf does not
    expand them and passes each wildcard path to PDFtk as specified. If the
    resolved input is a single directory, all PDF files under the directory are
    joined by using the pattern '<directory>\*.pdf'.

    The function rejects inputs that resolve to two or more directories, or a
    mixture of files and directories.

    The function invokes `pdftk.exe` with `cat output` and always appends
    `verbose`. It supports `-WhatIf` and `-Confirm` through
    `SupportsShouldProcess`.

  .PARAMETER Path
    Specifies wildcard-compatible paths to source items.
    Wildcard paths are passed to PDFtk without expansion. The source items must
    otherwise resolve to PDF files only, or to a single directory.

  .PARAMETER LiteralPath
    Specifies literal paths to source items.
    The source items must resolve to PDF files only, or to a single directory.

  .PARAMETER Destination
    Specifies the output PDF path.
    When omitted and the source is a single directory, the output defaults to
    '{directoryName}.pdf' in the parent folder of the directory.
    This parameter is optional only when the source is a single directory.

  .PARAMETER Force
    If specified, allows overwrite behavior for an existing read-only
    destination file by temporarily clearing the read-only attribute.

  .PARAMETER NoClobber
    If specified, the function throws an error when Destination already exists.

  .PARAMETER OwnerPassword
    Specifies the owner password for the PDF file. Use a SecureString for secure input.

  .PARAMETER UserPassword
    Specifies the user password for the PDF file. Use a SecureString for secure input.

  .EXAMPLE
    ``` powershell
    Join-Pdf -Path 'C:\Docs\manual.pdf' -Destination 'C:\Temp\merged.pdf'
    ```

    Joins a single PDF file and writes the result to C:\Temp\merged.pdf.

  .EXAMPLE
    ``` powershell
    Join-Pdf -Path 'C:\Docs\chapter1.pdf', 'C:\Docs\chapter2.pdf' -Destination 'C:\Temp\merged.pdf'
    ```

    Joins multiple PDF files in the specified order.

  .EXAMPLE
    ``` powershell
    Join-Pdf -Path 'C:\Docs\*.pdf' -Destination 'C:\Temp\merged.pdf'
    ```

    Passes the wildcard path directly to PDFtk without expanding it in PowerShell.

  .EXAMPLE
    ``` powershell
    Join-Pdf -Path 'C:\Docs'
    ```

    Joins all PDF files that match C:\Docs\*.pdf and writes C:\Docs.pdf.

  .EXAMPLE
    ``` powershell
    Join-Pdf -LiteralPath 'C:\Docs' -Destination 'C:\Temp\merged.pdf' -WhatIf
    ```

    Shows what would happen without running pdftk.

  .EXAMPLE
    ``` powershell
    Join-Pdf -LiteralPath 'C:\Docs'
    ```

    Joins all PDF files under C:\Docs and writes C:\Docs.pdf. Destination is
    omitted because the source is a single directory.

  .EXAMPLE
    ``` powershell
    $ownerPw = ConvertTo-SecureString -String 'ownerpass' -AsPlainText -Force
    Join-Pdf -Path 'C:\Docs\manual.pdf' -Destination 'C:\Temp\merged.pdf' -OwnerPassword $ownerPw
    ```

    Joins a password-protected PDF file.

  .OUTPUTS
    None. Only creates a merged PDF file.

  .NOTES
    This function requires `pdftk.exe` to be available in the system PATH.
    Reference: https://www.pdflabs.com/docs/pdftk-man-page/#dest-op-cat
  #>
  [CmdletBinding(SupportsShouldProcess)]
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
    [Parameter()]
    [ValidateScript({ (Test-Path -LiteralPath $_ -IsValid) -and -not (Test-Path -LiteralPath $_ -PathType Container) })]
    [string]
    $Destination,
    [switch]
    $Force,
    [switch]
    $NoClobber,
    [SecureString]
    $OwnerPassword,
    [SecureString]
    $UserPassword
  )
  begin {
    $log = $env:TEMP | Join-Path -ChildPath "PDFtk.$(Get-Date -Format 'yyyyMMddHHmmss').log"
  }
  process {
    $items = @()
    $sourceItems = @()
    switch -Exact -CaseSensitive ($PSCmdlet.ParameterSetName) {
      'PathSet' {
        foreach ($currentPath in $Path) {
          if ([WildcardPattern]::ContainsWildcardCharacters($currentPath)) {
            $sourceItems += $currentPath
            continue
          }
          $item = Get-Item -Path $currentPath -Force
          $items += $item
        }
      }
      'LiteralPathSet' {
        $items = @(Get-Item -LiteralPath $LiteralPath -Force)
      }
    }
    if (($items.Count -eq 0) -and ($sourceItems.Count -eq 0)) {
      $source = if ($PSCmdlet.ParameterSetName -eq 'PathSet') {
        $Path -join ', '
      } else {
        $LiteralPath -join ', '
      }
      $PSCmdlet.ThrowTerminatingError([ErrorRecord]::new(
          [ArgumentException]::new("$source did not resolve to any items. Specify PDF file paths or a single directory path.", 'Path')
          , 'ItemNotFound'
          , [ErrorCategory]::ObjectNotFound
          , $source
        ))
    }
    $directories = @($items | Where-Object { $_.PSIsContainer })
    $files = @($items | Where-Object { -not $_.PSIsContainer })
    if ($directories.Count -gt 1) {
      $source = $directories.FullName -join ', '
      $PSCmdlet.ThrowTerminatingError([ErrorRecord]::new(
          [ArgumentException]::new("$source resolves to multiple directories. Specify only one directory path.", 'Path')
          , 'MultipleDirectoriesNotSupported'
          , [ErrorCategory]::InvalidArgument
          , $source
        ))
    }
    if (($directories.Count -eq 1) -and (($files.Count -gt 0) -or ($sourceItems.Count -gt 0))) {
      $source = @(@($items | ForEach-Object { $_.FullName }) + $sourceItems) -join ', '
      $PSCmdlet.ThrowTerminatingError([ErrorRecord]::new(
          [ArgumentException]::new("$source mixes files and directories. Specify PDF files only, or a single directory path.", 'Path')
          , 'MixedFileAndDirectoryNotSupported'
          , [ErrorCategory]::InvalidArgument
          , $source
        ))
    }
    $sourceItems = if ($directories.Count -eq 1) {
      @($directories[0].FullName | Join-Path -ChildPath '*.pdf')
    } else {
      @($sourceItems + @($files | ForEach-Object { $_.FullName }))
    }
    $source = "`"$($sourceItems -join '" "')`""
    $outputDestination = if ($PSBoundParameters.ContainsKey('Destination')) {
      $Destination
    } elseif ($directories.Count -eq 1) {
      $directories[0].Parent.FullName | Join-Path -ChildPath ($directories[0].Name + '.pdf')
    } else {
      $PSCmdlet.ThrowTerminatingError([ErrorRecord]::new(
          [ArgumentException]::new('Destination is required when joining PDF files. Specify the output path.', 'Destination')
          , 'DestinationRequired'
          , [ErrorCategory]::InvalidArgument
          , $null
        ))
    }
    if (-not (($Force -and -not $WhatIfPreference) -or $PSCmdlet.ShouldProcess($source, 'Join PDF files'))) {
      return
    }
    if ((Test-Path -LiteralPath $outputDestination -PathType Container) -or ((Test-Path -LiteralPath $outputDestination -PathType Leaf) -and $NoClobber)) {
      $PSCmdlet.ThrowTerminatingError([ErrorRecord]::new(
          [IOException]::new("$outputDestination already exists. Use -Force to overwrite the file.")
          , 'ItemAlreadyExists'
          , [ErrorCategory]::ResourceExists
          , $outputDestination
        ))
    }
    $isReadOnly = (Test-Path -LiteralPath $outputDestination -PathType Leaf) -and (Get-Item -LiteralPath $outputDestination -Force).IsReadOnly
    if ($isReadOnly -and $Force) {
      (Get-Item -LiteralPath $outputDestination -Force).IsReadOnly = $false
    }
    $passwordArgs = @()
    if ($PSBoundParameters.ContainsKey('OwnerPassword')) {
      $passwordArgs += 'owner_pw', [NetworkCredential]::new([string]::Empty, $OwnerPassword).Password
    }
    if ($PSBoundParameters.ContainsKey('UserPassword')) {
      $passwordArgs += 'user_pw', [NetworkCredential]::new([string]::Empty, $UserPassword).Password
    }
    # https://www.pdflabs.com/docs/pdftk-man-page/#dest-op-cat
    pdftk.exe $source cat @passwordArgs output $outputDestination verbose 2>>$log
    if ($isReadOnly -and $Force) {
      (Get-Item -LiteralPath $outputDestination -Force).IsReadOnly = $true
    }
  }
  clean {
    if (Test-Path -LiteralPath $log) {
      if (@(Get-Content -LiteralPath $log).Count -gt 0) {
        "LOG:`t$log" | Out-Host
      } else {
        Remove-Item -LiteralPath $log -Force
      }
    }
  }
}
function Split-Pdf {
  <#
  .SYNOPSIS
    Splits a PDF file into one page per output PDF using PDFtk burst.

  .DESCRIPTION
    Split-Pdf reads a single PDF file specified by Path or LiteralPath and
    invokes `pdftk.exe burst` to generate one output PDF per page. The output
    file naming pattern is controlled by Destination, and `verbose` is always
    appended. The command rejects directory inputs and non-PDF files.

  .PARAMETER Path
    Specifies wildcard-compatible path to a single PDF file.

  .PARAMETER LiteralPath
    Specifies literal path to a single PDF file.

  .PARAMETER Destination
    Specifies the printf-styled output filename pattern for burst output.
    The path is not validated for existence because it contains format placeholders.

  .PARAMETER OwnerPassword
    Specifies the owner password for the PDF file. Use a SecureString for secure input.

  .PARAMETER UserPassword
    Specifies the user password for the PDF file. Use a SecureString for secure input.

  .EXAMPLE
    ``` powershell
  Split-Pdf -Path 'C:\Docs\manual.pdf' -Destination 'C:\Temp\page_%04d.pdf'
  ```

  Splits manual.pdf into numbered page files in C:\Temp.

  .EXAMPLE
    ``` powershell
    $ownerPw = ConvertTo-SecureString -String 'ownerpass' -AsPlainText -Force
    Split-Pdf -Path 'C:\Docs\manual.pdf' -Destination 'C:\Temp\page_%04d.pdf' -OwnerPassword $ownerPw
    ```

  .OUTPUTS
    None. Only splits the PDF into page files.

  .NOTES
    This function requires `pdftk.exe` to be available in the system PATH.
    Reference: https://www.pdflabs.com/docs/pdftk-man-page/#dest-op-burst
  #>
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([void])]
  param (
    [Parameter(Mandatory, ParameterSetName = 'PathSet', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [SupportsWildcards()]
    [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
    [string]
    $Path,
    [Alias('PSPath', 'LP')]
    [Parameter(Mandatory, ParameterSetName = 'LiteralPathSet', ValueFromPipelineByPropertyName)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]
    $LiteralPath,
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
    [string]
    $Destination,
    [SecureString]
    $OwnerPassword,
    [SecureString]
    $UserPassword
  )
  begin {
    $log = $env:TEMP | Join-Path -ChildPath "PDFtk.$(Get-Date -Format 'yyyyMMddHHmmss').log"
  }
  process {
    $items = @(
      switch -Exact -CaseSensitive ($PSCmdlet.ParameterSetName) {
        'PathSet' {
          @(Get-Item -Path $Path -Force)
        }
        'LiteralPathSet' {
          @(Get-Item -LiteralPath $LiteralPath -Force)
        }
      }
    )
    if ($items.Count -ne 1) {
      $source = if ($PSCmdlet.ParameterSetName -eq 'PathSet') {
        $Path
      } else {
        $LiteralPath
      }
      $PSCmdlet.ThrowTerminatingError([ErrorRecord]::new(
          [ArgumentException]::new("$source resolves to multiple items. Specify a single PDF file path.", 'Path')
          , 'AmbiguousPath'
          , [ErrorCategory]::InvalidArgument
          , $source
        ))
    }
    $item = $items[0]
    if ($item.PSIsContainer) {
      $PSCmdlet.ThrowTerminatingError([ErrorRecord]::new(
          [ArgumentException]::new("$($item.FullName) is a directory. Split-Pdf accepts only a PDF file path.", 'Path')
          , 'DirectoryNotSupported'
          , [ErrorCategory]::InvalidArgument
          , $item.FullName
        ))
    }
    if (([WildcardPattern]::Escape($item.FullName) | Split-Path -Extension) -inotmatch '^\.pdf$') {
      $PSCmdlet.ThrowTerminatingError([ErrorRecord]::new(
          [ArgumentException]::new("$($item.FullName) is not a PDF file. Specify a path with .pdf extension.", 'Path')
          , 'InvalidPdfFile'
          , [ErrorCategory]::InvalidArgument
          , $item.FullName
        ))
    }
    if (-not $PSCmdlet.ShouldProcess($item.FullName, 'Split PDF into pages')) {
      return
    }
    $passwordArgs = @()
    if ($PSBoundParameters.ContainsKey('OwnerPassword')) {
      $passwordArgs += 'owner_pw', [NetworkCredential]::new([string]::Empty, $OwnerPassword).Password
    }
    if ($PSBoundParameters.ContainsKey('UserPassword')) {
      $passwordArgs += 'user_pw', [NetworkCredential]::new([string]::Empty, $UserPassword).Password
    }
    # https://www.pdflabs.com/docs/pdftk-man-page/#dest-op-burst
    pdftk.exe $item.FullName burst @passwordArgs output $Destination verbose 2>>$log
  }
  clean {
    if (Test-Path -LiteralPath $log) {
      if (@(Get-Content -LiteralPath $log).Count -gt 0) {
        "LOG:`t$log" | Out-Host
      } else {
        Remove-Item -LiteralPath $log -Force
      }
    }
  }
}
