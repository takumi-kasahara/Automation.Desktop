<#
.SYNOPSIS
  Exports application data to a backup location.

.DESCRIPTION
  This script exports application data (Chocolatey and Winget packages) to a backup location.
  It identifies the user's personal folder, creates a backup directory if needed, and exports installed package lists from both Chocolatey and Winget package managers.

.NOTES
  Requires Chocolatey and Winget to be installed.
  The script exports both Chocolatey and Winget package lists.
#>
using namespace System.IO
using namespace System.Xml.Linq

[CmdletBinding()]
param ()

Set-StrictMode -Version Latest
Set-Location -LiteralPath $PSScriptRoot

$target = Get-SpecialFolder -Name Personal |
Join-Path -ChildPath 'Backups' |
Join-Path -ChildPath 'Devices' |
Join-Path -ChildPath $env:COMPUTERNAME |
Join-Path -ChildPath 'Users' |
Join-Path -ChildPath $env:USERNAME
if (-not (Test-Path -LiteralPath $target)) {
  New-Item -Path $target -ItemType Directory | Out-Null
}

# Chocolatey Packages
try {
  # Force CommandNotFoundException
  choco.exe --version >$null

  $config = ($env:ChocolateyInstall | Join-Path -ChildPath 'config' | Join-Path -ChildPath 'chocolatey.config')
  if (Test-Path -LiteralPath $config) {
    Copy-Item -LiteralPath $config -Destination $target -PassThru
  }

  $packages = [XElement]::new([XElement]::new('packages', $null))
  foreach ($line in @(choco.exe list --limit-output)) {
    $param = $line -split '\|'
    $id = $param[0]
    $version = $param[1]
    $package = [XElement]::new('package', $null)
    $package.Add([XAttribute]::new('id', $id))
    $package.Add([XAttribute]::new('version', $version))
    $packages.Add($package)
  }

  $destination = $target | Join-Path -ChildPath 'packages.config'
  $xml = [XDocument]::new([XDeclaration]::new('1.0', 'utf-8', $null))
  $xml.Add($packages)
  $xml.Save($destination)
  Get-Item -LiteralPath $destination
} catch {
  Write-Warning -Message $_.Exception.Message
}

# Winget Packages
try {
  # Force CommandNotFoundException
  winget.exe --version >$null

  @(
    'source'
    'settings'
    'features'
  ) |
  ForEach-Object {
    $command = $_
    $destination = $target | Join-Path -ChildPath "winget.$command.json"
    winget.exe $command export |
    Out-File -LiteralPath $destination
    Get-Item -LiteralPath $destination
  }

  $destination = $target | Join-Path -ChildPath 'winget.packages.json'
  try {
    $temp = [Path]::GetTempFileName()
    winget.exe export --include-versions --accept-source-agreements --output $temp
    $json = Get-Content -Path $temp -Raw | ConvertFrom-Json
  } finally {
    if (Test-Path -LiteralPath $temp) {
      Remove-Item -LiteralPath $temp
    }
  }
  $json.Sources.Packages |
  Where-Object { @($_ | Get-Member -Name 'Scope').Count -eq 0 } |
  ForEach-Object { $_ | Add-Member -MemberType NoteProperty -Name 'Scope' -Value 'machine' }
  $json.Sources |
  ForEach-Object { $_.Packages = $_.Packages | Sort-Object -Property PackageIdentifier }
  $json |
  ConvertTo-Json -Depth 100 |
  Out-File -LiteralPath $destination
  Get-Item -LiteralPath $destination
} catch {
  Write-Warning -Message $_.Exception.Message
}

# Visual Studio Code
$destination = $target | Join-Path -ChildPath 'extensions.txt'
foreach ($program in @(
    'code.cmd'
    'code-insiders.cmd'
  )
) {
  # Force CommandNotFoundException
  try {
    & $program --version >$null
    @(& $program --list-extensions) |
    Sort-Object |
    Out-File -LiteralPath $destination
    Get-Item -LiteralPath $destination
    break
  } catch {
    Write-Warning -Message $_.Exception.Message
    continue
  }
}

# .NET Global Tools
try {
  # Force CommandNotFoundException
  dotnet.exe --version >$null

  $destination = $target | Join-Path -ChildPath 'dotnet-tools.json'
  dotnet.exe tool list --global --format json |
  Out-File -LiteralPath $destination
  Get-Item -LiteralPath $destination
} catch {
  Write-Warning -Message $_.Exception.Message
}

# NuGet
try {
  # Force CommandNotFoundException
  nuget.exe help >$null

  $config = $env:APPDATA | Join-Path -ChildPath 'NuGet' | Join-Path -ChildPath 'NuGet.Config'
  if (Test-Path -LiteralPath $config) {
    Copy-Item -LiteralPath $config -Destination $target -PassThru
  }
} catch {
  Write-Warning -Message $_.Exception.Message
}

# npm
try {
  # Force CommandNotFoundException
  npm.cmd --version >$null

  $destination = $target | Join-Path -ChildPath 'npmrc.json'
  npm.cmd config list --json --global |
  Out-File -LiteralPath $destination
  Get-Item -LiteralPath $destination

  $destination = $target | Join-Path -ChildPath 'package.json'
  npm.cmd list --json --global --depth=0 |
  Out-File -LiteralPath $destination
  Get-Item -LiteralPath $destination
} catch {
  Write-Warning -Message $_.Exception.Message
}

# pip
try {
  # Force CommandNotFoundException
  pip.exe --version >$null

  $config = $env:APPDATA | Join-Path -ChildPath 'pip' | Join-Path -ChildPath 'pip.ini'
  if (Test-Path -LiteralPath $config) {
    Copy-Item -LiteralPath $config -Destination $target -PassThru
  }

  $destination = $target | Join-Path -ChildPath 'requirements.txt'
  $requirements = @(pip.exe freeze)
  if ($requirements.Count -gt 0) {
    $requirements |
    Out-File -LiteralPath $destination
    Get-Item -LiteralPath $destination
  }
} catch {
  Write-Warning -Message $_.Exception.Message
}

$config = $target | Join-Path -ChildPath '.config'
if (-not (Test-Path -LiteralPath $config)) {
  New-Item -Path $config -ItemType Directory | Out-Null
}
(Import-PowerShellDataFile -LiteralPath 'File.psd1').GetEnumerator() |
ForEach-Object {
  $path = 'Env:\' | Join-Path -ChildPath $_.Name
  if (-not (Test-Path -LiteralPath $path)) {
    return
  }
  $item = Get-Item -LiteralPath $path
  $item.Value | Join-Path -ChildPath $_.Value |
  Get-Item |
  ForEach-Object {
    $destination = $config | Join-Path -ChildPath "$($_.Name)"
    Copy-Item -LiteralPath $_.FullName -Destination $destination -PassThru
  }
}
(Import-PowerShellDataFile -LiteralPath 'Registry.psd1').GetEnumerator() |
ForEach-Object {
  $destination = $config | Join-Path -ChildPath "$($_.Key).reg"
  reg.exe export "$($_.Value)" "$destination" /y >$null
  if (Test-Path -LiteralPath $destination) {
    Get-Item -LiteralPath $destination
  }
}
