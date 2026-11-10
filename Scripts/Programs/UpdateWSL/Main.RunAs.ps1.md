---
document type: cmdlet
external help file: Main.RunAs.ps1-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: ''
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: Main.RunAs.ps1
---

# Main.RunAs.ps1

## SYNOPSIS

Updates WSL distributions and optimizes virtual hard disks.

## SYNTAX

### __AllParameterSets

```
Main.RunAs.ps1
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

This script updates WSL to the latest pre-release version, executes distribution-specific scripts defined in Distro.psd1, shuts down WSL, and optimizes virtual hard disk files.

## EXAMPLES

## PARAMETERS

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

Requires WSL to be installed.
The script reads distribution scripts from `Distro.psd1` configuration file.

## RELATED LINKS

{{ Fill in the related links here }}
