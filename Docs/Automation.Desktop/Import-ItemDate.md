---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: Import-ItemDate
---

# Import-ItemDate

## SYNOPSIS

Imports file and directory timestamps from a JSON file.

## SYNTAX

### PathSet (Default)

```
Import-ItemDate [-Path] <string[]> [-Force] [-PassThru] [-WhatIf] [-Confirm]
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

Reads one or more JSON files produced by Export-ItemDate and applies the CreationTime, LastWriteTime, and LastAccessTime values to each corresponding file or directory.
When a record's Path property is a relative path, it is interpreted as relative to the folder that contains the JSON file, so the data exported by `Export-ItemDate` can be re-applied under the same relative layout.
By default the command does not emit output; use -PassThru to return each successfully updated file as a FileInfo object.

## EXAMPLES

### EXAMPLE 1

```powershell
Import-ItemDate -Path 'C:\dir\timestamps.json'
```

Restores timestamps from timestamps.json.

### EXAMPLE 2

```powershell
Import-ItemDate -Path 'C:\dir\timestamps.json' -Force
```

Restores timestamps from timestamps.json, including protected files.

### EXAMPLE 3

```powershell
Import-ItemDate -Path @('C:\dir\a.json', 'C:\dir\b.json')
```

Restores timestamps from both JSON files.

### EXAMPLE 4

```powershell
Import-ItemDate -Path 'C:\dir\timestamps.json' -PassThru
```

Applies the timestamp data and returns the FileInfo objects for the updated files.

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

If specified, sets timestamps on read-only items.

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

### -PassThru

If specified, returns the FileInfo object for each successfully updated file.

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

### -Path

Path(s) to the JSON file(s) that contain the timestamp data.
Accepts an array of paths.

```yaml
Type: System.String[]
DefaultValue: ''
SupportsWildcards: false
Aliases:
  - FilePath
  - FullName
ParameterSets:
  - Name: (All)
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

### System.IO.FileInfo

When `-PassThru` is specified

{{ Fill in the Description }}

### System.Void

{{ Fill in the Description }}

## NOTES

This function supports ShouldProcess and can be used with -WhatIf and -Confirm.

## RELATED LINKS

{{ Fill in the related links here }}
