---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: Get-DuplicateFile
---

# Get-DuplicateFile

## SYNOPSIS

Finds duplicate files in directories by extension, size, and hash.

## SYNTAX

### PathSet (Default)

```
Get-DuplicateFile [-Path] <string[]> [-Recurse] [-Property <string[]>] [-Descending] [-Skip <int>]
```

### LiteralPathSet

```
Get-DuplicateFile -LiteralPath <string[]> [-Recurse] [-Property <string[]>] [-Descending]
 [-Skip <int>]
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

Scans one or more directories, groups files by extension and length, computes SHA256 hashes for matching candidates, and returns duplicate file objects.
Sorts each duplicate group according to the specified properties and skips the first item in each group, so only duplicate copies are returned.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-DuplicateFile -Path 'C:\dir\*' -Recurse
```

Returns duplicate files found recursively below C:\dir.

### EXAMPLE 2

```powershell
Get-DuplicateFile -LiteralPath 'C:\dir' -Property 'CreationTime','LastWriteTime' -Descending -Skip 2
```

Returns duplicate files in C:\dir, sorted by CreationTime and LastWriteTime in descending order, skipping the first 2 items in each duplicate group.

## PARAMETERS

### -Descending

Sorts by the specified property values in descending order.

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

### -Property

Specifies one or more file properties used to sort duplicates before skipping the first item.

```yaml
Type: System.String[]
DefaultValue: >-
  @(
        'LastWriteTime'
        'CreationTime'
      )
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

### -Skip

Skips the first N items in each duplicate group and returns the rest.

```yaml
Type: System.Int32
DefaultValue: 1
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

### System.IO.FileInfo

Objects for duplicate files only.

{{ Fill in the Description }}

### System.IO.FileInfo

{{ Fill in the Description }}

## NOTES

## RELATED LINKS

{{ Fill in the related links here }}
