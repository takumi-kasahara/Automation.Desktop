---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: Compress-EnvironmentVariable
---

# Compress-EnvironmentVariable

## SYNOPSIS

Replaces environment variable values in a string with %NAME% tokens.

## SYNTAX

### __AllParameterSets

```
Compress-EnvironmentVariable [[-InputString] <string>]
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

Scans the input string for environment variable values and replaces each occurrence with the corresponding variable name wrapped in percent signs (for example, %PATH%).
Uses all environment variables from the Env: provider, sorting them by the length of their value in descending order to ensure longer values are replaced before shorter substrings.

## EXAMPLES

### EXAMPLE 1

```powershell
Compress-EnvironmentVariable -InputString 'Path is C:\Users\User; temp is C:\dir'
```

Replaces matching path values with environment-variable references.

### EXAMPLE 2

```powershell
Compress-EnvironmentVariable -InputString 'My home is C:\Users\User and path is C:\Users'
```

Replaces matching path values with environment-variable references.

## PARAMETERS

### -InputString

The string to compress by replacing environment variable values.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
  - Name: (All)
    Position: 0
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

## OUTPUTS

### System.String

The compressed string with environment variables replaced.

{{ Fill in the Description }}

### System.String

{{ Fill in the Description }}

## NOTES

Empty environment variable values are ignored.

## RELATED LINKS

{{ Fill in the related links here }}
