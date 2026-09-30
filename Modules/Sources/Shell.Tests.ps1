using namespace System.Collections.Generic

[CmdletBinding()]
param ()

Import-Module -Name ($PSScriptRoot | Join-Path -ChildPath '..\Automation.Desktop.psm1') -Force
Set-StrictMode -Version Latest

InModuleScope 'Shell' {
  Describe 'Get-ItemDetail' {
    BeforeAll {
      Mock -CommandName Get-Item -MockWith { [PSCustomObject]@{ FullName = 'C:\dir\file.txt' } }
      Mock -CommandName Resolve-Path -MockWith { [PSCustomObject]@{ Path = $LiteralPath } }
      Mock -CommandName Test-Path -MockWith { $true }
      Mock -CommandName New-Object -ParameterFilter { $ComObject -eq 'Shell.Application' } -MockWith {
        $item = [PSCustomObject]@{
          Name     = 'file.txt'
          FullName = 'C:\dir\file.txt'
        }
        $folder = [PSCustomObject]@{ Item = $item }
        $folder | Add-Member -MemberType ScriptMethod -Name ParseName -Value { $this.Item }
        $folder | Add-Member -MemberType ScriptMethod -Name GetDetailsOf -Value {
          param(
            [string]
            $Target,
            [int]
            $Index
          )
          if ([string]::IsNullOrEmpty($Target)) {
            switch ($Index) {
              0 {
                return 'Name'
              }
              1 {
                return 'Type'
              }
              2 {
                return 'Size'
              }
              default {
                return [string]::Empty
              }
            }
          } else {
            switch ($Index) {
              0 {
                return $this.Item.Name
              }
              1 {
                return 'Text Document'
              }
              2 {
                return '1 KB'
              }
              default {
                return [string]::Empty
              }
            }
          }
        }
        $shell = [PSCustomObject]@{ Folder = $folder }
        $shell | Add-Member -MemberType ScriptMethod -Name Namespace -Value { $this.Folder }
        return $shell
      }
    }
    Context 'ParameterSetName' {
      It 'returns item details by Path' {
        Get-ItemDetail -Path 'C:\dir\file.txt' -Min 0 -Max 2 | Should-BeCollection -Count 3
      }
      It 'returns item details by Path with ValueFromPipeline' {
        'C:\dir\file.txt' | Get-ItemDetail -Min 0 -Max 2 | Should-BeCollection -Count 3
      }
      It 'returns item details by Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = 'C:\dir\file.txt' } | Get-ItemDetail -Min 0 -Max 2 | Should-BeCollection -Count 3
      }
      It 'returns item details by LiteralPath' {
        Get-ItemDetail -LiteralPath 'C:\dir\file.txt' -Min 0 -Max 2 | Should-BeCollection -Count 3
      }
      It 'returns item details by LiteralPath with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ PSPath = 'C:\dir\file.txt' } | Get-ItemDetail -Min 0 -Max 2 | Should-BeCollection -Count 3
      }
    }
    Context 'Output' {
      It 'returns item details with Name and Value properties' {
        $result = Get-ItemDetail -Path 'C:\dir\file.txt' -Min 0 -Max 2

        $result | Should-BeCollection -Count 3
        $result[0].Name | Should-BeString 'Name'
        $result[0].Value | Should-BeString 'file.txt'
        $result[1].Name | Should-BeString 'Type'
        $result[1].Value | Should-BeString 'Text Document'
        $result[2].Name | Should-BeString 'Size'
        $result[2].Value | Should-BeString '1 KB'
      }
      It 'returns item details with Name and Value properties by LiteralPath' {
        $result = Get-ItemDetail -LiteralPath 'C:\dir\file.txt' -Min 0 -Max 2

        $result | Should-BeCollection -Count 3
        $result[0].Name | Should-BeString 'Name'
        $result[0].Value | Should-BeString 'file.txt'
      }
    }
    Context 'Other parameters' {
      It 'calls Get-Item with Path when using Path parameter set' {
        Get-ItemDetail -Path 'C:\dir\file.txt' -Min 0 -Max 0 | Out-Null

        Should-Invoke -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\file.txt' -and $Force -eq $true } -Times 1 -Exactly
      }
      It 'calls Get-Item with LiteralPath when using LiteralPath parameter set' {
        Get-ItemDetail -LiteralPath 'C:\dir\file.txt' -Min 0 -Max 0 | Out-Null

        Should-Invoke -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\dir\file.txt' -and $Force -eq $true } -Times 1 -Exactly
      }
    }
    Context 'Edge cases' {
      It 'throws when Min is less than 0' {
        { Get-ItemDetail -Path 'C:\dir\file.txt' -Min -1 } | Should-Throw
      }
      It 'throws when Max is less than 0' {
        { Get-ItemDetail -Path 'C:\dir\file.txt' -Max -1 } | Should-Throw
      }
      It 'throws when Min is greater than Max' {
        { Get-ItemDetail -Path 'C:\dir\file.txt' -Min 2 -Max 1 } | Should-Throw
      }
    }
  }
  Describe 'Find-Application' {
    Context 'Other parameters' {
      It 'returns applications found in PATH without searching other locations' {
        Mock -CommandName where.exe -MockWith {
          if ($args[0] -eq 'notepad.exe') {
            'C:\Windows\notepad.exe'
          }
        }
        Mock -CommandName Get-Application

        $result = @(Find-Application -Name 'notepad.exe')

        $result | Should-BeCollection -Count 1
        $result[0] | Should-BeString 'C:\Windows\notepad.exe'
        Should-Invoke -CommandName Get-Application -Times 0 -Exactly
      }
      It 'returns applications found in Program Files when PATH search fails' {
        Mock -CommandName where.exe -MockWith {
          if ($args[0] -eq '/r' -and $args[1] -eq $env:ProgramFiles) {
            'C:\Program Files\Example\app.exe'
          }
        }
        Mock -CommandName Get-Application
        Mock -CommandName Test-Path -MockWith { $true }

        $result = @(Find-Application -Name 'app.exe')
        $result | Should-BeCollection -Count 1
        $result[0] | Should-BeString 'C:\Program Files\Example\app.exe'

        Should-Invoke -CommandName Get-Application -Times 0 -Exactly
      }
      It 'returns registered applications when all where.exe searches fail' {
        Mock -CommandName where.exe -MockWith { @() }
        Mock -CommandName Test-Path -MockWith { $true }
        Mock -CommandName Get-Application -MockWith {
          [PSCustomObject]@{
            Name = 'notepad.exe'
            Path = 'C:\Program Files\notepad.exe'
          }
        }

        $result = @(Find-Application -Name 'notepad.exe')

        $result | Should-BeCollection -Count 1
        $result[0] | Should-BeString 'C:\Program Files\notepad.exe'
        Should-Invoke -CommandName Get-Application -Times 1 -Exactly
      }
    }
  }
  Describe 'Get-Application' {
    BeforeAll {
      Mock -CommandName Test-Path -MockWith { $true }
      Mock -CommandName Get-ChildItem -MockWith {
        param($Path)
        if ($Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths') {
          $app1 = [PSCustomObject]@{ PSChildName = 'notepad.exe' }
          $app1 | Add-Member -MemberType ScriptMethod -Name GetValue -Value {
            param($name)
            [void]$name
            '"C:\Program Files\notepad.exe"'
          }
          $app2 = [PSCustomObject]@{ PSChildName = 'calc.exe' }
          $app2 | Add-Member -MemberType ScriptMethod -Name GetValue -Value {
            param($name)
            [void]$name
            '"C:\Program Files\calc.exe"'
          }
          return @($app1, $app2)
        }
      }
    }
    Context 'ParameterSetName' {
      It 'returns registered applications from App Paths' {
        Get-Application | Should-BeCollection -Count 2
      }
      It 'returns the requested application by Name' {
        Get-Application -Name 'notepad.exe' | Should-BeCollection -Count 1
      }
    }
    Context 'Output' {
      It 'returns applications with Name and Path properties' {
        $result = Get-Application

        $result | Should-BeCollection -Count 2
        $result.Name | Should-ContainCollection 'notepad.exe'
        $result.Name | Should-ContainCollection 'calc.exe'
        $result.Path | Should-ContainCollection 'C:\Program Files\notepad.exe'
        $result.Path | Should-ContainCollection 'C:\Program Files\calc.exe'
      }
      It 'returns the requested application with Name and Path properties' {
        $result = Get-Application -Name 'notepad.exe'

        $result | Should-BeCollection -Count 1
        $result[0].Name | Should-BeString 'notepad.exe'
        $result[0].Path | Should-BeString 'C:\Program Files\notepad.exe'
      }
    }
  }
  Describe 'Get-SpecialFolder' {
    BeforeAll {
      Mock -CommandName Get-ChildItem -MockWith {
        $startup = [PSCustomObject]@{ PSChildName = 'Startup' }
        $startup | Add-Member -MemberType ScriptMethod -Name GetValue -Value {
          param($name)
          if ($name -eq 'Name') {
            'Startup'
          } else {
            $null
          }
        } -Force
        $common = [PSCustomObject]@{ PSChildName = 'Common Startup' }
        $common | Add-Member -MemberType ScriptMethod -Name GetValue -Value {
          param($name)
          if ($name -eq 'Name') {
            'Common Startup'
          } else {
            $null
          }
        } -Force
        return @($startup, $common)
      }
      Mock -CommandName New-Object -ParameterFilter { $ComObject -eq 'Shell.Application' } -MockWith {
        $folders = @{
          'shell:Startup'        = [PSCustomObject]@{ Self = [PSCustomObject]@{ Path = 'C:\Users\Test\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup' } }
          'shell:Common Startup' = [PSCustomObject]@{ Self = [PSCustomObject]@{ Path = 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup' } }
        }
        $shell = [PSCustomObject]@{ Folders = $folders }
        $shell | Add-Member -MemberType ScriptMethod -Name NameSpace -Value {
          param($path)
          return $this.Folders[$path]
        }
        return $shell
      }
    }
    Context 'ParameterSetName' {
      It 'returns all registered special folders when no Name is supplied' {
        Get-SpecialFolder | Should-BeCollection -Count 2
      }
      It 'returns the requested special folder path by Name' {
        Get-SpecialFolder -Name 'Startup' | Should-BeString 'C:\Users\Test\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup'
      }
    }
    Context 'Output' {
      It 'returns special folders with Name and Path properties' {
        $result = Get-SpecialFolder

        $result | Should-BeCollection -Count 2
        $result.Name | Should-ContainCollection 'Startup'
        $result.Name | Should-ContainCollection 'Common Startup'
        $result.Path | Should-ContainCollection 'C:\Users\Test\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup'
        $result.Path | Should-ContainCollection 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup'
      }
    }
  }
  Describe 'Get-Startup' {
    BeforeAll {
      Mock -CommandName Test-Path -MockWith { $true }
      Mock -CommandName Get-ChildItem -ParameterFilter { $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions' } -MockWith {
        $startup = [PSCustomObject]@{ PSChildName = 'Startup' }
        $startup | Add-Member -MemberType ScriptMethod -Name GetValue -Value {
          param($name)
          if ($name -eq 'Name') {
            'Startup'
          } else {
            $null
          }
        } -Force
        $common = [PSCustomObject]@{ PSChildName = 'Common Startup' }
        $common | Add-Member -MemberType ScriptMethod -Name GetValue -Value {
          param($name)
          if ($name -eq 'Name') {
            'Common Startup'
          } else {
            $null
          }
        } -Force
        return @($startup, $common)
      }
      Mock -CommandName New-Object -ParameterFilter { $ComObject -eq 'Shell.Application' } -MockWith {
        $folders = @{
          'shell:Startup'        = [PSCustomObject]@{ Self = [PSCustomObject]@{ Path = 'C:\Startup' } }
          'shell:Common Startup' = [PSCustomObject]@{ Self = [PSCustomObject]@{ Path = 'C:\Common Startup' } }
        }
        $shell = [PSCustomObject]@{ Folders = $folders }
        $shell | Add-Member -MemberType ScriptMethod -Name NameSpace -Value {
          param($path)
          return $this.Folders[$path]
        }
        return $shell
      }
      Mock -CommandName Get-ChildItem -ParameterFilter { $LiteralPath -eq 'C:\Startup' } -MockWith {
        [PSCustomObject]@{
          FullName   = 'C:\Startup\app.lnk'
          BaseName   = 'app'
          Extension  = '.lnk'
          PSProvider = [PSCustomObject]@{ Name = 'FileSystem' }
        }
      }
      Mock -CommandName Get-ChildItem -ParameterFilter { $LiteralPath -eq 'C:\Common Startup' } -MockWith {
        [PSCustomObject]@{
          FullName   = 'C:\Common Startup\script.ps1'
          BaseName   = 'script'
          Extension  = '.ps1'
          PSProvider = [PSCustomObject]@{ Name = 'FileSystem' }
        }
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' } -MockWith {
        $reg = [PSCustomObject]@{ PSProvider = [PSCustomObject]@{ Name = 'Registry' } }
        $reg | Add-Member -MemberType ScriptMethod -Name GetValueNames -Value { @('One') }
        $reg | Add-Member -MemberType ScriptMethod -Name GetValue -Value {
          param($name)
          if ($name -eq 'One') {
            'C:\App\one.exe'
          }
        }
        return $reg
      }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' } -MockWith {
        $reg = [PSCustomObject]@{ PSProvider = [PSCustomObject]@{ Name = 'Registry' } }
        $reg | Add-Member -MemberType ScriptMethod -Name GetValueNames -Value { @('Two') }
        $reg | Add-Member -MemberType ScriptMethod -Name GetValue -Value {
          param($name)
          if ($name -eq 'Two') {
            'C:\App\two.exe'
          }
        }
        return $reg
      }
      Mock -CommandName Get-Shortcut -ParameterFilter { $LiteralPath -eq 'C:\Startup\app.lnk' } -MockWith {
        [PSCustomObject]@{
          TargetPath = 'C:\Program Files\App\app.exe'
          Arguments  = '-arg'
        }
      }
    }
    Context 'ParameterSetName' {
      It 'returns startup items from startup folders and registry' {
        @(Get-Startup) | Should-BeCollection -Count 4
      }
    }
    Context 'Output' {
      It 'returns startup items with Name and CommandLine properties' {
        $result = @(Get-Startup)

        $result | Should-BeCollection -Count 4
        $result | Where-Object { $_.Name -eq 'app' } | Select-Object -ExpandProperty CommandLine | Should-ContainCollection '"C:\Program Files\App\app.exe" -arg'
        $result | Where-Object { $_.Name -eq 'script' } | Select-Object -ExpandProperty CommandLine | Should-ContainCollection 'C:\Common Startup\script.ps1'
        $result | Where-Object { $_.Name -eq 'One' } | Select-Object -ExpandProperty CommandLine | Should-ContainCollection 'C:\App\one.exe'
        $result | Where-Object { $_.Name -eq 'Two' } | Select-Object -ExpandProperty CommandLine | Should-ContainCollection 'C:\App\two.exe'
      }
    }
  }
  Describe 'Move-ItemToRecycleBin' {
    BeforeAll {
      Mock -CommandName Test-Path -MockWith { $true }
      Mock -CommandName Get-Item -ParameterFilter { ($Path -eq 'C:\dir\file.txt' -or $LiteralPath -eq 'C:\dir\file.txt' -or $PSPath -eq 'C:\dir\file.txt') -and $Force -eq $true } -MockWith {
        [PSCustomObject]@{
          FullName      = 'C:\dir\file.txt'
          PSIsContainer = $false
        }
      }
      $movedItems = [List[string]]::new()
      Mock -CommandName New-Object -ParameterFilter { $ComObject -eq 'Shell.Application' } -MockWith {
        $recycleBin = [PSCustomObject]@{}
        $recycleBin | Add-Member -MemberType ScriptMethod -Name MoveHere -Value {
          param(
            [string]
            $Path
          )
          $movedItems.Add($Path) | Out-Null
        }
        $shell = [PSCustomObject]@{ RecycleBin = $recycleBin }
        $shell | Add-Member -MemberType ScriptMethod -Name NameSpace -Value { return $this.RecycleBin }
        return $shell
      }
    }
    BeforeEach {
      $movedItems.Clear()
    }
    Context 'ParameterSetName' {
      It 'moves the item to recycle bin by Path' {
        Move-ItemToRecycleBin -Path 'C:\dir\file.txt'

        $movedItems | Should-BeCollection -Count 1
        $movedItems[0] | Should-BeString 'C:\dir\file.txt'
      }
      It 'moves the item to recycle bin by Path with ValueFromPipeline' {
        'C:\dir\file.txt' | Move-ItemToRecycleBin
        $movedItems | Should-BeCollection -Count 1
        $movedItems[0] | Should-BeString 'C:\dir\file.txt'
      }
      It 'moves the item to recycle bin by Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = 'C:\dir\file.txt' } | Move-ItemToRecycleBin
        $movedItems | Should-BeCollection -Count 1
        $movedItems[0] | Should-BeString 'C:\dir\file.txt'
      }
      It 'moves the item to recycle bin by LiteralPath' {
        Move-ItemToRecycleBin -LiteralPath 'C:\dir\file.txt'

        $movedItems | Should-BeCollection -Count 1
        $movedItems[0] | Should-BeString 'C:\dir\file.txt'
      }
      It 'Moves the item to recycle bin by LiteralPath with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ PSPath = 'C:\dir\file.txt' } | Move-ItemToRecycleBin
        $movedItems | Should-BeCollection -Count 1
        $movedItems[0] | Should-BeString 'C:\dir\file.txt'
      }
    }
    Context 'SupportsShouldProcess' {
      It 'does not move the item when WhatIf is supplied' {
        Move-ItemToRecycleBin -Path 'C:\dir\file.txt' -WhatIf | Out-Null

        $movedItems.Count | Should-Be 0
      }
    }
    Context 'Other parameters' {
    }
    Context 'Edge cases' {
    }
  }
  Describe 'New-Shortcut' {
    BeforeAll {
      Mock -CommandName Remove-Item
      Mock -CommandName Resolve-Path -MockWith { [PSCustomObject]@{ Path = $TargetPath } }
      Mock -CommandName Test-Path -MockWith { $true }
      Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\dir\shortcut.lnk' -and $Force -eq $true } -MockWith {
        [PSCustomObject]@{ FullName = 'C:\dir\shortcut.lnk' }
      }
      Mock -CommandName New-Object -ParameterFilter { $ComObject -eq 'WScript.Shell' } -MockWith {
        $shortcut = [PSCustomObject]@{
          FullName         = $null
          TargetPath       = $null
          WorkingDirectory = $null
          Arguments        = $null
          Description      = $null
          IconLocation     = $null
          HotKey           = $null
          WindowStyle      = $null
        }
        $shortcut | Add-Member -MemberType ScriptMethod -Name Save -Value { }
        $shell = [PSCustomObject]@{ Shortcut = $shortcut }
        $shell | Add-Member -MemberType ScriptMethod -Name CreateShortcut -Value {
          param(
            [string]
            $Path
          )
          $this.Shortcut.FullName = $Path
          return $this.Shortcut
        }
        return $shell
      }
    }
    Context 'ParameterSetName' {
      It 'creates a shortcut by Path' {
        New-Shortcut -Path 'C:\dir\shortcut.lnk' -TargetPath 'C:\Windows\notepad.exe' | Out-Null
      }
      It 'creates a shortcut by Path with ValueFromPipeline' {
        'C:\dir\shortcut' | New-Shortcut -TargetPath 'C:\Windows\notepad.exe' | Out-Null
      }
      It 'creates a shortcut by Path with ValueFromPipelineByPropertyName' {
        [PSCustomObject]@{ Path = 'C:\dir\shortcut' } | New-Shortcut -TargetPath 'C:\Windows\notepad.exe' | Out-Null
      }
      It 'appends .lnk extension when needed' {
        New-Shortcut -Path 'C:\dir\shortcut' -TargetPath 'C:\Windows\notepad.exe' | Out-Null

        Should-Invoke -CommandName New-Object -ParameterFilter { $ComObject -eq 'WScript.Shell' } -Times 1 -Exactly
      }
    }
    Context 'Output' {
      It 'returns the created shortcut with FullName property' {
        $result = New-Shortcut -Path 'C:\dir\shortcut.lnk' -TargetPath 'C:\Windows\notepad.exe'

        $result.FullName | Should-BeString 'C:\dir\shortcut.lnk'
      }
      It 'returns the created shortcut with FullName property by ValueFromPipeline' {
        $result = 'C:\dir\shortcut' | New-Shortcut -TargetPath 'C:\Windows\notepad.exe'

        $result.FullName | Should-BeString 'C:\dir\shortcut.lnk'
      }
      It 'returns the created shortcut with FullName property by ValueFromPipelineByPropertyName' {
        $result = [PSCustomObject]@{ Path = 'C:\dir\shortcut' } | New-Shortcut -TargetPath 'C:\Windows\notepad.exe'

        $result.FullName | Should-BeString 'C:\dir\shortcut.lnk'
      }
    }
    Context 'SupportsShouldProcess' {
      It 'does not create a shortcut when WhatIf is specified' {
        New-Shortcut -Path 'C:\dir\shortcut' -TargetPath 'C:\Windows\notepad.exe' -Force -WhatIf | Out-Null

        Should-Invoke -CommandName New-Object -ParameterFilter { $ComObject -eq 'WScript.Shell' } -Times 0 -Exactly
      }
      It 'suppresses ShouldProcess when Force is supplied with Confirm' {
        Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\dir\shortcut.lnk' -and $Force -eq $true } -MockWith {
          [PSCustomObject]@{ FullName = 'C:\dir\shortcut.lnk' }
        }
        New-Shortcut -Path 'C:\dir\shortcut' -TargetPath 'C:\Windows\notepad.exe' -Force -Confirm | Out-Null
        Should-Invoke -CommandName New-Object -ParameterFilter { $ComObject -eq 'WScript.Shell' } -Times 1 -Exactly
      }
    }
    Context 'Other parameters' {
      It 'sets HotKey and WindowStyle on the shortcut' {
        $mockShortcut = [PSCustomObject]@{

          TargetPath       = $null
          WorkingDirectory = $null
          Arguments        = $null
          Description      = $null
          IconLocation     = $null
          HotKey           = $null
          WindowStyle      = $null
        }
        $mockShortcut | Add-Member -MemberType ScriptMethod -Name Save -Value { }
        Mock -CommandName New-Object -ParameterFilter { $ComObject -eq 'WScript.Shell' } -MockWith {
          $shell = [PSCustomObject]@{ Shortcut = $mockShortcut }
          $shell | Add-Member -MemberType ScriptMethod -Name CreateShortcut -Value { $this.Shortcut }
          return $shell
        }
        Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\dir\shortcut.lnk' -and $Force -eq $true } -MockWith {
          [PSCustomObject]@{ FullName = 'C:\dir\shortcut.lnk' }
        }
        New-Shortcut -Path 'C:\dir\shortcut' -TargetPath 'C:\Windows\notepad.exe' -HotKey 'F5' -WindowStyle Maximum
        $mockShortcut.HotKey | Should-BeString 'Ctrl+Alt+F5'
        $mockShortcut.WindowStyle | Should-Be 3
      }
      It 'overwrites existing shortcut when Force is specified' {
        Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\dir\shortcut.lnk' -and $Force -eq $true } -MockWith {
          [PSCustomObject]@{ FullName = 'C:\dir\shortcut.lnk' }
        }
        New-Shortcut -Path 'C:\dir\shortcut.lnk' -TargetPath 'C:\Windows\notepad.exe' -Force | Out-Null
        Should-Invoke -CommandName Remove-Item -Times 1 -Exactly
      }
    }
    Context 'Edge cases' {
    }
  }
  Describe 'New-UrlShortcut' {
    BeforeAll {
      Mock -CommandName Test-Path -MockWith { $true }
      Mock -CommandName Remove-Item
      Mock -CommandName New-Object -ParameterFilter { $ComObject -eq 'WScript.Shell' } -MockWith {
        $shortcut = [PSCustomObject]@{ TargetPath = $null }
        $shortcut | Add-Member -MemberType ScriptMethod -Name Save -Value { }
        $shell = [PSCustomObject]@{ Shortcut = $shortcut }
        $shell | Add-Member -MemberType ScriptMethod -Name CreateShortcut -Value { $this.Shortcut }
        return $shell
      }
    }
    Context 'ParameterSetName' {
      It 'appends .url extension when needed' {
        Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\dir\shortcut.url' -and $Force -eq $true } -MockWith {
          [PSCustomObject]@{ FullName = 'C:\dir\shortcut.url' }
        }
        New-UrlShortcut -Path 'C:\dir\shortcut' -TargetPath 'https://example.com' | Out-Null
        Should-Invoke -CommandName New-Object -ParameterFilter { $ComObject -eq 'WScript.Shell' } -Times 1 -Exactly
      }
    }
    Context 'SupportsShouldProcess' {
      It 'does not create a shortcut when WhatIf is specified' {
        New-UrlShortcut -Path 'C:\dir\shortcut' -TargetPath 'https://example.com' -Force -WhatIf | Out-Null

        Should-Invoke -CommandName New-Object -ParameterFilter { $ComObject -eq 'WScript.Shell' } -Times 0 -Exactly
      }
      It 'suppresses ShouldProcess when Force is supplied with Confirm' {
        Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\dir\shortcut.url' -and $Force -eq $true } -MockWith {
          [PSCustomObject]@{ FullName = 'C:\dir\shortcut.url' }
        }
        New-UrlShortcut -Path 'C:\dir\shortcut.url' -TargetPath 'https://example.com' -Force -Confirm | Out-Null
        Should-Invoke -CommandName Remove-Item -Times 1 -Exactly
      }
    }
    Context 'Other parameters' {
    }
    Context 'Edge cases' {
    }
  }
  Describe 'Get-Shortcut' {
    BeforeAll {
      Mock -CommandName Test-Path -MockWith { $true }
      Mock -CommandName New-Object -ParameterFilter { $ComObject -eq 'WScript.Shell' } -MockWith {
        $shortcut = [PSCustomObject]@{ FullName = 'C:\dir\shortcut.lnk' }
        $shell = [PSCustomObject]@{ Shortcut = $shortcut }
        $shell | Add-Member -MemberType ScriptMethod -Name CreateShortcut -Value { $this.Shortcut }
        return $shell
      }
    }
    Context 'ParameterSetName' {
      It 'returns the shortcut object by Path with wildcards' {
        Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\shortcut.lnk' -and $Force -eq $true } -MockWith {
          [PSCustomObject]@{ FullName = 'C:\dir\shortcut.lnk' }
        }
        Get-Shortcut -Path 'C:\dir\shortcut.lnk' | Should-NotBeNull
        Should-Invoke -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\shortcut.lnk' -and $Force -eq $true } -Times 1 -Exactly
      }
      It 'returns the shortcut object by LiteralPath' {
        Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\dir\shortcut.lnk' -and $Force -eq $true } -MockWith {
          [PSCustomObject]@{ FullName = 'C:\dir\shortcut.lnk' }
        }
        Get-Shortcut -LiteralPath 'C:\dir\shortcut.lnk' | Should-NotBeNull
        Should-Invoke -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\dir\shortcut.lnk' -and $Force -eq $true } -Times 1 -Exactly
      }
    }
    Context 'Output' {
      It 'returns the shortcut object with FullName property by Path' {
        Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\shortcut.lnk' -and $Force -eq $true } -MockWith {
          [PSCustomObject]@{ FullName = 'C:\dir\shortcut.lnk' }
        }
        $result = Get-Shortcut -Path 'C:\dir\shortcut.lnk'
        $result.FullName | Should-BeString 'C:\dir\shortcut.lnk'
      }
      It 'returns the shortcut object with FullName property by LiteralPath' {
        Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\dir\shortcut.lnk' -and $Force -eq $true } -MockWith {
          [PSCustomObject]@{ FullName = 'C:\dir\shortcut.lnk' }
        }
        $result = Get-Shortcut -LiteralPath 'C:\dir\shortcut.lnk'
        $result.FullName | Should-BeString 'C:\dir\shortcut.lnk'
      }
    }
    Context 'Other parameters' {
    }
    Context 'Edge cases' {
    }
  }
  Describe 'Test-Shortcut' {
    BeforeAll {
      Mock -CommandName Test-Path -MockWith { $true }
      Mock -CommandName Get-Shortcut -MockWith {
        [PSCustomObject]@{ TargetPath = 'C:\Windows\notepad.exe' }
      }
    }
    Context 'ParameterSetName' {
      It 'returns True when shortcut target exists by Path with wildcards' {
        Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\shortcut.lnk' } -MockWith {
          [PSCustomObject]@{ FullName = 'C:\dir\shortcut.lnk' }
        }
        Test-Shortcut -Path 'C:\dir\shortcut.lnk' | Should-BeTrue
        Should-Invoke -CommandName Get-Shortcut -Times 1 -Exactly
      }
      It 'returns True when shortcut target exists by LiteralPath' {
        Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\dir\shortcut.lnk' } -MockWith {
          [PSCustomObject]@{ FullName = 'C:\dir\shortcut.lnk' }
        }
        Test-Shortcut -LiteralPath 'C:\dir\shortcut.lnk' | Should-BeTrue
        Should-Invoke -CommandName Get-Shortcut -Times 1 -Exactly
      }
    }
    Context 'Output' {
      It 'returns a boolean result by Path' {
        Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\shortcut.lnk' } -MockWith {
          [PSCustomObject]@{ FullName = 'C:\dir\shortcut.lnk' }
        }
        $result = Test-Shortcut -Path 'C:\dir\shortcut.lnk'
        $result | Should-BeTrue
      }
      It 'returns a boolean result by LiteralPath' {
        Mock -CommandName Get-Item -ParameterFilter { $LiteralPath -eq 'C:\dir\shortcut.lnk' } -MockWith {
          [PSCustomObject]@{ FullName = 'C:\dir\shortcut.lnk' }
        }
        $result = Test-Shortcut -LiteralPath 'C:\dir\shortcut.lnk'
        $result | Should-BeTrue
      }
    }
    Context 'Edge cases' {
      It 'returns False when shortcut file is not found' {
        Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'C:\dir\missing.lnk' } -MockWith {

          throw [ItemNotFoundException]::new('Item not found')
        }
        $result = Test-Shortcut -Path 'C:\dir\missing.lnk'
        $result | Should-BeFalse
      }
    }
  }
  Describe 'New-NetworkDrive' {
    BeforeAll {
      Mock -CommandName New-PSDrive
      Mock -CommandName Remove-PSDrive
      Mock -CommandName Test-Path -MockWith { $true }
    }
    Context 'ParameterSetName' {
      It 'creates a persistent network drive for the specified name and root' {
        New-NetworkDrive -Name Z -Root '\\server\share'

        Should-Invoke -CommandName New-PSDrive -ParameterFilter { $Name -eq 'Z' -and $Root -eq '\\server\share' -and $Scope -eq 'Global' -and $Persist -eq $true } -Times 1 -Exactly
      }
    }
    Context 'SupportsShouldProcess' {
      It 'supports WhatIf without throwing errors' {
        New-NetworkDrive -Name Z -Root '\\server\share' -Force -WhatIf | Out-Null

        Should-Invoke -CommandName New-PSDrive -Times 1 -Exactly
      }
      It 'suppresses ShouldProcess when Force is supplied with Confirm' {
        New-NetworkDrive -Name Z -Root '\\server\share' -Force -Confirm | Out-Null

        Should-Invoke -CommandName Remove-PSDrive -ParameterFilter { $Name -eq 'Z' -and $Scope -eq 'Global' -and $Force -eq $true } -Times 1 -Exactly
        Should-Invoke -CommandName New-PSDrive -ParameterFilter { $Name -eq 'Z' -and $Root -eq '\\server\share' -and $Scope -eq 'Global' -and $Persist -eq $true } -Times 1 -Exactly
      }
    }
    Context 'Other parameters' {
    }
    Context 'Edge cases' {
    }
  }
  Describe 'New-NetworkShortcut' {
    BeforeAll {
      $networkShortcutExists = $false
      Mock -CommandName New-Shortcut -MockWith { [PSCustomObject]@{ FullName = 'C:\network\target.lnk' } }
      Mock -CommandName Out-File
      Mock -CommandName Set-ItemProperty
      Mock -CommandName Test-Path -ParameterFilter { $IsValid -eq $true } -MockWith { $true }
      Mock -CommandName Test-Path -MockWith {
        if ($networkShortcutExists) {
          $networkShortcutExists = $false
          return $true
        }
        return $false
      }
      Mock -CommandName Remove-Item -MockWith { $networkShortcutExists = $false }
      Mock -CommandName New-Item -MockWith {
        param(
          [string]
          $Path
        )
        $networkShortcutExists = $true
        [PSCustomObject]@{ FullName = $Path }
      }
      Mock -CommandName Get-Item -MockWith {
        param(
          [string]
          $LiteralPath
        )
        [PSCustomObject]@{ FullName = $LiteralPath }
      }
    }
    Context 'ParameterSetName' {
      It 'creates a network shortcut folder and target shortcut' {
        $networkShortcutExists = $false

        New-NetworkShortcut -Path '\\server\share' | Out-Null

        Should-Invoke -CommandName New-Item -Times 1 -Exactly
        Should-Invoke -CommandName New-Shortcut -Times 1 -Exactly
        Should-Invoke -CommandName Set-ItemProperty -Times 2 -Exactly
      }
    }
    Context 'SupportsShouldProcess' {
      It 'supports WhatIf without throwing errors' {
        $networkShortcutExists = $false

        New-NetworkShortcut -Path '\\server\share' -Force -WhatIf | Out-Null

        Should-Invoke -CommandName New-Item -Times 0 -Exactly
        Should-Invoke -CommandName New-Shortcut -Times 0 -Exactly
      }
      It 'suppresses ShouldProcess when Force is supplied with Confirm' {
        $networkShortcutExists = $true

        New-NetworkShortcut -Path '\\server\share' -Force -Confirm | Out-Null

        Should-Invoke -CommandName Remove-Item -Times 1 -Exactly
        Should-Invoke -CommandName New-Shortcut -Times 1 -Exactly
        Should-Invoke -CommandName Set-ItemProperty -Times 2 -Exactly
      }
    }
    Context 'Other parameters' {
    }
    Context 'Edge cases' {
    }
  }
}
