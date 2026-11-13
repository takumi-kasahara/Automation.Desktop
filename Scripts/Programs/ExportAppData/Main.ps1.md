---
document type: cmdlet
external help file: Main.ps1-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: ''
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: Main.ps1
---

# Main.ps1

## SYNOPSIS

Exports application data to a backup location.

## SYNTAX

### __AllParameterSets

```
Main.ps1
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

This script exports application data (Chocolatey and Winget packages) to a backup location.
It identifies the user's personal folder, creates a backup directory if needed, and exports installed package lists from both Chocolatey and Winget package managers.

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

Requires Chocolatey and Winget to be installed.
The script exports both Chocolatey and Winget package lists.

## RELATED LINKS

{{ Fill in the related links here }}
