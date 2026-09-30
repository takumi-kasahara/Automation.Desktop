<#
.SYNOPSIS
  Updates WSL distributions and optimizes virtual hard disks.

.DESCRIPTION
  This script updates WSL to the latest pre-release version, executes distribution-specific scripts defined in Distro.psd1, shuts down WSL, and optimizes virtual hard disk files.

.NOTES
  Requires WSL to be installed.
  The script reads distribution scripts from `Distro.psd1` configuration file.
#>
[CmdletBinding()]
param ()

Set-StrictMode -Version Latest
Set-Location -LiteralPath $PSScriptRoot

wsl.exe --update --pre-release

$config = Import-PowerShellDataFile -LiteralPath 'Distro.psd1'
@(wsl.exe --list --all --quiet) |
ForEach-Object { $_ -replace '\0', [string]::Empty } |
Where-Object { $_.Length -gt 0 } -PipelineVariable distro |
ForEach-Object { $config.GetEnumerator() | Where-Object { $_.Name -eq $distro } } |
ForEach-Object {
  wsl.exe --distribution $distro --exec "./$($_.Value.Script)"
  [PSCustomObject]@{
    Distro = $distro
    Script = $_.Value.Script
  }
} | Out-Host

wsl.exe --shutdown >$null 2>&1

try {
  Get-ChildItem -LiteralPath 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss' |
  ForEach-Object { $_.GetValue('BasePath') | Join-Path -ChildPath $_.GetValue('VhdFileName') } |
  Where-Object { Test-Path -LiteralPath $_ } |
  ForEach-Object { [WildcardPattern]::Escape($_) } |
  ForEach-Object { Optimize-VHD -Path $_ -Mode Full }
} catch {
  Write-Warning -Message $_.Exception.Message
}
