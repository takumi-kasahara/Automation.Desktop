---
document type: cmdlet
external help file: Automation.Desktop-Help.xml
HelpUri: ''
Locale: ja-JP
Module Name: Automation.Desktop
ms.date: 11/09/2026
PlatyPS schema version: 2024-05-01
title: Get-OllamaModel
---

# Get-OllamaModel

## SYNOPSIS

Gets the list of Ollama models.

## SYNTAX

### __AllParameterSets

```
Get-OllamaModel
```

## ALIASES

This cmdlet has the following aliases,
{{Insert list of aliases}}

## DESCRIPTION

This cmdlet runs `ollama list` and returns the model information as an array.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-OllamaModel
```

Returns a list of installed Ollama models.

## PARAMETERS

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject[]

Objects with Id and Name properties representing Ollama models.

{{ Fill in the Description }}

### System.Management.Automation.PSObject[]

{{ Fill in the Description }}

## NOTES

## RELATED LINKS

{{ Fill in the related links here }}
