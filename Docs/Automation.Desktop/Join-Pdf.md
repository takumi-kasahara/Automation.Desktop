---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: Join-Pdf
---

# Join-Pdf

## SYNOPSIS

Joins PDF files into a single PDF by using PDFtk.

## SYNTAX

### PathSet

```
Join-Pdf [-Path] <string[]> [-Destination <string>] [-Force] [-NoClobber]
 [-OwnerPassword <securestring>] [-UserPassword <securestring>] [-WhatIf] [-Confirm]
```

### LiteralPathSet

```
Join-Pdf -LiteralPath <string[]> [-Destination <string>] [-Force] [-NoClobber]
 [-OwnerPassword <securestring>] [-UserPassword <securestring>] [-WhatIf] [-Confirm]
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

Joins PDF files into a single PDF by using PDFtk.
It uses `pdftk.exe cat output` to merge files.

## EXAMPLES

### EXAMPLE 1

```powershell
Join-Pdf -Path 'C:\docs\manual.pdf' -Destination 'C:\dir\merged.pdf'
```

Joins a single PDF file and writes the result to C:\dir\merged.pdf.

### EXAMPLE 2

```powershell
Join-Pdf -Path 'C:\docs\chapter1.pdf', 'C:\docs\chapter2.pdf' -Destination 'C:\dir\merged.pdf'
```

Joins multiple PDF files in the specified order.

### EXAMPLE 3

```powershell
Join-Pdf -Path 'C:\docs\*.pdf' -Destination 'C:\dir\merged.pdf'
```

Passes the wildcard path directly to PDFtk without expanding it in PowerShell.

### EXAMPLE 4

```powershell
Join-Pdf -Path 'C:\docs'
```

Joins all PDF files that match C:\docs\*.pdf and writes C:\docs.pdf.

### EXAMPLE 5

```powershell
Join-Pdf -LiteralPath 'C:\docs' -Destination 'C:\dir\merged.pdf' -WhatIf
```

Shows what would happen without running pdftk.

### EXAMPLE 6

```powershell
Join-Pdf -LiteralPath 'C:\docs'
```

Joins all PDF files under C:\docs and writes C:\docs.pdf.
Destination is
omitted because the source is a single directory.

### EXAMPLE 7

```powershell
$ownerPw = ConvertTo-SecureString -String 'ownerpass' -AsPlainText -Force
Join-Pdf -Path 'C:\docs\manual.pdf' -Destination 'C:\dir\merged.pdf' -OwnerPassword $ownerPw
```

Joins a password-protected PDF file.

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

Specifies the output PDF path.
When omitted and the source is a single directory, the output defaults to '{directoryName}.pdf' in the parent folder of the directory.
This parameter is optional only when the source is a single directory.

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

If specified, allows overwrite behavior for an existing read-only destination file by temporarily clearing the read-only attribute.

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

Specifies literal paths to source items.
The source items must resolve to PDF files only, or to a single directory.

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

If specified, the function throws an error when Destination already exists.

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

### -OwnerPassword

Specifies the owner password for the PDF file.
Use a SecureString for secure input.

```yaml
Type: System.Security.SecureString
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

### -Path

Specifies wildcard-compatible paths to source items.
Wildcard paths are passed to PDFtk without expansion.
The source items must otherwise resolve to PDF files only, or to a single directory.

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

### -UserPassword

Specifies the user password for the PDF file.
Use a SecureString for secure input.

```yaml
Type: System.Security.SecureString
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

This function requires `pdftk.exe` to be available in the system PATH.
Reference: https://www.pdflabs.com/docs/pdftk-man-page/#dest-op-cat

## RELATED LINKS

{{ Fill in the related links here }}
