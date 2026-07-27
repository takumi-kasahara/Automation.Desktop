[CmdletBinding()]
param ()

Set-StrictMode -Version Latest
Set-Location -LiteralPath $PSScriptRoot

$externalDrive = Get-Disk |
Where-Object -Property BusType -EQ 'USB' |
Get-Partition |
Get-Volume |
Select-Object -ExpandProperty DriveLetter -First 1
if (-not $externalDrive) {
  throw 'External drive not found.'
}
$target = "$($externalDrive):"

Get-Process |
Where-Object -Property ProcessName -EQ 'OneDrive' |
Stop-Process -Force

(Import-PowerShellDataFile -LiteralPath 'Directory.psd1').GetEnumerator() |
Sort-Object -Property Name |
ForEach-Object {
  $name = $_.Name
  $path = 'Env:\' | Join-Path -ChildPath $name
  if (-not (Test-Path -LiteralPath $path)) {
    return
  }
  $item = Get-Item -LiteralPath $path
  if ($_.Value.Count -eq 0) {
    $source = $item.Value
    if (-not (Test-Path -LiteralPath $source -PathType Container)) {
      Write-Warning -Message "$source not found."
      return
    }
    $destination = $target | Join-Path -ChildPath $name
    Invoke-Robocopy -Source $source -Destination $destination
  } else {
    $_.Value |
    ForEach-Object {
      $source = $item.Value | Join-Path -ChildPath $_
      if (-not (Test-Path -LiteralPath $source -PathType Container)) {
        Write-Warning -Message "$source not found."
        return
      }
      $destination = $target | Join-Path -ChildPath $name | Join-Path -ChildPath $_
      Invoke-Robocopy -Source $source -Destination $destination
    }
  }
} | Out-Host
