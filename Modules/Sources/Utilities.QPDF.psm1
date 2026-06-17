using namespace System.IO

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
    ConvertTo-Qdf reads a PDF file specified by FilePath and converts it to
    QDF format, writing the result to the specified Destination.

  .PARAMETER Path
    Specifies the path of the PDF file to convert.

  .PARAMETER Destination
    Specifies the path of the file to write the QDF output to.

  .PARAMETER Force
    If specified, overwrites the destination file if it already exists, including read-only files.

  .PARAMETER NoClobber
    If specified, the function will fail if the destination file already exists.

  .EXAMPLE
    ConvertTo-Qdf -Path 'C:\Docs\manual.pdf' -Destination 'C:\Temp\manual.qdf'

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
    $NoClobber
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
      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord -ErrorId 'ItemAlreadyExists' -TargetObject $Destination))
    }
    $isReadOnly = (Test-Path -LiteralPath $Destination -PathType Leaf) -and (Get-Item -LiteralPath $Destination -Force).IsReadOnly
    if ($isReadOnly -and $Force) {
      (Get-Item -LiteralPath $Destination -Force).IsReadOnly = $false
    }
    # https://qpdf.readthedocs.io/en/stable/cli.html
    qpdf.exe $item.FullName --qdf $Destination 2>>$log
    if ($isReadOnly) {
      (Get-Item -LiteralPath $Destination -Force).IsReadOnly = $true
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
function ConvertFrom-Qdf {
  <#
  .SYNOPSIS
    Converts a QDF file back to PDF format using QPDF.

  .DESCRIPTION
    ConvertFrom-Qdf reads a QDF file specified by FilePath and converts it
    back to PDF format, writing the result to the specified Destination.

  .PARAMETER Path
    Specifies the path of the QDF file to convert.

  .PARAMETER Destination
    Specifies the path of the file to write the PDF output to.

  .PARAMETER Force
    If specified, overwrites the destination file if it already exists, including read-only files.

  .PARAMETER NoClobber
    If specified, the function will fail if the destination file already exists.

  .EXAMPLE
    ConvertFrom-Qdf -Path 'C:\Temp\manual.qdf' -Destination 'C:\Docs\manual.pdf'

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
    $NoClobber
  )
  begin {
    $log = $env:TEMP | Join-Path -ChildPath "QPDF.$(Get-Date -Format 'yyyyMMddHHmmss').log"
  }
  process {
    $item = Get-Item -LiteralPath $Path -Force
    # https://qpdf.readthedocs.io/en/stable/cli.html
    if (-not (($Force -and -not $WhatIfPreference) -or $PSCmdlet.ShouldProcess($item.FullName, 'Convert from QDF'))) {
      return
    }
    if ((Test-Path -LiteralPath $Destination -PathType Container) -or ((Test-Path -LiteralPath $Destination -PathType Leaf) -and $NoClobber)) {
      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord -ErrorId 'ItemAlreadyExists' -TargetObject $Destination))
    }
    $isReadOnly = (Test-Path -LiteralPath $Destination -PathType Leaf) -and (Get-Item -LiteralPath $Destination -Force).IsReadOnly
    if ($isReadOnly -and $Force) {
      (Get-Item -LiteralPath $Destination -Force).IsReadOnly = $false
    }
    fix-qdf.exe $item.FullName >$Destination 2>>$log
    if ($isReadOnly) {
      (Get-Item -LiteralPath $Destination -Force).IsReadOnly = $true
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

  .EXAMPLE
    Unblock-Pdf -Path 'C:\Docs\*.pdf'

  .EXAMPLE
    Unblock-Pdf -LiteralPath 'C:\Docs\manual.pdf' -WhatIf

  .OUTPUTS
    None. Only removes PDF encryption.

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
    $LiteralPath
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
      $stdout = qpdf.exe --show-encryption $_ 2>>$log
      if ($stdout -eq 'File is not encrypted') {
        return
      }
      if (-not $PSCmdlet.ShouldProcess($_.FullName, 'Decrypt PDF')) {
        return
      }
      qpdf.exe $_ --decrypt --replace-input 2>>$log
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

  .EXAMPLE
    Get-PdfPage -Path 'C:\Docs\*.pdf'

  .EXAMPLE
    Get-PdfPage -LiteralPath 'C:\Docs\manual.pdf'

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
    $LiteralPath
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
      $page = qpdf.exe --show-npages $_ 2>>$log
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
      }
      else {
        Remove-Item -LiteralPath $log -Force
      }
    }
  }
}
