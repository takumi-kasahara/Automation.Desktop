---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: Get-PdfPage
---

# Get-PdfPage

## SYNOPSIS

Retrieves the page count of PDF files using QPDF.

## SYNTAX

### PathSet (Default)

```
Get-PdfPage [-Path] <string[]> [-OwnerPassword <securestring>] [-UserPassword <securestring>]
```

### LiteralPathSet

```
Get-PdfPage -LiteralPath <string[]> [-OwnerPassword <securestring>] [-UserPassword <securestring>]
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

Get-PdfPage reads PDF files specified by Path or LiteralPath and invokes
`qpdf.exe --show-npages` to obtain the number of pages in each file.
It returns objects containing the original file item and the parsed page count.
Standard error output from QPDF is written to a temporary log file that is removed when it remains empty.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-PdfPage -Path 'C:\docs\*.pdf'
```

Returns the page count for each matching PDF file.

### EXAMPLE 2

```powershell
Get-PdfPage -LiteralPath 'C:\docs\manual.pdf'
```

Returns the page count for manual.pdf.

### EXAMPLE 3

```powershell
$ownerPw = ConvertTo-SecureString -String 'owner123' -AsPlainText -Force
Get-PdfPage -LiteralPath 'C:\docs\encrypted.pdf' -OwnerPassword $ownerPw
```

Returns the page count for an encrypted PDF file using the owner password.

## PARAMETERS

### -LiteralPath

Specifies literal PDF file paths to inspect.

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

### -OwnerPassword

Specifies the owner password for encrypted PDF files.
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

Specifies wildcard-compatible PDF file paths to inspect.

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

Specifies the user password for encrypted PDF files.
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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

{{ Fill in the Description }}

## OUTPUTS

### PdfInfo

Object containing the PDF file item and its page count.

{{ Fill in the Description }}

## NOTES

This function requires `qpdf.exe` to be available in the system PATH.

## RELATED LINKS

{{ Fill in the related links here }}
