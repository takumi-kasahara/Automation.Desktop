using namespace System.Collections.ObjectModel
using namespace System.Management.Automation

function Get-OllamaModel {
  <#
  .SYNOPSIS
    Gets the list of Ollama models.

  .DESCRIPTION
    The Get-OllamaModel cmdlet runs `ollama list` and returns the model information as an array of PSObjects.
    Each object has Id and Name properties.

  .EXAMPLE
    ```powershell
    Get-OllamaModel
    ```
    Returns a list of installed Ollama models.

  .OUTPUTS
    PSCustomObject[]
      Objects with Id and Name properties representing Ollama models.
  #>
  [CmdletBinding()]
  [OutputType([PSCustomObject])]
  param()
  try {
    $global:LASTEXITCODE = 0
    $output = ollama list 2>&1
    if ($LASTEXITCODE -ne 0 -and $output -notmatch 'NAME\s+ID') { throw $output }
    $lines = $output -split "`n"
    if ($lines.Count -lt 2) { return @() }
    $models = @()
    for ($i = 1; $i -lt $lines.Count; $i++) {
      $line = $lines[$i].Trim()
      if (-not $line) { continue }

      $parts = $line -split '\s+'
      if ($parts.Count -ge 2) {
        $models += [PSCustomObject]@{
          Id   = $parts[1]
          Name = $parts[0]
        }
      }
    }
    return $models
  } catch {
    throw "Failed to get Ollama models: $_"
  }
}
function Remove-OllamaModel {
  <#
  .SYNOPSIS
    Removes an Ollama model.

  .DESCRIPTION
    The Remove-OllamaModel cmdlet removes a specified Ollama model by running `ollama rm`.
    Supports -WhatIf and -Confirm for safe operation.

  .PARAMETER Name
    The name of the model to remove. This parameter supports tab completion from the list of models.

  .PARAMETER WhatIf
    Shows what would happen if the cmdlet runs. The cmdlet is not run.

  .PARAMETER Confirm
    Prompts you for confirmation before running the cmdlet.

  .EXAMPLE
    ```powershell
    Remove-OllamaModel -Name "llama2"
    ```

    Removes the llama2 model.
  #>
  [CmdletBinding(SupportsShouldProcess)]
  param()
  dynamicparam {
    try {
      $models = ([string[]]@(Get-OllamaModel | Select-Object -ExpandProperty Name))
    } catch {
      $models = @()
    }
    $attributeCollection = [Collection[Attribute]]::new()
    $parameter = [ParameterAttribute]::new()
    $parameter.Mandatory = $true
    $attributeCollection.Add($parameter)
    if ($models.Count -gt 0) {
      $validateSetAttribute = [ValidateSetAttribute]::new($models)
      $attributeCollection.Add($validateSetAttribute)
    }
    $dynamic = [RuntimeDefinedParameter]::new('Name', [string], $attributeCollection)
    $dict = [RuntimeDefinedParameterDictionary]::new()
    $dict.Add('Name', $dynamic)
    return $dict
  }
  process {
    $Name = $PSBoundParameters['Name']

    try {
      if (-not $PSCmdlet.ShouldProcess($Name, 'Remove model')) { return }
      $global:LASTEXITCODE = 0
      $output = ollama rm $Name 2>&1
      if ($LASTEXITCODE -ne 0 -and $output -notmatch 'Removed') { throw $output }
      "Removed model '$Name'." | Out-Host
    } catch {
      $msg = if ($_.Exception -and $_.Exception.Message) { $_.Exception.Message } elseif ($_.ToString()) { $_.ToString() } else { [string]::Empty }
      $msgText = if ($msg) { $msg } else { $_ }
      if ($msgText -match 'What if' -or $msgText -match 'Performing the operation') { return }
      throw "Failed to remove model '$Name': $msgText"
    }
  }
}

function Update-OllamaModel {
  <#
  .SYNOPSIS
    Updates an Ollama model.

  .DESCRIPTION
    The Update-OllamaModel cmdlet updates a specified Ollama model by running `ollama pull`.
    Use the -All switch to update all models.

  .PARAMETER Name
    The name of the model to update. This parameter supports tab completion from the list of models.
    Ignored when -All is specified.

  .PARAMETER All
    Indicates that all models should be updated.

  .EXAMPLE
    ```powershell
    Update-OllamaModel -Name "llama2"
    ```

    Updates the llama2 model.

  .EXAMPLE
    ```powershell
    Update-OllamaModel -All
    ```

    Updates all installed models.

  .OUTPUTS
    None.
  #>
  [CmdletBinding(SupportsShouldProcess)]
  param(
    [Parameter(ParameterSetName = 'All')]
    [switch]
    $All
  )
  dynamicparam {
    try {
      $models = ([string[]]@(Get-OllamaModel | Select-Object -ExpandProperty Name))
    } catch {
      $models = @()
    }
    $attributeCollection = [Collection[Attribute]]::new()
    $parameter = [ParameterAttribute]::new()
    if (-not $All) {
      $parameter.Mandatory = $true
    }
    $attributeCollection.Add($parameter)
    if ($models.Count -gt 0) {
      $validateSetAttribute = [ValidateSetAttribute]::new($models)
      $attributeCollection.Add($validateSetAttribute)
    }
    $dynamic = [RuntimeDefinedParameter]::new('Name', [string], $attributeCollection)
    $dict = [RuntimeDefinedParameterDictionary]::new()
    $dict.Add('Name', $dynamic)
    return $dict
  }
  process {
    $Name = $PSBoundParameters['Name']

    try {
      if ($All) {
        $models = Get-OllamaModel
        foreach ($model in $models) {
          if (-not $PSCmdlet.ShouldProcess($model.Name, 'Update model')) {
            continue
          }
          $global:LASTEXITCODE = 0
          $output = ollama pull $model.Name 2>&1
          if ($LASTEXITCODE -ne 0 -and $output -notmatch 'success') { throw $output }
          "Updated model '$($model.Name)'." | Out-Host
        }
      } else {
        if (-not $PSCmdlet.ShouldProcess($Name, 'Update model')) { return }
        $global:LASTEXITCODE = 0
        $output = ollama pull $Name 2>&1
        if ($LASTEXITCODE -ne 0 -and $output -notmatch 'success') { throw $output }
        "Updated model '$Name'." | Out-Host
      }
    } catch {
      $msg = if ($_.Exception -and $_.Exception.Message) { $_.Exception.Message } elseif ($_.ToString()) { $_.ToString() } else { [string]::Empty }
      $msgText = if ($msg) { $msg } else { $_ }
      if ($msgText -match 'What if' -or $msgText -match 'Performing the operation') { return }
      throw "Failed to update models: $msgText"
    }
  }
}

function Invoke-OllamaModel {
  <#
  .SYNOPSIS
    Invokes an Ollama model to generate text.

  .DESCRIPTION
    The Invoke-OllamaModel cmdlet runs a specified Ollama model and returns the generated text.
    It runs `ollama run` with the model name and optional prompt.

  .PARAMETER Name
    The name of the model to invoke. This parameter supports tab completion from the list of models.

  .PARAMETER Prompt
    The prompt to send to the model. If not specified, the model will wait for interactive input (use with caution).

  .EXAMPLE
    ```powershell
    Invoke-OllamaModel -Name "llama2" -Prompt "What is the capital of Japan?"
    ```
    Returns the generated text from the llama2 model.

  .OUTPUTS
    System.String
      The generated text from the invoked Ollama model.
  #>
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([string])]
  param(
    [string]
    $Prompt
  )
  dynamicparam {
    try {
      $models = ([string[]]@(Get-OllamaModel | Select-Object -ExpandProperty Name))
    } catch {
      $models = @()
    }
    $attributeCollection = [Collection[Attribute]]::new()
    $parameter = [ParameterAttribute]::new()
    $parameter.Mandatory = $true
    $attributeCollection.Add($parameter)
    if ($models.Count -gt 0) {
      $validateSetAttribute = [ValidateSetAttribute]::new($models)
      $attributeCollection.Add($validateSetAttribute)
    }
    $dynamic = [RuntimeDefinedParameter]::new('Name', [string], $attributeCollection)
    $dict = [RuntimeDefinedParameterDictionary]::new()
    $dict.Add('Name', $dynamic)
    return $dict
  }
  process {
    $Name = $PSBoundParameters['Name']
    $Prompt = $PSBoundParameters['Prompt']

    try {
      if (-not $PSCmdlet.ShouldProcess($Name, 'Invoke model')) { return }

      $global:LASTEXITCODE = 0
      $arguments = @($Name)
      if ($PSBoundParameters.ContainsKey('Prompt') -and $Prompt) {
        $arguments += $Prompt
      }
      $output = ollama run @arguments 2>&1
      if ($LASTEXITCODE -ne 0) { throw $output }
      return $output
    } catch {
      $msg = if ($_.Exception -and $_.Exception.Message) { $_.Exception.Message } elseif ($_.ToString()) { $_.ToString() } else { [string]::Empty }
      $msgText = if ($msg) { $msg } else { $_ }
      if ($msgText -match 'What if' -or $msgText -match 'Performing the operation') { return }
      throw "Failed to invoke model '$Name': $msgText"
    }
  }
}
function Stop-OllamaModel {
  <#
  .SYNOPSIS
    Stops a running Ollama model.

  .DESCRIPTION
    The Stop-OllamaModel cmdlet stops a specified Ollama model that is currently loaded in memory.
    Use the -All switch to stop all running models.

  .PARAMETER Name
    The name of the model to stop. This parameter supports tab completion from the list of models.

  .PARAMETER All
    Indicates that all running models should be stopped.

  .EXAMPLE
    ```powershell
    Stop-OllamaModel -Name "llama2"
    ```
    Stops the llama2 model if it is running.

  .EXAMPLE
    ```powershell
    Stop-OllamaModel -All
    ```
    Stops all running models.

  .OUTPUTS
    None.
  #>
  [CmdletBinding(SupportsShouldProcess)]
  param(
    [Parameter(ParameterSetName = 'All')]
    [switch]
    $All
  )
  dynamicparam {
    try {
      $models = ([string[]]@(Get-OllamaModel | Select-Object -ExpandProperty Name))
    } catch {
      $models = @()
    }
    $attributeCollection = [Collection[Attribute]]::new()
    $parameter = [ParameterAttribute]::new()
    if (-not $All) {
      $parameter.Mandatory = $true
    }
    $attributeCollection.Add($parameter)
    if ($models.Count -gt 0) {
      $validateSetAttribute = [ValidateSetAttribute]::new($models)
      $attributeCollection.Add($validateSetAttribute)
    }
    $dynamic = [RuntimeDefinedParameter]::new('Name', [string], $attributeCollection)
    $dict = [RuntimeDefinedParameterDictionary]::new()
    $dict.Add('Name', $dynamic)
    return $dict
  }
  process {
    $Name = $PSBoundParameters['Name']

    try {
      if ($All) {
        $global:LASTEXITCODE = 0
        $output = ollama ps 2>&1
        if ($LASTEXITCODE -ne 0) {
          Write-Warning 'Could not list running models. Attempting to stop all known models.'
          $models = Get-OllamaModel
        } else {
          $lines = $output -split "`n"
          $models = @()
          if ($lines.Count -ge 2) {
            for ($i = 1; $i -lt $lines.Count; $i++) {
              $line = $lines[$i].Trim()
              if (-not $line) { continue }
              $parts = $line -split '\s+'
              if ($parts.Count -ge 1) {
                $models += [PSCustomObject]@{ Name = $parts[0] }
              }
            }
          }
        }
        foreach ($model in $models) {
          if (-not $PSCmdlet.ShouldProcess($model.Name, 'Stop model')) { continue }
          $global:LASTEXITCODE = 0
          $output = ollama stop $model.Name 2>&1
          if ($LASTEXITCODE -ne 0 -and $output -notmatch 'stopped') { throw $output }
          "Stopped model '$($model.Name)'." | Out-Host
        }
      } else {
        if (-not $PSCmdlet.ShouldProcess($Name, 'Stop model')) { return }
        $global:LASTEXITCODE = 0
        $output = ollama stop $Name 2>&1
        if ($LASTEXITCODE -ne 0 -and $output -notmatch 'stopped') { throw $output }
        "Stopped model '$Name'." | Out-Host
      }
    } catch {
      $msg = if ($_.Exception -and $_.Exception.Message) { $_.Exception.Message } elseif ($_.ToString()) { $_.ToString() } else { [string]::Empty }
      $msgText = if ($msg) { $msg } else { $_ }
      if ($msgText -match 'What if' -or $msgText -match 'Performing the operation') { return }
      throw "Failed to stop models: $msgText"
    }
  }
}
