---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: Set-ItemDate
---

# Set-ItemDate

## SYNOPSIS

Sets or fixes file and directory timestamps, optionally using EXIF data.

## SYNTAX

### AllDatesPathSet (Default)

```
Set-ItemDate [-Path] <string[]> [-Date] <datetime> [-TimeFix] [-Force] [-WhatIf] [-Confirm]
```

### ExifDatePathSet

```
Set-ItemDate [-Path] <string[]> [-UseExif] [-Force] [-WhatIf] [-Confirm]
```

### EachDatePathSet

```
Set-ItemDate [-Path] <string[]> [-CreationTime <datetime>] [-LastWriteTime <datetime>]
 [-LastAccessTime <datetime>] [-TimeFix] [-Force] [-WhatIf] [-Confirm]
```

### ExifDateLiteralPathSet

```
Set-ItemDate -LiteralPath <string[]> [-UseExif] [-Force] [-WhatIf] [-Confirm]
```

### EachDateLiteralPathSet

```
Set-ItemDate -LiteralPath <string[]> [-CreationTime <datetime>] [-LastWriteTime <datetime>]
 [-LastAccessTime <datetime>] [-TimeFix] [-Force] [-WhatIf] [-Confirm]
```

### AllDatesLiteralPathSet

```
Set-ItemDate [-Date] <datetime> -LiteralPath <string[]> [-TimeFix] [-Force] [-WhatIf] [-Confirm]
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

Sets CreationTime, LastWriteTime, and LastAccessTime for files or directories.
You can set all timestamps at once, set them individually, or update them from EXIF metadata.
Supports wildcards and literal paths.
If CreationTime is later than LastWriteTime, `-TimeFix` will automatically correct it.

## EXAMPLES

### EXAMPLE 1

```powershell
Set-ItemDate -Path 'C:\file.txt' -Date (Get-Date)
```

Sets all timestamps of file.txt to the current date and time.

### EXAMPLE 2

```powershell
Set-ItemDate -Path 'C:\image.jpg' -UseExif
```

Sets timestamps of image.jpg from its EXIF metadata.

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

### -CreationTime

Sets only the CreationTime property.

```yaml
Type: System.Nullable`1[System.DateTime]
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
  - Name: EachDateLiteralPathSet
    Position: Named
    IsRequired: false
    ValueFromPipeline: false
    ValueFromPipelineByPropertyName: false
    ValueFromRemainingArguments: false
  - Name: EachDatePathSet
    Position: Named
    IsRequired: false
    ValueFromPipeline: false
    ValueFromPipelineByPropertyName: false
    ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Date

Sets all timestamps (CreationTime, LastWriteTime, LastAccessTime) to the specified date and time.

```yaml
Type: System.DateTime
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
  - Name: AllDatesLiteralPathSet
    Position: 1
    IsRequired: true
    ValueFromPipeline: false
    ValueFromPipelineByPropertyName: false
    ValueFromRemainingArguments: false
  - Name: AllDatesPathSet
    Position: 1
    IsRequired: true
    ValueFromPipeline: false
    ValueFromPipelineByPropertyName: false
    ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Force

Forces setting timestamps even if the item is read-only or otherwise protected.

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

### -LastAccessTime

Sets only the LastAccessTime property.

```yaml
Type: System.Nullable`1[System.DateTime]
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
  - Name: EachDateLiteralPathSet
    Position: Named
    IsRequired: false
    ValueFromPipeline: false
    ValueFromPipelineByPropertyName: false
    ValueFromRemainingArguments: false
  - Name: EachDatePathSet
    Position: Named
    IsRequired: false
    ValueFromPipeline: false
    ValueFromPipelineByPropertyName: false
    ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -LastWriteTime

Sets only the LastWriteTime property.

```yaml
Type: System.Nullable`1[System.DateTime]
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
  - Name: EachDateLiteralPathSet
    Position: Named
    IsRequired: false
    ValueFromPipeline: false
    ValueFromPipelineByPropertyName: false
    ValueFromRemainingArguments: false
  - Name: EachDatePathSet
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

```yaml
Type: System.String[]
DefaultValue: ''
SupportsWildcards: false
Aliases:
  - PSPath
  - LP
ParameterSets:
  - Name: ExifDateLiteralPathSet
    Position: Named
    IsRequired: true
    ValueFromPipeline: false
    ValueFromPipelineByPropertyName: true
    ValueFromRemainingArguments: false
  - Name: EachDateLiteralPathSet
    Position: Named
    IsRequired: true
    ValueFromPipeline: false
    ValueFromPipelineByPropertyName: true
    ValueFromRemainingArguments: false
  - Name: AllDatesLiteralPathSet
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

Path(s) to the target file(s) or directory(ies).
Wildcards supported.

```yaml
Type: System.String[]
DefaultValue: ''
SupportsWildcards: true
Aliases: []
ParameterSets:
  - Name: ExifDatePathSet
    Position: 0
    IsRequired: true
    ValueFromPipeline: true
    ValueFromPipelineByPropertyName: true
    ValueFromRemainingArguments: false
  - Name: EachDatePathSet
    Position: 0
    IsRequired: true
    ValueFromPipeline: true
    ValueFromPipelineByPropertyName: true
    ValueFromRemainingArguments: false
  - Name: AllDatesPathSet
    Position: 0
    IsRequired: true
    ValueFromPipeline: true
    ValueFromPipelineByPropertyName: true
    ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -TimeFix

If CreationTime is later than LastWriteTime, sets CreationTime to LastWriteTime.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
  - Name: EachDateLiteralPathSet
    Position: Named
    IsRequired: false
    ValueFromPipeline: false
    ValueFromPipelineByPropertyName: false
    ValueFromRemainingArguments: false
  - Name: EachDatePathSet
    Position: Named
    IsRequired: false
    ValueFromPipeline: false
    ValueFromPipelineByPropertyName: false
    ValueFromRemainingArguments: false
  - Name: AllDatesLiteralPathSet
    Position: Named
    IsRequired: false
    ValueFromPipeline: false
    ValueFromPipelineByPropertyName: false
    ValueFromRemainingArguments: false
  - Name: AllDatesPathSet
    Position: Named
    IsRequired: false
    ValueFromPipeline: false
    ValueFromPipelineByPropertyName: false
    ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -UseExif

Updates timestamps from EXIF metadata for supported files (e.g., images with EXIF data).

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
  - Name: ExifDateLiteralPathSet
    Position: Named
    IsRequired: false
    ValueFromPipeline: false
    ValueFromPipelineByPropertyName: false
    ValueFromRemainingArguments: false
  - Name: ExifDatePathSet
    Position: Named
    IsRequired: false
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

### System.String[]

{{ Fill in the Description }}

## OUTPUTS

### System.Void

{{ Fill in the Description }}

## NOTES

This function supports ShouldProcess and can be used with-WhatIf and -Confirm.

## RELATED LINKS

{{ Fill in the related links here }}
