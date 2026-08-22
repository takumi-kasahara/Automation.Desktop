<#
.SYNOPSIS
  Mirrors a source directory to a destination using Robocopy.

.DESCRIPTION
  Mirrors a source directory to a destination using Robocopy.
  It uses `Robocopy.exe` with mirroring options to replicate files.
  Displays progress, writes a log to the TEMP directory.
  Returns an object describing the operation.
  Emits warnings if Robocopy reports a serious error (exit code >= 8).
  Supports -WhatIf. When specified, Robocopy runs with /L so no files are copied, moved, or deleted.

.PARAMETER Source
  The source directory path to copy from. Must exist.

.PARAMETER Destination
  The destination directory path to copy to. Must be a valid path.

.PARAMETER NDL
  No Directory List: Do not output directory names during the Robocopy operation.

.PARAMETER NFL
  No File List: Do not output file names during the Robocopy operation.

.EXAMPLE
  ```powershell
  Invoke-Robocopy -Source 'C:\Data' -Destination 'D:\Backup\Data'
  ```

  Mirrors C:\Data to D:\Backup\Data and returns the operation details.

.EXAMPLE
  ```powershell
  Invoke-Robocopy -Source 'C:\Data' -Destination 'D:\Backup\Data' -WhatIf
  ```

  Lists the files that would be copied or deleted without making any changes.

.OUTPUTS
  System.Management.Automation.PSCustomObject
    An object with Source, Destination, and Log properties.

.NOTES
  Uses /MIR, so files missing in the source are deleted from the destination.
  Robocopy exit codes: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy#exit-return-codes
#>
function Invoke-Robocopy {
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([PSCustomObject])]
  param (
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ })]
    [string]
    $Source,
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
    [string]
    $Destination,
    [switch]
    $NDL,
    [switch]
    $NFL
  )
  try {
    $log = $env:TEMP | Join-Path -ChildPath "Robocopy.$(Get-Date -Format 'yyyyMMddHHmmss').log"
    Write-Progress -Activity 'Backup' -Status $Source
    [PSCustomObject]@{
      Source      = $Source
      Destination = $Destination
      Log         = $log
    }
    $arguments = @(
      '/TEE'
      '/COPY:DAT'
      '/DCOPY:DAT'
      '/TIMFIX'
      '/MIR'
      '/NP'
      '/XJ'
      '/COMPRESS'
      '/SPARSE'
      '/R:0'
      '/W:0'
      "/LOG+:$log"
    )
    if ($NDL) {
      $arguments += '/NDL'
    }
    if ($NFL) {
      $arguments += '/NFL'
    }
    if (-not $PSCmdlet.ShouldProcess("$Source -> $Destination", 'Robocopy')) {
      $arguments += '/L'
    }
    Robocopy.exe $Source $Destination @arguments
    # https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy#exit-return-codes
    if ($LASTEXITCODE -ge 0x8) {
      Write-Warning -Message "Robocopy failed with exit code $LASTEXITCODE."
    }
  } finally {
    Write-Progress -Completed
  }
}
