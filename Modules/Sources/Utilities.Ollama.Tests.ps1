[CmdletBinding()]
param ()

Import-Module -Name ($PSScriptRoot | Join-Path -ChildPath '..\Automation.Desktop.psm1') -Force
Set-StrictMode -Version Latest

InModuleScope 'Utilities.Ollama' {
  Describe 'Get-OllamaModel' {
    BeforeAll {
      Mock -CommandName ollama -MockWith {
        param([string]$Command)
        if ($Command -eq 'list') {
          return @'
NAME      ID       SIZE  MODIFIED
llama2    78e8c1b9 4.7GB 2 weeks ago
codellama a8f8b622 3.8GB 3 days ago
mistral   2c1a2b3d 4.1GB 1 week ago
'@
        }
        return [string]::Empty
      }
    }
    Context 'ParameterSetName' {
      It 'returns models' {
        $result = Get-OllamaModel
        $result | Should -Not -BeNullOrEmpty
      }
      It 'returns objects with Id and Name' {
        $result = Get-OllamaModel
        $result[0].PSObject.Properties.Name | Should -Be @('Id', 'Name')
        $result[0].Name | Should -Be 'llama2'
        $result[0].Id | Should -Be '78e8c1b9'
      }
    }
  }
  Describe 'Remove-OllamaModel' {
    BeforeAll {
      Mock -CommandName ollama -MockWith {
        param(
          [string]
          $Command
        )
        if ($Command -eq 'rm') { return '' }
        if ($Command -eq 'list') {
          return @'
NAME                 ID           SIZE      MODIFIED
llama2    78e8c1b9 4.7GB 2 weeks ago
codellama a8f8b622 3.8GB 3 days ago
'@
        }
        return [string]::Empty
      }
      Mock -CommandName Get-OllamaModel -MockWith {
        return @(
          [PSCustomObject]@{ Id = '78e8c1b9'; Name = 'llama2' }
          [PSCustomObject]@{ Id = 'a8f8b622'; Name = 'codellama' }
        )
      }
    }
    Context 'ParameterSetName' {
      It 'handles Name parameter' {
        Remove-OllamaModel -Name 'llama2'

        Should-Invoke -CommandName ollama -Times 1
      }
    }
    Context 'SupportShouldProcess' {
      It 'does not call ollama when WhatIf is specified' {
        Remove-OllamaModel -Name 'llama2' -WhatIf

        Should-Invoke -CommandName ollama -Times 0 -Exactly
      }
      It 'calls ollama when Confirm is specified' {
        Remove-OllamaModel -Name 'llama2' -Confirm:$false

        Should-Invoke -CommandName ollama -Times 1 -Exactly
      }
    }
    Context 'Edge Cases' {
      It 'throws when ollama rm fails' {
        Mock -CommandName ollama -MockWith {
          param(
            [string]
            $Command
          )
          if ($Command -eq 'rm') { throw 'Failed to remove' }
          return [string]::Empty
        }
        { Remove-OllamaModel -Name 'llama2' -Confirm:$false } | Should-Throw
      }
    }
  }
  Describe 'Update-OllamaModel' {
    BeforeAll {
      Mock -CommandName ollama -MockWith {
        param(
          [string]
          $Command
        )
        if ($Command -eq 'pull') { return '' }
        if ($Command -eq 'list') {
          return @'
NAME      ID       SIZE  MODIFIED
llama2    78e8c1b9 4.7GB 2 weeks ago
codellama a8f8b622 3.8GB 3 days ago
'@
        }
        return [string]::Empty
      }
      Mock -CommandName Get-OllamaModel -MockWith {
        return @(
          [PSCustomObject]@{ Id = '78e8c1b9'; Name = 'llama2' }
          [PSCustomObject]@{ Id = 'a8f8b622'; Name = 'codellama' }
        )
      }
    }
    Context 'ParameterSetName' {
      It 'handles Name parameter' {
        Update-OllamaModel -Name 'llama2'
        Should-Invoke -CommandName ollama -Times 1
      }
      It 'handles All parameter' {
        Update-OllamaModel -All
        Should-Invoke -CommandName ollama -Times 2
      }
    }
    Context 'SupportShouldProcess' {
      It 'does not call ollama when WhatIf is specified' {
        Update-OllamaModel -Name 'llama2' -WhatIf

        Should-Invoke -CommandName ollama -Times 0 -Exactly
      }
      It 'calls ollama when Confirm is specified' {
        Update-OllamaModel -Name 'llama2' -Confirm:$false

        Should-Invoke -CommandName ollama -Times 1 -Exactly
      }
      It 'does not call ollama for any model when WhatIf is specified with All' {
        Update-OllamaModel -All -WhatIf

        Should-Invoke -CommandName ollama -Times 0 -Exactly
      }
      It 'calls ollama for all models when Confirm is specified with All' {
        Update-OllamaModel -All -Confirm:$false

        Should-Invoke -CommandName ollama -Times 2 -Exactly
      }
    }
    Context 'Edge Cases' {
      It 'throws when ollama pull fails' {
        Mock -CommandName ollama -MockWith {
          param(
            [string]
            $Command
          )
          if ($Command -eq 'pull') { throw 'Failed to pull' }
          return [string]::Empty
        }
        { Update-OllamaModel -Name 'llama2' -Confirm:$false } | Should-Throw
      }
    }
  }
  Describe 'Invoke-OllamaModel' {
    BeforeAll {
      Mock -CommandName ollama -MockWith {
        param(
          [string]
          $Command
        )
        if ($Command -eq 'run') { return 'Hello' }
        if ($Command -eq 'list') {
          return @'
NAME      ID       SIZE  MODIFIED
llama2    78e8c1b9 4.7GB 2 weeks ago
codellama a8f8b622 3.8GB 3 days ago
'@
        }
        return [string]::Empty
      }
      Mock -CommandName Get-OllamaModel -MockWith {
        return @(
          [PSCustomObject]@{ Id = '78e8c1b9'; Name = 'llama2' }
          [PSCustomObject]@{ Id = 'a8f8b622'; Name = 'codellama' }
        )
      }
    }
    Context 'ParameterSetName' {
      It 'handles Name with Prompt' {
        $result = Invoke-OllamaModel -Name 'llama2' -Prompt 'Hello'

        Should-Invoke -CommandName ollama -Times 1
        $result | Should-BeString 'Hello'
      }
    }
    Context 'SupportShouldProcess' {
      It 'does not call ollama when WhatIf is specified' {
        Invoke-OllamaModel -Name 'llama2' -Prompt 'Hello' -WhatIf

        Should-Invoke -CommandName ollama -Times 0 -Exactly
      }
      It 'calls ollama when Confirm is specified' {
        Invoke-OllamaModel -Name 'llama2' -Prompt 'Hello' -Confirm:$false

        Should-Invoke -CommandName ollama -Times 1 -Exactly
      }
    }
    Context 'Edge Cases' {
      It 'throws when ollama run fails' {
        Mock -CommandName ollama -MockWith {
          param(
            [string]
            $Command
          )
          if ($Command -eq 'run') { throw 'Failed to run' }
          return [string]::Empty
        }
        { Invoke-OllamaModel -Name 'llama2' -Prompt 'Hello' -Confirm:$false } | Should-Throw
      }
    }
  }
  Describe 'Stop-OllamaModel' {
    BeforeAll {
      Mock -CommandName ollama -MockWith {
        param(
          [string]
          $Command
        )
        if ($Command -eq 'stop') { return [string]::Empty }
        if ($Command -eq 'ps') {
          return @'
NAME            ID       SIZE      MEMORY
llama2          78e8c1b9 4.7GB     2.1GB
codellama       a8f8b622 3.8GB     1.5GB
'@
        }
        if ($Command -eq 'list') {
          return @'
NAME      ID       SIZE  MODIFIED
llama2    78e8c1b9 4.7GB 2 weeks ago
codellama a8f8b622 3.8GB 3 days ago
'@
        }
        return [string]::Empty
      }
      Mock -CommandName Get-OllamaModel -MockWith {
        return @(
          [PSCustomObject]@{ Id = '78e8c1b9'; Name = 'llama2' }
          [PSCustomObject]@{ Id = 'a8f8b622'; Name = 'codellama' }
        )
      }
    }
    Context 'ParameterSetName' {
      It 'handles Name parameter' {
        Stop-OllamaModel -Name 'llama2'

        Should-Invoke -CommandName ollama -Times 1
      }
      It 'handles All parameter' {
        Stop-OllamaModel -All

        Should-Invoke -CommandName ollama -Times 2
      }
    }
    Context 'SupportShouldProcess' {
      It 'does not call ollama when WhatIf is specified' {
        Stop-OllamaModel -Name 'llama2' -WhatIf

        Should-Invoke -CommandName ollama -Times 0 -Exactly
      }
      It 'calls ollama when Confirm is specified' {
        Stop-OllamaModel -Name 'llama2' -Confirm:$false

        Should-Invoke -CommandName ollama -Times 1 -Exactly
      }
      It 'does not call ollama for any model when WhatIf is specified with All' {
        Stop-OllamaModel -All -WhatIf

        Should-Invoke -CommandName ollama -Times 1 -Exactly
      }
      It 'calls ollama for all models when Confirm is specified with All' {
        Stop-OllamaModel -All -Confirm:$false

        Should-Invoke -CommandName ollama -Times 3 -Exactly
      }
    }
    Context 'Edge Cases' {
      It 'throws when ollama stop fails' {
        Mock -CommandName ollama -MockWith {
          param(
            [string]
            $Command
          )
          if ($Command -eq 'stop') { throw 'Failed to stop' }
          return [string]::Empty
        }
        { Stop-OllamaModel -Name 'llama2' -Confirm:$false } | Should-Throw
      }
    }
  }
}
