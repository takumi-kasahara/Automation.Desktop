[CmdletBinding()]
param ()

Set-StrictMode -Version Latest
Set-Location -LiteralPath $PSScriptRoot

function Invoke-Robocopy {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ })]
    [string]
    $Source,
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
    [string]
    $Destination
  )
  try {
    $log = $env:TEMP | Join-Path -ChildPath "Robocopy.$(Get-Date -Format 'yyyyMMddHHmmss').log"
    Write-Progress -Activity 'Backup' -Status $Source
    $arguments = @(
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
    Robocopy.exe $Source $Destination @arguments | Out-Null
    # https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy#exit-return-codes
    if ($LASTEXITCODE -ge 8) {
      throw "Robocopy failed with exit code $LASTEXITCODE. See log: $log"
    }
    [PSCustomObject]@{
      Source      = $Source
      Destination = $Destination
      Log         = $log
    }
  }
  finally {
    Write-Progress -Completed
  }
}

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
Where-Object -Property ProcessName -In @(
  'Everything'
  'OneDrive'
) |
Stop-Process -Force

$log = $env:TEMP | Join-Path -ChildPath "BleachBit.$(Get-Date -Format 'yyyyMMddHHmmss').log"
$arguments = @(
  '--clean'
  '--preset'
  '--update-winapp2'
)
bleachbit_console.exe @arguments | Tee-Object -LiteralPath $log
Clear-Host

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
  }
  else {
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

# Dev Drive
# https://learn.microsoft.com/en-us/windows/dev-drive/
try {
  Get-ChildItem -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\AutoAttachVirtualDisks' |
  ForEach-Object { $_.GetValue('Path') } |
  Where-Object { Test-Path -LiteralPath $_ } |
  ForEach-Object { [WildcardPattern]::Escape($_) } |
  ForEach-Object { Optimize-VHD -Path $_ -Mode Full }

  $root = $target | Join-Path -ChildPath 'DevDrives'
  @(Get-Volume | Where-Object -Property FileSystem -EQ 'ReFS' | Select-Object -ExpandProperty DriveLetter) |
  ForEach-Object {
    $source = "$($_):\"
    $destination = $root | Join-Path -ChildPath $_
    Invoke-Robocopy -Source $source -Destination $destination
  } | Out-Host
}
catch {
  Write-Warning -Message $_.Exception.Message
}

# Hyper-V
# https://learn.microsoft.com/en-us/powershell/module/hyper-v/?view=windowsserver2025-ps
try {
  $root = $target | Join-Path -ChildPath 'Hyper-V'
  Get-VM |
  Where-Object -Property State -EQ 'Off' |
  ForEach-Object {
    Get-VMHardDiskDrive -VMName $_.Name |
    ForEach-Object {
      Get-VHD -Path $_.Path |
      Where-Object -Property VhdType -EQ 'Dynamic' |
      Optimize-VHD -Mode Full
    }
    $destination = $root | Join-Path -ChildPath $_.Name
    if (Test-Path -LiteralPath $destination) {
      Remove-Item -LiteralPath $destination -Recurse
    }
    $_ | Export-VM -Path $root
  }
}
catch {
  Write-Warning -Message $_.Exception.Message
}

# WSL
# to restore:
# wsl.exe --import-in-place <DistributionName> <FileName>
# https://learn.microsoft.com/en-us/windows/wsl/basic-commands
try {
  $root = $target | Join-Path -ChildPath 'WSL'
  # Force CommandNotFoundException
  wsl.exe --status >$null

  if (-not (Test-Path -LiteralPath $root)) {
    New-Item -Path $root -ItemType Directory | Out-Null
  }
  @(wsl.exe --list --all --quiet) |
  ForEach-Object { $_ -replace '\0', [string]::Empty } |
  Where-Object -Property Length -GT 0 |
  ForEach-Object { wsl.exe --export $_ $($root | Join-Path -ChildPath "$($_).vhdx") --vhd }
}
catch {
  Write-Warning -Message $_.Exception.Message
}

$config = $target | Join-Path -ChildPath '.config'
# ipconfig
$root = $config | Join-Path -ChildPath 'ipconfig'
if (Test-Path -LiteralPath $root) {
  "$root\*" | Remove-Item
}
else {
  New-Item -Path $root -ItemType Directory | Out-Null
}
ipconfig.exe /all |
Out-File -LiteralPath ($root | Join-Path -ChildPath 'ipconfig.txt')

# https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/netsh-wlan
# to restore:
# netsh.exe wlan add profile filename="<filename>"
$root = $config | Join-Path -ChildPath 'wlan'
if (Test-Path -LiteralPath $root) {
  "$root\*" | Remove-Item
}
else {
  New-Item -Path $root -ItemType Directory | Out-Null
}
netsh.exe wlan export profile key=clear folder="$root"

# https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options
# to restore:
# powercfg.exe /import "<path>" "<guid>"
$root = $config | Join-Path -ChildPath 'powercfg'
if (Test-Path -LiteralPath $root) {
  "$root\*" | Remove-Item
}
else {
  New-Item -Path $root -ItemType Directory | Out-Null
}
powercfg.exe /QUERY |
Out-File -LiteralPath ($root | Join-Path -ChildPath 'powercfg.txt')
$guid = @((powercfg.exe /GETACTIVESCHEME) -split '\s+')[3]
powercfg.exe /EXPORT $($root | Join-Path -ChildPath 'powercfg.pow') $guid
New-Item -Path ($root | Join-Path -ChildPath $guid) -ItemType File | Out-Null
powercfg.exe /BATTERYREPORT /OUTPUT $($root | Join-Path -ChildPath 'batteryreport.html')

# https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/schtasks
# to restore:
# schtasks.exe /create /xml "<path>"
$root = $config | Join-Path -ChildPath 'schtasks'
if (Test-Path -LiteralPath $root) {
  "$root\*" | Remove-Item
}
else {
  New-Item -Path $root -ItemType Directory | Out-Null
}
schtasks.exe /query /xml |
Out-File -LiteralPath ($root | Join-Path -ChildPath 'schtasks.xml')

# https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism-default-application-association-servicing-command-line-options?view=windows-11
# to restore:
# Dism.exe /Online /Import-DefaultAppAssociations:"<path>"
Dism.exe /Online /Export-DefaultAppAssociations:"$($config | Join-Path -ChildPath 'DefaultAssociations.xml')"

$root = $config | Join-Path -ChildPath 'reg'
if (-not (Test-Path -LiteralPath $root)) {
  New-Item -Path $root -ItemType Directory | Out-Null
}
@{
  #region HKLM
  'Run (HKLM)' = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'
  #endregion
  #region HKCU
  'Run (HKCU)' = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Run'
  #endregion
}.GetEnumerator() |
ForEach-Object {
  $destination = $root | Join-Path -ChildPath "$($_.Name).reg"
  [PSCustomObject]$_
  reg.exe export "$($_.Value)" "$destination" /y
} |
Out-Host
