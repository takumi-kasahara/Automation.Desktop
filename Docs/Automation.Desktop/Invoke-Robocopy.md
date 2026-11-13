---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: Invoke-Robocopy
---

# Invoke-Robocopy

## SYNOPSIS

Mirrors a source directory to a destination using Robocopy.

## SYNTAX

### __AllParameterSets

```
Invoke-Robocopy [-Source] <string> [-Destination] <string> [-NoClobber] [-NDL] [-NFL] [-WhatIf]
 [-Confirm]
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

Mirrors a source directory to a destination using Robocopy.
It uses `Robocopy.exe` with mirroring options to replicate files.
Displays progress, writes a log to the TEMP directory.
Returns an object describing the operation.
Emits warnings if Robocopy reports a serious error (exit code >= 8).
Supports -WhatIf.
When specified, Robocopy runs with /L so no files are copied, moved, or deleted.

## EXAMPLES

### EXAMPLE 1

```powershell
Invoke-Robocopy -Source 'C:\Data' -Destination 'D:\Backup\Data'
```

Mirrors C:\Data to D:\Backup\Data and returns the operation details.

### EXAMPLE 2

```powershell
Invoke-Robocopy -Source 'C:\Data' -Destination 'D:\Backup\Data' -WhatIf
```

Lists the files that would be copied or deleted without making any changes.

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

### -Destination

The destination directory path to copy to.
Must be a valid path.

```yaml
Type: System.String
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

### -NDL

No Directory List: Do not output directory names during the Robocopy operation.

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

### -NFL

No File List: Do not output file names during the Robocopy operation.

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

### -NoClobber

Exclude Changed files: Do not overwrite files that exist in the destination but have changed in the source.
Throws an exception if the destination path already exists.

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

### -Source

The source directory path to copy from.
Must exist.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
  - Name: (All)
    Position: 0
    IsRequired: true
    ValueFromPipeline: false
    ValueFromPipelineByPropertyName: false
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

## OUTPUTS

### System.Management.Automation.PSCustomObject

    Object containing the Source

{{ Fill in the Description }}

### System.Management.Automation.PSObject

{{ Fill in the Description }}

## NOTES

Uses /MIR, so files missing in the source are deleted from the destination.
Robocopy exit codes: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy#exit-return-codes

## RELATED LINKS

{{ Fill in the related links here }}
