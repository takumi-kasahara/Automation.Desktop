---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: Export-ItemDate
---

# Export-ItemDate

## SYNOPSIS

Exports file and directory timestamps to a JSON file.

## SYNTAX

### PathSet (Default)

```
Export-ItemDate [-Path] <string[]> [-Destination <string>] [-Force] [-NoClobber] [-WhatIf]
 [-Confirm]
```

### LiteralPathSet

```
Export-ItemDate -LiteralPath <string[]> [-Destination <string>] [-Force] [-NoClobber] [-WhatIf]
 [-Confirm]
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

Reads the CreationTime, LastWriteTime, and LastAccessTime of one or more files or directories specified by Path or LiteralPath and writes them to a JSON file specified by Destination.
Supports wildcards via -Path and literal paths via `-LiteralPath`.
When an input item is a directory, recursively enumerates every file within it, including files in subfolders, and exports each file's timestamps.
The Path property in the JSON output is written as a path relative to a base directory.
When the input is a directory, the base directory is the parent of that directory, so the exported paths include the directory name (for example 'dir\file.txt').
When the input is one or more files, the base directory is their common parent directory, so the data can be re-applied on another machine or under a different root.
Use `-Force` to overwrite an existing destination file, or `-NoClobber` to fail if the destination already exists.

## EXAMPLES

### EXAMPLE 1

```powershell
Export-ItemDate -Path 'C:\dir\*' -Destination 'C:\dir\timestamps.json'
```

Exports timestamps for every matching item to a JSON file.

### EXAMPLE 2

```powershell
Export-ItemDate -LiteralPath 'C:\dir\file.txt' -Destination 'C:\dir\timestamps.json' -Force
```

Exports file.txt timestamps and overwrites an existing JSON file.

### EXAMPLE 3

```powershell
Export-ItemDate -LiteralPath 'C:\dir' -Destination 'C:\dir\timestamps.json'
```

Exports the CreationTime, LastWriteTime, and LastAccessTime of every file under C:\dir, including files in subfolders, to a single JSON file.

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

Specifies the path of the JSON file to write the timestamp data to.
When -Destination is
supplied, all inputs are written to that single file.
When -Destination is omitted, each
input directory is written to its own '{folder name}.json' in the parent folder of that
directory, and the function returns one path per directory.
If any input is a file,
-Destination is mandatory and omitting it throws an error.

```yaml
Type: System.String
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

### -Force

If specified, overwrites the destination file if it already exists.

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

Literal path(s) to the target file(s) or directory(ies).
When a directory is specified, all files within it are exported recursively, including files in subfolders.

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

### -NoClobber

If specified, the function will fail if the destination file already exists.

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

Path(s) to the target file(s) or directory(ies).
Wildcards supported.
When a directory is specified, all files within it are exported recursively, including files in subfolders.

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

### System.IO.FileInfo[].

Returns one FileInfo object per output file. When -Destination is supplied

{{ Fill in the Description }}

### System.IO.FileInfo[]

{{ Fill in the Description }}

## NOTES

This function supports ShouldProcess and can be used with -WhatIf and -Confirm.

## RELATED LINKS

{{ Fill in the related links here }}
