---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: Unblock-Pdf
---

# Unblock-Pdf

## SYNOPSIS

Removes encryption from PDF files using QPDF.

## SYNTAX

### PathSet

```
Unblock-Pdf [-Path] <string[]> [-OwnerPassword <securestring>] [-UserPassword <securestring>]
 [-WhatIf] [-Confirm]
```

### LiteralPathSet

```
Unblock-Pdf -LiteralPath <string[]> [-OwnerPassword <securestring>] [-UserPassword <securestring>]
 [-WhatIf] [-Confirm]
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

Unblock-Pdf reads PDF files specified by Path or LiteralPath and uses
`qpdf.exe --show-encryption` to determine whether each file is encrypted.
If a file is encrypted, the function runs `qpdf.exe --decrypt --replace-input`
to remove encryption in place.
The command supports `-WhatIf` through
`SupportsShouldProcess` so the decryption step can be previewed without
modifying files.

## EXAMPLES

### EXAMPLE 1

```powershell
Unblock-Pdf -Path 'C:\docs\*.pdf'
```

Removes encryption from every PDF that matches the path.

### EXAMPLE 2

```powershell
Unblock-Pdf -LiteralPath 'C:\docs\manual.pdf' -WhatIf
```

Shows the decryption operation for manual.pdf without modifying it.

### EXAMPLE 3

```powershell
$ownerPw = ConvertTo-SecureString -String 'ownerpass' -AsPlainText -Force
Unblock-Pdf -LiteralPath 'C:\docs\encrypted.pdf' -OwnerPassword $ownerPw
```

Removes encryption from a password-protected PDF file.

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

### -LiteralPath

Specifies literal PDF file paths to inspect and unblock.

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

Specifies wildcard-compatible PDF file paths to inspect and unblock.

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

This function requires `qpdf.exe` to be available in the system PATH.
Standard error output from QPDF is written to a temporary log file that is removed when it remains empty.

## RELATED LINKS

{{ Fill in the related links here }}
