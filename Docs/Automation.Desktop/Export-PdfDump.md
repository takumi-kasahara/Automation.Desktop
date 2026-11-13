---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: Export-PdfDump
---

# Export-PdfDump

## SYNOPSIS

Exports PDF metadata dump information using PDFtk.

## SYNTAX

### __AllParameterSets

```
Export-PdfDump [-Path] <string> -Destination <string> [-Force] [-NoClobber]
 [-OwnerPassword <securestring>] [-UserPassword <securestring>] [-WhatIf] [-Confirm]
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

Exports PDF metadata dump information using PDFtk.
It uses `pdftk.exe` to write metadata dump output in UTF-8 format to the destination.
Collects standard error to a temporary log file and removes it when empty.

## EXAMPLES

### EXAMPLE 1

```powershell
Export-PdfDump -Path 'C:\docs\manual.pdf' -Destination 'C:\dir\dump.txt'
```

Exports metadata from manual.pdf to a text dump.

### EXAMPLE 2

```powershell
$ownerPw = ConvertTo-SecureString -String 'ownerpass' -AsPlainText -Force
$userPw = ConvertTo-SecureString -String 'userpass' -AsPlainText -Force
Export-PdfDump -Path 'C:\docs\manual.pdf' -Destination 'C:\dir\dump.txt' -OwnerPassword $ownerPw -UserPassword $userPw
```

Exports metadata from a password-protected PDF file to a text dump.

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

Specifies the path of the file to write the metadata dump output to.

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

Specifies the path of the PDF file to export metadata from.

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

{{ Fill in the related links here }}
