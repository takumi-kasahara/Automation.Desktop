---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: Sync-DirectoryDate
---

# Sync-DirectoryDate

## SYNOPSIS

Synchronizes directory timestamps from child file timestamps.

## SYNTAX

### PathSet (Default)

```
Sync-DirectoryDate [-Path] <string[]> [-Force] [-WhatIf] [-Confirm]
```

### LiteralPathSet

```
Sync-DirectoryDate -LiteralPath <string[]> [-Force] [-WhatIf] [-Confirm]
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

Updates the CreationTime, LastWriteTime, and LastAccessTime of one or more directories based on the timestamps of child files.
Computes the earliest CreationTime and the latest LastWriteTime and LastAccessTime among all nested files, then applies those values to each target directory.
If a directory contains no files, writes a warning and does not modify that directory.

## EXAMPLES

### EXAMPLE 1

```powershell
Sync-DirectoryDate -Path 'C:\dir\*'
```

Synchronizes timestamps for every matching directory.

### EXAMPLE 2

```powershell
Sync-DirectoryDate -LiteralPath 'C:\dir\subdir' -Force
```

Synchronizes the timestamp of subdir with its contents and suppresses confirmation prompts.

## PARAMETERS

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

Forces child enumeration and timestamp sync for protected files.

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

Literal path(s) to target directories.

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

Path(s) to target directories.
Wildcards supported.

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

## RELATED LINKS

{{ Fill in the related links here }}
