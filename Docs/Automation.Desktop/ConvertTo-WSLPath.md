---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: ConvertTo-WSLPath
---

# ConvertTo-WSLPath

## SYNOPSIS

Converts a Windows path to a WSL path.

## SYNTAX

### PathSet (Default)

```
ConvertTo-WSLPath [-Path] <string[]> [-ArgumentList <string[]>]
```

### LiteralPathSet

```
ConvertTo-WSLPath -LiteralPath <string[]> [-ArgumentList <string[]>]
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

Converts a Windows filesystem path into the corresponding WSL (Windows Subsystem for Linux) path by invoking `wsl.exe wslpath -a -u`.
Accepts wildcard and literal paths and returns the converted path string(s).

## EXAMPLES

### EXAMPLE 1

```powershell
ConvertTo-WSLPath -Path 'C:\Users\User\file.txt'
```

Converts the Windows path to its WSL representation.

### EXAMPLE 2

```powershell
ConvertTo-WSLPath -LiteralPath 'C:\Users\User\file.txt' -ArgumentList '--quiet'
```

Converts the specified Windows path to its WSL representation without displaying output.

## PARAMETERS

### -ArgumentList

Specifies additional arguments passed to `wsl.exe` before `wslpath`.

```yaml
Type: System.String[]
DefaultValue: '@()'
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

Specifies literal Windows paths to convert.

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

Specifies wildcard-compatible Windows paths to convert.

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

The converted WSL path.

{{ Fill in the Description }}

## NOTES

This function uses `Get-Item` to resolve the input path and delegates path
conversion to WSL via `wsl.exe`.

## RELATED LINKS

{{ Fill in the related links here }}
