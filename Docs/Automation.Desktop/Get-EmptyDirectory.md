---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: Get-EmptyDirectory
---

# Get-EmptyDirectory

## SYNOPSIS

Gets empty directories from one or more paths.

## SYNTAX

### PathSet (Default)

```
Get-EmptyDirectory [-Path] <string[]> [-Recurse]
```

### LiteralPathSet

```
Get-EmptyDirectory -LiteralPath <string[]> [-Recurse]
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

Returns directories that contain no child items.
Accepts wildcards or literal paths and can search recursively when the `-Recurse` switch is specified.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-EmptyDirectory -Path 'C:\dir\*'
```

Returns empty directories directly below C:\dir.

### EXAMPLE 2

```powershell
Get-EmptyDirectory -LiteralPath 'C:\dir' -Recurse
```

Returns empty directories directly below C:\dir when searching recursively.

## PARAMETERS

### -LiteralPath

Specifies literal directory paths to search.

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

Specifies directory paths to search.
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

### -Recurse

Searches child directories recursively.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

{{ Fill in the Description }}

## OUTPUTS

### System.IO.DirectoryInfo

Objects for directories that have no child items.

{{ Fill in the Description }}

### System.IO.DirectoryInfo

{{ Fill in the Description }}

## NOTES

## RELATED LINKS

{{ Fill in the related links here }}
