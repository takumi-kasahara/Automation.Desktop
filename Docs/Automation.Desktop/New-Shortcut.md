---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: https://learn.microsoft.com/en-us/troubleshoot/windows-client/admin-development/create-desktop-shortcut-with-wsh
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: New-Shortcut
---

# New-Shortcut

## SYNOPSIS

Creates a Windows shortcut file (`.lnk`).

## SYNTAX

### __AllParameterSets

```
New-Shortcut [-Path] <string> [-TargetPath] <string> [-WorkingDirectory <string>]
 [-Arguments <string>] [-Description <string>] [-IconLocation <string>] [-HotKey <string>]
 [-WindowStyle <string>] [-Force] [-WhatIf] [-Confirm]
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

Creates a Windows Shell shortcut at the specified destination.
If the destination path does not end with `.lnk`, the cmdlet appends the extension automatically.

## EXAMPLES

### EXAMPLE 1

```powershell
New-Shortcut -Path 'C:\Users\Public\Desktop\Example.lnk' -TargetPath 'C:\Windows\System32\notepad.exe'
```

Creates a public desktop shortcut to Notepad.

### EXAMPLE 2

```powershell
New-Shortcut -Path 'C:\Users\Public\Desktop\Example' -TargetPath 'C:\Windows\System32\notepad.exe' -WorkingDirectory 'C:\dir' -Arguments '/A /B' -Description 'Example shortcut' -IconLocation 'C:\Windows\System32\shell32.dll,1' -HotKey 'F5' -WindowStyle Maximum -Force
```

Creates a desktop shortcut with custom properties including working directory, arguments, description, icon, and hotkey.

## PARAMETERS

### -Arguments

Specifies command-line arguments for the shortcut target.

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

### -Description

Specifies the shortcut description.

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

Overwrites an existing shortcut file if it already exists.

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

### -HotKey

Specifies the shortcut hotkey.
Accepts F1–F12 or single alphanumeric keys.

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

### -IconLocation

Specifies the icon location for the shortcut.
Defaults to `,0`.

```yaml
Type: System.String
DefaultValue: ',0'
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
If the path has no extension, `.lnk` is appended automatically.

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

Specifies the target file or URL for the shortcut.
If the path exists, it is resolved to the canonical path.

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

### -WindowStyle

Specifies the window style for the shortcut: Normal, Maximum, or Minimum.

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

### -WorkingDirectory

Specifies the working directory for the shortcut.

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

The created shortcut file.

{{ Fill in the Description }}

### System.IO.FileInfo

{{ Fill in the Description }}

## NOTES

Returns the created shortcut file object.

## RELATED LINKS

- [](https://learn.microsoft.com/en-us/troubleshoot/windows-client/admin-development/create-desktop-shortcut-with-wsh)
