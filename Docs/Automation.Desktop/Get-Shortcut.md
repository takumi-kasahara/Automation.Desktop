---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: Get-Shortcut
---

# Get-Shortcut

## SYNOPSIS

Returns a Windows shortcut object for the specified file path.

## SYNTAX

### PathSet (Default)

```
Get-Shortcut [-Path] <string[]>
```

### LiteralPathSet

```
Get-Shortcut -LiteralPath <string[]>
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

Resolves the specified shortcut path and returns a
`WScript.Shell` shortcut object.
Supports both wildcard-aware
`-Path` input and literal `-LiteralPath` input.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-Shortcut -Path 'C:\Users\Public\Desktop\Example.lnk'
```

Returns the properties of the matching shortcut.

### EXAMPLE 2

```powershell
Get-Shortcut -LiteralPath 'C:\Users\Public\Desktop\Example.lnk'
```

## PARAMETERS

### -LiteralPath

Specifies one or more exact shortcut file paths.

```yaml
Type: System.String[]
DefaultValue: ''
SupportsWildcards: false
Aliases:
  - PSPath
  - LP
ParameterSets:
  - Name: LiteralPathSet
    Position: Named
    IsRequired: true
    ValueFromPipeline: false
    ValueFromPipelineByPropertyName: true
    ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Path

Specifies one or more shortcut file paths, with wildcard support.

```yaml
Type: System.String[]
DefaultValue: ''
SupportsWildcards: true
Aliases: []
ParameterSets:
  - Name: PathSet
    Position: 0
    IsRequired: true
    ValueFromPipeline: true
    ValueFromPipelineByPropertyName: true
    ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

{{ Fill in the Description }}

## OUTPUTS

### System.__ComObject

The shortcut COM object.

{{ Fill in the Description }}

### System.__ComObject

{{ Fill in the Description }}

## NOTES

Returns the COM shortcut object created by `WScript.Shell`.

## RELATED LINKS

{{ Fill in the related links here }}
