using namespace System.Management.Automation

[CmdletBinding()]
param ()

$ErrorActionPreference = [ActionPreference]::Stop
Set-StrictMode -Version Latest
Set-Location -LiteralPath $PSScriptRoot

reg.exe export 'HKCU\Environment' ($env:TEMP | Join-Path -ChildPath "User.$(Get-Date -Format 'yyyyMMddHHmmss').reg") /y >$null
& {
  $user = @(
    [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::User) -split ';' |
    ForEach-Object { $_.Trim() -replace '\\$' } |
    Where-Object { ![string]::IsNullOrEmpty($_) } |
    Where-Object {
      if ((Test-Path -LiteralPath $_) -or (Test-Path -LiteralPath (Expand-EnvironmentVariable -InputString $_))) {
        return $true
      }
      Write-Warning -Message "$_ not found."
      return $false
    } |
    ForEach-Object { Expand-EnvironmentVariable -InputString $_ }
  ) | Sort-Object -Unique
  $user | Out-Host
  [Environment]::SetEnvironmentVariable('Path', ($user -join ';'), [EnvironmentVariableTarget]::User)
}
reg.exe export 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' ($env:TEMP | Join-Path -ChildPath "Machine.$(Get-Date -Format 'yyyyMMddHHmmss').reg") /y >$null
& {
  $machine = @(
    [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine) -split ';' |
    ForEach-Object { $_.Trim() -replace '\\$' } |
    Where-Object { ![string]::IsNullOrEmpty($_) } |
    Where-Object {
      if ((Test-Path -LiteralPath $_) -or (Test-Path -LiteralPath (Expand-EnvironmentVariable -InputString $_))) {
        return $true
      }
      Write-Warning -Message "$_ not found."
      return $false
    } |
    ForEach-Object { Expand-EnvironmentVariable -InputString $_ }
  ) | Sort-Object -Unique
  $added = @(
    '7z.exe'
    'AutoHotkey.exe'
    'bleachbit_console.exe'
    'qpdf.exe'
  ) |
  Where-Object { -not (Get-Command $_ -ErrorAction SilentlyContinue) } |
  ForEach-Object {
    $appName = Find-Application -Name $_ 2>$null | Select-Object -First 1
    if ([string]::IsNullOrEmpty($appName)) {
      $appName = Get-Application -Name $_ 2>$null | Select-Object -ExpandProperty Path -First 1
    }
    if ([string]::IsNullOrEmpty($appName)) {
      Write-Warning -Message "$_ not found."
      return $null
    }
    $parent = Split-Path -Path $appName -Parent
    if ($parent -and (Test-Path -LiteralPath $parent -PathType Container)) {
      return $parent
    }
  } | Sort-Object -Unique
  if (@($added).Count -gt 0) {
    $machine += $added
    $added | ForEach-Object { "Added:`t$_" | Out-Host }
  }
  $machine = $machine | Sort-Object -Unique
  $machine | Out-Host
  [Environment]::SetEnvironmentVariable('Path', ($machine -join ';'), [EnvironmentVariableTarget]::Machine)
}
