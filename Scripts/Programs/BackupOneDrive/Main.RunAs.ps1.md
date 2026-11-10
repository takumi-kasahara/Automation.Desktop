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

Backs up OneDrive data to an external drive.

## SYNTAX

### __AllParameterSets

```
Main.RunAs.ps1
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

This script backs up OneDrive data to an external USB drive.
It identifies USB drives, stops the OneDrive process, and copies files from the OneDrive directory to the backup location.

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

Requires admin privileges to access external drives.
The script stops the OneDrive process before copying files.

## RELATED LINKS

{{ Fill in the related links here }}
