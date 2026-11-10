---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: Get-ExifDate
---

# Get-ExifDate

## SYNOPSIS

Reads Exif timestamp metadata from image files.

## SYNTAX

### PathSet (Default)

```
Get-ExifDate [-Path] <string[]> [-Recurse] [-AsJson]
```

### LiteralPathSet

```
Get-ExifDate -LiteralPath <string[]> [-Recurse] [-AsJson]
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

Reads Exif timestamps from image files.
It uses `ExifTool.exe` to extract Exif date tags and returns the results as PathInfo objects.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-ExifDate -Path 'C:\Pictures\*.jpg'
```

Returns EXIF timestamps for every matching JPEG file.

### EXAMPLE 2

```powershell
Get-ExifDate -LiteralPath 'C:\Pictures\IMG_0001.JPG' -AsJson
```

Returns EXIF timestamps for the specified file in JSON format.

## PARAMETERS

### -AsJson

Treats ExifTool output as JSON instead of CSV.

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

Specifies literal file paths to inspect.

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

Specifies wildcard-compatible file paths to inspect.

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

### -Recurse

Recursively scans child files when the path resolves to a directory.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

{{ Fill in the Description }}

## OUTPUTS

### System.Management.Automation.PathInfo.

Objects containing the full path and Exif date metadata of each file.

{{ Fill in the Description }}

### System.Management.Automation.PathInfo

{{ Fill in the Description }}

## NOTES

## RELATED LINKS

{{ Fill in the related links here }}
