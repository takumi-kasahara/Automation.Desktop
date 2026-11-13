---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: ConvertTo-LocalPath
---

# ConvertTo-LocalPath

## SYNOPSIS

Converts a network share path to its local filesystem path.

## SYNTAX

### PathSet (Default)

```
ConvertTo-LocalPath [-Path] <string[]>
```

### LiteralPathSet

```
ConvertTo-LocalPath -LiteralPath <string[]>
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

Accepts a UNC path that begins with a share name and converts it to the corresponding local path on the current computer.
When a matching Win32 share is found, the share prefix is replaced with the share's local path.
Non-UNC paths are returned unchanged after optional environment-variable compression.

## EXAMPLES

### EXAMPLE 1

```powershell
ConvertTo-LocalPath -Path '\\MYPC\Share\Folder\File.txt'
```

Converts a UNC path to its local path when the share is available locally.

### EXAMPLE 2

```powershell
ConvertTo-LocalPath -LiteralPath '\\MYPC\Share\Folder\File.txt'
```

Converts the specified literal UNC path to its local path when the share is available locally.

## PARAMETERS

### -LiteralPath

Specifies literal UNC or local paths to convert.

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

Specifies wildcard-compatible UNC or local paths to convert.

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

{{ Fill in the Description }}

## NOTES

This function uses Win32 share information from Get-CimInstance.
It also delegates environment-variable compression to Compress-EnvironmentVariable.

## RELATED LINKS

{{ Fill in the related links here }}
