---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: Get-NormalizedPath
---

# Get-NormalizedPath

## SYNOPSIS

Normalizes Windows file and directory paths.

## SYNTAX

### PathSet (Default)

```
Get-NormalizedPath [-Path] <string[]> [-Decompose] [-Compatible]
```

### LiteralPathSet

```
Get-NormalizedPath -LiteralPath <string[]> [-Decompose] [-Compatible]
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

Normalizes each input path by resolving the target item and normalizing the final path component.
Preserves parent directories and converts invalid file name characters as needed.
Use `-Compatible` for compatibility normalization forms and `-Decompose` to decompose Unicode characters before re-composition.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-NormalizedPath -Path 'C:\Users\Public\Document.txt'
```

Returns the normalized form of the specified path.

### EXAMPLE 2

```powershell
Get-NormalizedPath -LiteralPath 'C:\Users\Public\Document.txt' -Compatible
```

Returns the normalized form of the specified path using compatibility normalization forms.

## PARAMETERS

### -Compatible

Uses compatibility normalization forms for path component normalization.

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

### -Decompose

Decomposes Unicode characters before normalization.

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

Specifies literal paths to normalize.

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

Specifies wildcard-compatible paths to normalize.

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

The normalized path.

{{ Fill in the Description }}

### System.String

{{ Fill in the Description }}

## NOTES

This function uses Get-Item to resolve paths and only changes the final path component when normalization is required.

## RELATED LINKS

{{ Fill in the related links here }}
