---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: Import-PdfDump
---

# Import-PdfDump

## SYNOPSIS

Imports PDF metadata dump information into PDF files using PDFtk.

## SYNTAX

### __AllParameterSets

```
Import-PdfDump [-Path] <string> -Source <string> -Destination <string> [-Force]
 [-OwnerPassword <securestring>] [-UserPassword <securestring>] [-WhatIf] [-Confirm]
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

Imports PDF metadata dump information into PDF files using PDFtk.
It uses `pdftk.exe update_info_utf8` to apply metadata from a dump file.

## EXAMPLES

### EXAMPLE 1

```powershell
Import-PdfDump -Path 'C:\docs\manual.pdf' -Source 'C:\dir\meta.dump' -Destination 'C:\dir\updated.pdf'
```

Applies metadata from meta.dump and writes the updated PDF to C:\dir.

### EXAMPLE 2

```powershell
$ownerPw = ConvertTo-SecureString -String 'ownerpass' -AsPlainText -Force
$userPw = ConvertTo-SecureString -String 'userpass' -AsPlainText -Force
Import-PdfDump -Path 'C:\docs\manual.pdf' -Source 'C:\dir\meta.dump' -Destination 'C:\dir\updated.pdf' -OwnerPassword $ownerPw -UserPassword $userPw
```

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

Specifies the output path for the updated PDF file.

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

### -Force

If specified, overwrites the destination file if it already exists, including read-only files.

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

Specifies the path of the PDF file to update.

```yaml
Type: System.String
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

### -Source

Specifies the PDF dump file that contains the metadata to import.

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
Standard error output from PDFtk is collected to a temporary log file and the
log file is removed when it remains empty.

## RELATED LINKS

{{ Fill in the related links here }}
