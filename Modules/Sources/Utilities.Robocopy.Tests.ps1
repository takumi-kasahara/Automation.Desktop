[CmdletBinding()]
param ()

Import-Module -Name ($PSScriptRoot | Join-Path -ChildPath '..\Automation.Desktop.psm1') -Force
Set-StrictMode -Version Latest

InModuleScope 'Utilities.Robocopy' {
  Describe 'Invoke-Robocopy' {
    BeforeAll {
      $script:robocopyArguments = $null
      Mock -CommandName Robocopy.exe -MockWith {
        param(
          [string]
          $Source,
          [string]
          $Destination
        )
        $script:robocopyArguments = $args
        return 0
      }
      Mock -CommandName Test-Path -MockWith { $true }
    }
    Context 'ParameterSetName' {
      It 'handles Source and Destination parameters' {
        Invoke-Robocopy -Source 'C:\Source' -Destination 'C:\Destination'

        Should-Invoke -CommandName Robocopy.exe -Times 1
      }
      It 'handles Source, Destination, and NDL parameters' {
        Invoke-Robocopy -Source 'C:\Source' -Destination 'C:\Destination' -NDL

        $script:robocopyArguments | Should -Contain '/NDL'
      }
      It 'handles Source, Destination, and NFL parameters' {
        Invoke-Robocopy -Source 'C:\Source' -Destination 'C:\Destination' -NFL

        $script:robocopyArguments | Should -Contain '/NFL'
      }
      It 'handles Source, Destination, NDL, and NFL parameters' {
        Invoke-Robocopy -Source 'C:\Source' -Destination 'C:\Destination' -NDL -NFL

        $script:robocopyArguments | Should -Contain '/NDL'
        $script:robocopyArguments | Should -Contain '/NFL'
      }
      It 'fails when NoClobber is specified and destination exists' {
        Mock -CommandName Test-Path -MockWith { $true }

        { Invoke-Robocopy -Source 'C:\Source' -Destination 'C:\Destination' -NoClobber } | Should -Throw
      }
    }
    Context 'Output' {
      It 'returns PSCustomObject with Source, Destination, and Log properties' {
        $result = Invoke-Robocopy -Source 'C:\Source' -Destination 'C:\Destination'

        $result | Should-HaveType ([Object[]])
        $result.Source | Should-BeString 'C:\Source'
        $result.Destination | Should-BeString 'C:\Destination'
        $result.Log | Should-NotBeNull
      }
    }
    Context 'ShouldProcess' {
      It 'respects -WhatIf parameter' {
        Invoke-Robocopy -Source 'C:\Source' -Destination 'C:\Destination' -WhatIf

        Should-Invoke -CommandName Robocopy.exe -Times 1
      }
      It 'does not execute when -Confirm is declined' {
        Invoke-Robocopy -Source 'C:\Source' -Destination 'C:\Destination' -Confirm:$false

        Should-Invoke -CommandName Robocopy.exe -Times 1
      }
    }
  }
}
