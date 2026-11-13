---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: Compare-Csv
---

# Compare-Csv

## SYNOPSIS

Compares two CSV files by row hash and returns mismatch summaries.

## SYNTAX

### __AllParameterSets

```
Compare-Csv [-ReferencePath] <string> [-DifferencePath] <string> [-OnlyReference] [-OnlyDifference]
 [-Delimiter <char>] [-NoHeader]
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

Imports two CSV files, computes a SHA-256 hash for each row, and groups rows by hash.
For hashes present in both files, this function compares occurrence counts and reports mismatches with line positions.
For hashes present in only one file, this function reports the side and line positions.
When NoHeader is specified, the function generates headers (Column 1, Column 2, ...) from the first line of each file.

## EXAMPLES

### EXAMPLE 1

```powershell
Compare-Csv -ReferencePath '.\reference.csv' -DifferencePath '.\difference.csv'
```

Compares two comma-delimited CSV files and returns mismatch records.

### EXAMPLE 2

```powershell
Compare-Csv -ReferencePath '.\reference.tsv' -DifferencePath '.\difference.tsv' -Delimiter "`t"
```

Compares two tab-delimited files and returns mismatch records.

### EXAMPLE 3

```powershell
Compare-Csv -ReferencePath '.\reference-no-header.csv' -DifferencePath '.\difference-no-header.csv' -NoHeader
```

Compares two headerless CSV files using generated column names.

## PARAMETERS

### -Delimiter

The delimiter character used in both CSV files.
The default delimiter is a comma (,).

```yaml
Type: System.Char
DefaultValue: ','
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

### -DifferencePath

The path to the difference CSV file to compare against the reference file.

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

### -NoHeader

Indicates that input CSV files do not have a header row.
When specified, headers are generated automatically from the first line column count.

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

### -OnlyDifference

Limits the output to mismatches involving difference-side rows.
When specified, reference-only mismatches are suppressed, and for differing occurrence counts the difference side is selected.

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

### -OnlyReference

Limits the output to mismatches involving reference-side rows.
When specified, difference-only mismatches are suppressed, and for differing occurrence counts the reference side is selected.

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

### -ReferencePath

The path to the reference CSV file.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### CompareCsvMismatch[]

Object containing Path

{{ Fill in the Description }}

### CompareCsvMismatch[]

{{ Fill in the Description }}

## NOTES

One-sided mismatches include similarity candidates ordered by Levenshtein-based similarity.

## RELATED LINKS

{{ Fill in the related links here }}
