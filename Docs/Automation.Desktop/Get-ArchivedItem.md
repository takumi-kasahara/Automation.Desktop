---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: Get-ArchivedItem
---

# Get-ArchivedItem

## SYNOPSIS

Reads archived file metadata from a 7-Zip archive.

## SYNTAX

### PathSet (Default)

```
Get-ArchivedItem [-Path] <string[]> [-Encoding <Encoding>]
```

### LiteralPathSet

```
Get-ArchivedItem -LiteralPath <string[]> [-Encoding <Encoding>]
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

Reads archived file metadata from a 7-Zip archive.
It uses `7z.exe` to list entries and parse their details.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-ArchivedItem -Path 'C:\Archives\*.7z'
```

Lists the contents of every matching 7z archive.

### EXAMPLE 2

```powershell
Get-ArchivedItem -LiteralPath 'C:\Archives\release.7z' -Encoding ([System.Text.Encoding]::UTF8)
```

Lists the contents of the specified archive with UTF-8 encoding.

## PARAMETERS

### -Encoding

Specifies the text encoding to use for 7-Zip output.
When provided, the function passes `-mcp=<codepage>` to `7z.exe`.

```yaml
Type: System.Text.Encoding
DefaultValue: ''
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

Specifies literal archive paths to inspect.

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

Specifies wildcard-compatible archive paths to inspect.

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

### ArchivedItem

Objects containing the relative path and timestamps of each archived item.

{{ Fill in the Description }}

### ArchivedItem

{{ Fill in the Description }}

## NOTES

## RELATED LINKS

{{ Fill in the related links here }}
