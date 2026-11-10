---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: Test-Shortcut
---

# Test-Shortcut

## SYNOPSIS

Verifies that a shortcut points to an existing target.

## SYNTAX

### PathSet (Default)

```
Test-Shortcut [-Path] <string[]>
```

### LiteralPathSet

```
Test-Shortcut -LiteralPath <string[]>
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

Resolves the specified shortcut file path, reads the target path
from the shortcut, and returns `True` when the shortcut target exists.
Supports wildcard-aware `-Path` input and exact `-LiteralPath` input.

## EXAMPLES

### EXAMPLE 1

```powershell
Test-Shortcut -Path 'C:\Users\Public\Desktop\Example.lnk'
```

Tests whether the matching shortcut target is valid.

### EXAMPLE 2

```powershell
Test-Shortcut -LiteralPath 'C:\Users\Public\Desktop\Example.lnk'
```

Tests whether the specified shortcut target is valid.

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

### System.Boolean

True if the shortcut target exists; otherwise

{{ Fill in the Description }}

### System.Boolean

{{ Fill in the Description }}

## NOTES

Returns a boolean value indicating whether the shortcut target exists.

## RELATED LINKS

{{ Fill in the related links here }}
