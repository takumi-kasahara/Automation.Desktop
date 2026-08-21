<#
.SYNOPSIS
  Provides utility functions for working with PDF files using QPDF.
.LINK
  https://qpdf.readthedocs.io/en/stable/cli.html
#>
using namespace System.IO
using namespace System.Net
using namespace System.Security

Set-StrictMode -Version Latest

class PdfInfo {
  [FileInfo]$Item
  [int]$PageCount
}
function ConvertTo-Qdf {
  <#
  .SYNOPSIS
    Converts a PDF file to QDF format using QPDF.

  .DESCRIPTION
  Converts a PDF file to QDF format using QPDF.
  Uses `qpdf.exe` to perform the conversion.
  Supports -WhatIf for previewing changes without execution.

  .PARAMETER Path
    Specifies the path of the PDF file to convert.

  .PARAMETER Destination
    Specifies the path of the file to write the QDF output to.

  .PARAMETER Force
    If specified, overwrites the destination file if it already exists, including read-only files.

  .PARAMETER NoClobber
    If specified, the function will fail if the destination file already exists.

  .PARAMETER OwnerPassword
    Specifies the owner password for encrypted PDF files. Use a SecureString for secure input.

  .PARAMETER UserPassword
    Specifies the user password for encrypted PDF files. Use a SecureString for secure input.

  .EXAMPLE
    ``` powershell
    ConvertTo-Qdf -Path 'C:\docs\manual.pdf' -Destination 'C:\dir\manual.qdf'
    ```

    Converts manual.pdf to an editable QDF file in C:\dir.

  .EXAMPLE
    ``` powershell
    $ownerPw = ConvertTo-SecureString -String 'owner123' -AsPlainText -Force
    ConvertTo-Qdf -Path 'C:\docs\encrypted.pdf' -Destination 'C:\dir\manual.qdf' -OwnerPassword $ownerPw
    ```

    Converts an encrypted PDF to QDF format using the owner password.

  .OUTPUTS
    None. Only converts PDF to QDF.
  #>
  [OutputType([void])]
  [CmdletBinding(SupportsShouldProcess)]
  param (
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
    $log = $env:TEMP | Join-Path -ChildPath "QPDF.$(Get-Date -Format 'yyyyMMddHHmmss').log"
  }
  process {
    $item = Get-Item -LiteralPath $Path -Force
    if (-not (($Force -and -not $WhatIfPreference) -or $PSCmdlet.ShouldProcess($item.FullName, 'Convert to QDF'))) {
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
    $arguments = @($item.FullName, '--qdf', $Destination)
    if ($PSBoundParameters.ContainsKey('OwnerPassword')) {
      $arguments += "--owner-password=$([NetworkCredential]::new([string]::Empty, $OwnerPassword).Password)"
    }
    if ($PSBoundParameters.ContainsKey('UserPassword')) {
      $arguments += "--password=$([NetworkCredential]::new([string]::Empty, $UserPassword).Password)"
    }
    qpdf.exe @arguments 2>>$log
    if ($isReadOnly) {
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
function ConvertFrom-Qdf {
  <#
  .SYNOPSIS
    Converts a QDF file back to PDF format using QPDF.

  .DESCRIPTION
  Converts a QDF file back to PDF format using QPDF.
  Uses `qpdf.exe` to perform the conversion.
  Supports -WhatIf for previewing changes without execution.

  .PARAMETER Path
    Specifies the path of the QDF file to convert.

  .PARAMETER Destination
    Specifies the path of the file to write the PDF output to.

  .PARAMETER Force
    If specified, overwrites the destination file if it already exists, including read-only files.

  .PARAMETER NoClobber
    If specified, the function will fail if the destination file already exists.

  .PARAMETER OwnerPassword
    Specifies the owner password for encrypted QDF files. Use a SecureString for secure input.

  .PARAMETER UserPassword
    Specifies the user password for encrypted QDF files. Use a SecureString for secure input.

  .EXAMPLE
    ``` powershell
    ConvertFrom-Qdf -Path 'C:\dir\manual.qdf' -Destination 'C:\docs\manual.pdf'
    ```

    Converts the QDF file back to a PDF document.

  .EXAMPLE
    ``` powershell
    $ownerPw = ConvertTo-SecureString -String 'owner123' -AsPlainText -Force
    ConvertFrom-Qdf -Path 'C:\dir\encrypted.qdf' -Destination 'C:\docs\manual.pdf' -OwnerPassword $ownerPw
    ```

    Converts an encrypted QDF file back to PDF using the owner password.

  .OUTPUTS
    None. Only converts QDF to PDF.
  #>
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([void])]
  param (
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
    $log = $env:TEMP | Join-Path -ChildPath "QPDF.$(Get-Date -Format 'yyyyMMddHHmmss').log"
  }
  process {
    $item = Get-Item -LiteralPath $Path -Force
    if (-not (($Force -and -not $WhatIfPreference) -or $PSCmdlet.ShouldProcess($item.FullName, 'Convert from QDF'))) {
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
    $arguments = @($item.FullName)
    if ($PSBoundParameters.ContainsKey('OwnerPassword')) {
      $arguments += "--owner-password=$([NetworkCredential]::new([string]::Empty, $OwnerPassword).Password)"
    }
    if ($PSBoundParameters.ContainsKey('UserPassword')) {
      $arguments += "--password=$([NetworkCredential]::new([string]::Empty, $UserPassword).Password)"
    }
    fix-qdf.exe @arguments >$Destination 2>>$log
    if ($isReadOnly) {
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
function Unblock-Pdf {
  <#
  .SYNOPSIS
    Removes encryption from PDF files using QPDF.

  .DESCRIPTION
    Unblock-Pdf reads PDF files specified by Path or LiteralPath and uses
    `qpdf.exe --show-encryption` to determine whether each file is encrypted.
    If a file is encrypted, the function runs `qpdf.exe --decrypt --replace-input`
    to remove encryption in place. The command supports `-WhatIf` through
    `SupportsShouldProcess` so the decryption step can be previewed without
    modifying files.

  .PARAMETER Path
    Specifies wildcard-compatible PDF file paths to inspect and unblock.

  .PARAMETER LiteralPath
    Specifies literal PDF file paths to inspect and unblock.

  .PARAMETER OwnerPassword
    Specifies the owner password for encrypted PDF files. Use a SecureString for secure input.

  .PARAMETER UserPassword
    Specifies the user password for encrypted PDF files. Use a SecureString for secure input.

  .EXAMPLE
    ``` powershell
    Unblock-Pdf -Path 'C:\docs\*.pdf'
    ```

    Removes encryption from every PDF that matches the path.

  .EXAMPLE
    ``` powershell
    Unblock-Pdf -LiteralPath 'C:\docs\manual.pdf' -WhatIf
    ```

    Shows the decryption operation for manual.pdf without modifying it.

  .EXAMPLE
    ``` powershell
    $ownerPw = ConvertTo-SecureString -String 'ownerpass' -AsPlainText -Force
    Unblock-Pdf -LiteralPath 'C:\docs\encrypted.pdf' -OwnerPassword $ownerPw
    ```

    Removes encryption from a password-protected PDF file.

  .OUTPUTS
    None.
      Only removes PDF encryption.

  .NOTES
    This function requires `qpdf.exe` to be available in the system PATH.
    Standard error output from QPDF is written to a temporary log file that is removed when it remains empty.
  #>
  [CmdletBinding(SupportsShouldProcess)]
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
    [SecureString]
    $OwnerPassword,
    [SecureString]
    $UserPassword
  )
  begin {
    $log = $env:TEMP | Join-Path -ChildPath "QPDF.$(Get-Date -Format 'yyyyMMddHHmmss').log"
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
      $showArgs = @('--show-encryption', $_)
      if ($PSBoundParameters.ContainsKey('OwnerPassword')) {
        $showArgs += "--owner-password=$([NetworkCredential]::new([string]::Empty, $OwnerPassword).Password)"
      }
      if ($PSBoundParameters.ContainsKey('UserPassword')) {
        $showArgs += "--password=$([NetworkCredential]::new([string]::Empty, $UserPassword).Password)"
      }
      $stdout = qpdf.exe @showArgs 2>>$log
      if ($stdout -eq 'File is not encrypted') {
        return
      }
      if (-not $PSCmdlet.ShouldProcess($_.FullName, 'Decrypt PDF')) {
        return
      }
      $decryptArgs = @($_, '--decrypt', '--replace-input')
      if ($PSBoundParameters.ContainsKey('OwnerPassword')) {
        $decryptArgs += "--owner-password=$([NetworkCredential]::new([string]::Empty, $OwnerPassword).Password)"
      }
      if ($PSBoundParameters.ContainsKey('UserPassword')) {
        $decryptArgs += "--password=$([NetworkCredential]::new([string]::Empty, $UserPassword).Password)"
      }
      qpdf.exe @decryptArgs 2>>$log
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
function Get-PdfPage {
  <#
  .SYNOPSIS
    Retrieves the page count of PDF files using QPDF.

  .DESCRIPTION
    Get-PdfPage reads PDF files specified by Path or LiteralPath and invokes
    `qpdf.exe --show-npages` to obtain the number of pages in each file. It
    returns objects containing the original file item and the parsed page count.
    Standard error output from QPDF is written to a temporary log file that is
    removed when it remains empty.

  .PARAMETER Path
    Specifies wildcard-compatible PDF file paths to inspect.

  .PARAMETER LiteralPath
    Specifies literal PDF file paths to inspect.

  .PARAMETER OwnerPassword
    Specifies the owner password for encrypted PDF files. Use a SecureString for secure input.

  .PARAMETER UserPassword
    Specifies the user password for encrypted PDF files. Use a SecureString for secure input.

  .EXAMPLE
    ``` powershell
    Get-PdfPage -Path 'C:\docs\*.pdf'
    ```

    Returns the page count for each matching PDF file.

  .EXAMPLE
    ``` powershell
    Get-PdfPage -LiteralPath 'C:\docs\manual.pdf'
    ```

    Returns the page count for manual.pdf.

  .EXAMPLE
    ``` powershell
    $ownerPw = ConvertTo-SecureString -String 'owner123' -AsPlainText -Force
    Get-PdfPage -LiteralPath 'C:\docs\encrypted.pdf' -OwnerPassword $ownerPw
    ```

    Returns the page count for an encrypted PDF file using the owner password.

  .OUTPUTS
    PdfInfo

  .NOTES
    This function requires `qpdf.exe` to be available in the system PATH.
  #>
  [CmdletBinding(DefaultParameterSetName = 'PathSet')]
  param (
    [Parameter(Mandatory, ParameterSetName = 'PathSet', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [SupportsWildcards()]
    [string[]]
    $Path,
    [Alias('PSPath', 'LP')]
    [Parameter(Mandatory, ParameterSetName = 'LiteralPathSet', ValueFromPipelineByPropertyName)]
    [string[]]
    $LiteralPath,
    [SecureString]
    $OwnerPassword,
    [SecureString]
    $UserPassword
  )
  begin {
    $log = $env:TEMP | Join-Path -ChildPath "QPDF.$(Get-Date -Format 'yyyyMMddHHmmss').log"
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
      $arguments = @('--show-npages', $_)
      if ($PSBoundParameters.ContainsKey('OwnerPassword')) {
        $arguments += "--owner-password=$([NetworkCredential]::new([string]::Empty, $OwnerPassword).Password)"
      }
      if ($PSBoundParameters.ContainsKey('UserPassword')) {
        $arguments += "--password=$([NetworkCredential]::new([string]::Empty, $UserPassword).Password)"
      }
      $page = qpdf.exe @arguments 2>>$log
      if ($LASTEXITCODE -eq 0) {
        return [PSCustomObject]@{
          Item      = $_
          PageCount = $page
        }
      }
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
