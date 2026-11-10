---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: ConvertTo-NetworkPath
---

# ConvertTo-NetworkPath

## SYNOPSIS

Converts a local filesystem path to a network share path.

## SYNTAX

### PathSet (Default)

```
ConvertTo-NetworkPath [-Path] <string[]>
```

### LiteralPathSet

```
ConvertTo-NetworkPath -LiteralPath <string[]>
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

Accepts a local path that begins with a shared folder path and converts it to the corresponding UNC path on the current computer.
If the local path does not match a defined Win32 share, the local path is returned.

## EXAMPLES

### EXAMPLE 1

```powershell
ConvertTo-NetworkPath -Path 'C:\Shared\Folder\File.txt'
```

Converts a local path to its corresponding UNC path.

### EXAMPLE 2

```powershell
ConvertTo-NetworkPath -LiteralPath 'C:\Shared\Folder\File.txt'
```

Converts the specified local path to its corresponding UNC path.

## PARAMETERS

### -LiteralPath

Specifies literal local or UNC paths to convert.

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

Specifies wildcard-compatible local or UNC paths to convert.

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

### System.String

The converted UNC network path.

{{ Fill in the Description }}

### System.String

{{ Fill in the Description }}

## NOTES

This function uses Win32 share information from Get-CimInstance.

## RELATED LINKS

{{ Fill in the related links here }}
