---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: https://www.pdflabs.com/docs/pdftk-man-page/#dest-op-burst
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: Split-Pdf
---

# Split-Pdf

## SYNOPSIS

Splits a PDF file into one page per output PDF using PDFtk burst.

## SYNTAX

### PathSet

```
Split-Pdf [-Path] <string> -Destination <string> [-OwnerPassword <securestring>]
 [-UserPassword <securestring>] [-WhatIf] [-Confirm]
```

### LiteralPathSet

```
Split-Pdf -LiteralPath <string> -Destination <string> [-OwnerPassword <securestring>]
 [-UserPassword <securestring>] [-WhatIf] [-Confirm]
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

Split-Pdf reads a single PDF file specified by Path or LiteralPath and
invokes `pdftk.exe burst` to generate one output PDF per page.
The output
file naming pattern is controlled by Destination, and `verbose` is always
appended.
The command rejects directory inputs and non-PDF files.

## EXAMPLES

### EXAMPLE 1

```powershell
Split-Pdf -Path 'C:\docs\manual.pdf' -Destination 'C:\dir\page_%04d.pdf'
```

Splits manual.pdf into numbered page files in C:\dir.

### EXAMPLE 2

```powershell
$ownerPw = ConvertTo-SecureString -String 'ownerpass' -AsPlainText -Force
Split-Pdf -Path 'C:\docs\manual.pdf' -Destination 'C:\dir\page_%04d.pdf' -OwnerPassword $ownerPw
```

Splits a password-protected PDF into numbered page files.

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

Specifies the printf-styled output filename pattern for burst output.
The path is not validated for existence because it contains format placeholders.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
  - Name: (All)
    Position: Named
    IsRequired: true
    ValueFromPipeline: false
    ValueFromPipelineByPropertyName: false
    ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -LiteralPath

Specifies literal path to a single PDF file.

```yaml
Type: System.String
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

Specifies wildcard-compatible path to a single PDF file.

```yaml
Type: System.String
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

### System.String

{{ Fill in the Description }}

## OUTPUTS

### System.Void

{{ Fill in the Description }}

## NOTES

This function requires `pdftk.exe` to be available in the system PATH.

## RELATED LINKS

- [](https://www.pdflabs.com/docs/pdftk-man-page/#dest-op-burst)
