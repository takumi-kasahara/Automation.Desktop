# Automation.Desktop

A collection of PowerShell modules and helper scripts for Windows file system, path, shell, and utility automation.

## Requirements

- Windows 11
- PowerShell 7
  - [Pester v6](https://pester.dev/docs/introduction/installation)
  - [PlatyPS](https://learn.microsoft.com/en-us/powershell/utility-modules/platyps/overview?view=ps-modules)
  - [PSScriptAnalyzer](https://learn.microsoft.com/en-us/powershell/utility-modules/psscriptanalyzer/overview?view=ps-modules)
- Windows Script Host Version 10.0

## Installation

Run from the repository root:

```powershell
.\Install.cmd
```

If you want to install Pester v6, run:

```powershell
Install-PSResource -Name Pester
```

If you want to install PlatyPS, run:

```powershell
Install-PSResource -Name Microsoft.PowerShell.PlatyPS
```

If you want to install PSScriptAnalyzer, run:

```powershell
Install-PSResource -Name PSScriptAnalyzer
```
