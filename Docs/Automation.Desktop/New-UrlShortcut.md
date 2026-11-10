---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: New-UrlShortcut
---

# New-UrlShortcut

## SYNOPSIS

Creates an Internet shortcut file (.url).

## SYNTAX

### __AllParameterSets

```
New-UrlShortcut [-Path] <string> [-TargetPath] <string> [-Force] [-WhatIf] [-Confirm]
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

Creates a Windows Internet Shortcut file that points to a well-formed absolute URI.
If the destination path does not end with `.url`, the cmdlet appends the extension automatically.

## EXAMPLES

### EXAMPLE 1

```powershell
New-UrlShortcut -Path 'C:\Users\Public\Desktop\Example.url' -TargetPath 'https://example.com'
```

Creates a public desktop shortcut to the specified website.

### EXAMPLE 2

```powershell
New-UrlShortcut -Path 'C:\Users\Public\Desktop\Example' -TargetPath 'https://example.com' -Force
```

Creates a desktop shortcut to the specified website, overwriting any existing shortcut.

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

### -Force

Overwrites an existing shortcut if one already exists.

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

Specifies the shortcut file path to create.
If the path has no extension,
`.url` is appended automatically.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases:
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

### -TargetPath

Specifies the destination URI for the shortcut.
Must be an absolute URL.

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

### System.IO.FileInfo

The created .url shortcut file.

{{ Fill in the Description }}

### System.IO.FileInfo

{{ Fill in the Description }}

## NOTES

Returns the created shortcut file object.

## RELATED LINKS

{{ Fill in the related links here }}
