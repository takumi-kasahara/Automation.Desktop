---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: Update-OllamaModel
---

# Update-OllamaModel

## SYNOPSIS

Updates an Ollama model.

## SYNTAX

### All

```
Update-OllamaModel [-All] [-WhatIf] [-Confirm]
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

The Update-OllamaModel cmdlet updates a specified Ollama model by running `ollama pull`.
Use the -All switch to update all models.

## EXAMPLES

### EXAMPLE 1

```powershell
Update-OllamaModel -Name "llama2"
```

Updates the llama2 model.

### EXAMPLE 2

```powershell
Update-OllamaModel -All
```

Updates all installed models.

## PARAMETERS

### -All

Indicates that all models should be updated.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
  - Name: All
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

### -Name

{{ Fill Name Description }}

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

## OUTPUTS

## NOTES

## RELATED LINKS

{{ Fill in the related links here }}
