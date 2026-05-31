using namespace System.IO

Set-StrictMode -Version Latest

class PdfInfo {
  [FileInfo]$Item
  [int]$PageCount
}
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

  .EXAMPLE
    Export-PdfDump -Path 'C:\Docs\manual.pdf' -Destination 'C:\Temp\dump.txt'

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
    $NoClobber
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
      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord -ErrorId 'ItemAlreadyExists' -TargetObject $Destination))
    }
    $isReadOnly = (Test-Path -LiteralPath $Destination -PathType Leaf) -and (Get-Item -LiteralPath $Destination -Force).IsReadOnly
    if ($isReadOnly -and $Force) {
      (Get-Item -LiteralPath $Destination -Force).IsReadOnly = $false
    }
    # https://www.pdflabs.com/docs/pdftk-man-page/#dest-op-dump-data
    pdftk.exe $item.FullName dump_data_utf8 output $Destination 2>>$log
    if ($isReadOnly -and $Force) {
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

  .EXAMPLE
    Import-PdfDump -Path 'C:\Docs\manual.pdf' -Source 'C:\Temp\meta.dump' -Destination 'C:\Temp\updated.pdf'

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
    $Force
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
    pdftk.exe $item.FullName update_info_utf8 $Source output $Destination 2>>$log
    if ($isReadOnly -and $Force) {
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
