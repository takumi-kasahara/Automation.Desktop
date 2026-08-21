# Automation.Desktop

A collection of PowerShell modules and helper scripts for Windows file system, path, shell, and utility automation.

## Requirements

- Windows 11
- PowerShell 7
  - [Pester v6](https://pester.dev/docs/introduction/installation)
  - [PSScriptAnalyzer](https://learn.microsoft.com/en-us/powershell/utility-modules/psscriptanalyzer/overview?view=ps-modules)
- Windows Script Host Version 10.0

## Installation

Run from the repository root:

```powershell
./Install.bat
```

If you want to install Pester v6, run:

```powershell
Install-Module -Name Pester -Scope CurrentUser
```

If you want to run tests:

```powershell
. .\Pester.ps1
```
