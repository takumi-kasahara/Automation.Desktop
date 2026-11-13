---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: https://learn.microsoft.com/en-us/windows/win32/shell/folder-getdetailsof
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: Get-ItemDetail
---

# Get-ItemDetail

## SYNOPSIS

Retrieves Windows shell property details for files and folders.

## SYNTAX

### PathSet (Default)

```
Get-ItemDetail [-Path] <string[]> [-Min <int>] [-Max <int>]
```

### LiteralPathSet

```
Get-ItemDetail -LiteralPath <string[]> [-Min <int>] [-Max <int>]
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

Resolves each specified item and enumerates shell metadata for the item using the Windows Shell.Application COM interface.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-ItemDetail -Path 'C:\dir\file.txt' -Min 0 -Max 10
```

Retrieves shell detail fields 0 through 10 for the specified file.

## PARAMETERS

### -LiteralPath

Specifies one or more literal item paths to search.

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

### -Max

The maximum detail index to include.
Defaults to 1024.

```yaml
Type: System.Int32
DefaultValue: '[Math]::Pow(2, 10)'
SupportsWildcards: false
Aliases: []
ParameterSets:
  - Name: (All)
    Position: Named
    IsRequired: false
    ValueFromPipeline: false
    ValueFromPipelineByPropertyName: false
    ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Min

The minimum detail index to include.
Defaults to 0.

```yaml
Type: System.Int32
DefaultValue: 0
SupportsWildcards: false
Aliases: []
ParameterSets:
  - Name: (All)
    Position: Named
    IsRequired: false
    ValueFromPipeline: false
    ValueFromPipelineByPropertyName: false
    ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Path

Specifies one or more item paths to search.
Supports wildcards.

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

### ItemDetail

Objects containing the detail index

{{ Fill in the Description }}

### ItemDetail

{{ Fill in the Description }}

## NOTES

## RELATED LINKS

- [](https://learn.microsoft.com/en-us/windows/win32/shell/folder-getdetailsof)
