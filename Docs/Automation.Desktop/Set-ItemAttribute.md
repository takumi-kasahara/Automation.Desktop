---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: Set-ItemAttribute
---

# Set-ItemAttribute

## SYNOPSIS

Sets one or more file or directory attributes.

## SYNTAX

### PathSet (Default)

```
Set-ItemAttribute [-Path] <string[]> [-Attribute] <FileAttributes> [-Force] [-WhatIf] [-Confirm]
```

### LiteralPathSet

```
Set-ItemAttribute [-Attribute] <FileAttributes> -LiteralPath <string[]> [-Force] [-WhatIf]
 [-Confirm]
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

Updates the specified item's file attributes by adding the requested attribute flags.

## EXAMPLES

### EXAMPLE 1

```powershell
Set-ItemAttribute -Path 'C:\dir\*' -Attribute ReadOnly
```

Sets the ReadOnly attribute on every matching item.

### EXAMPLE 2

```powershell
Set-ItemAttribute -LiteralPath 'C:\dir\file.txt' -Attribute Hidden -Force
```

Sets the Hidden attribute on file.txt and forces the update even if the file is read-only.

## PARAMETERS

### -Attribute

The file attribute flag(s) to add to the target item.

```yaml
Type: System.IO.FileAttributes
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
  - Name: (All)
    Position: 1
    IsRequired: true
    ValueFromPipeline: false
    ValueFromPipelineByPropertyName: false
    ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: ''
SupportsWildcards: false
Aliases:
  - cf
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

### -Force

Forces the attribute update even if the item already has the requested attribute.
If not specified, skips items that already have the attribute.

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

Specifies one or more literal paths to files or directories.

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

Specifies one or more paths to files or directories.
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

### -WhatIf

Runs the command in a mode that only reports what would happen without performing the actions.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: ''
SupportsWildcards: false
Aliases:
  - wi
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

### System.Void

{{ Fill in the Description }}

## NOTES

This cmdlet modifies file system object attributes and does not emit output when the operation succeeds.

## RELATED LINKS

{{ Fill in the related links here }}
