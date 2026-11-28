# Project Guidelines

This repository is a collection of PowerShell modules and helper scripts for Windows file system, path, shell, and utility automation.

## Overview

- [Modules/](./Modules/) contains PowerShell module manifests and implementation.
- [Modules/*.psd1](./Modules/) exports commands from [Modules/Functions/*.psm1](./Modules/Functions/).
- [Modules/Functions/](./Modules/Functions/) contains modules and tests.
- [Scripts/Programs/](./Scripts/Programs/) contains standalone program helper scripts.
- [Scripts/SendTo/](./Scripts/SendTo/) contains SendTo menu helper wrappers.

## Workflow

### PowerShell module development cycle

1. Edit files under [Modules/Functions/](./Modules/Functions/).
2. When editing `Module.psm1`, also update or create the corresponding test file `Module.Tests.ps1` and ensure tests cover your changes.
3. When adding or removing cmdlets, also update the module manifest files [Modules/*.psd1](./Modules/) to reflect the changes.

#### PSScriptAnalyzer Invocation

Prefer the `psscriptanalyzer` task defined in [tasks.json](./.vscode/tasks.json) when using VS Code.

Run PSScriptAnalyzer with [analyze.cmd](./.agents/skills/powershell-7/scripts/analyze.cmd) only when invoking directly outside of VS Code tasks:

```bat
".agents\skills\powershell-7\scripts\analyze.cmd" -Path "Modules" -Recurse
```

```powershell
& '.\.agents\skills\powershell-7\scripts\analyze.cmd' -Path '.\Modules\' -Recurse
```

#### Pester Invocation

Prefer the `pester` task defined in [tasks.json](./.vscode/tasks.json) when using VS Code.

Run Pester with [pester.cmd](./.agents/skills/powershell-7/scripts/pester.cmd) only when invoking directly outside of VS Code tasks:

```bat
".agents\skills\powershell-7\scripts\pester.cmd" -Path "Modules\Functions" -Parallel
```

```powershell
& '.\.agents\skills\powershell-7\scripts\pester.cmd' -Path '.\Modules\Functions\' -Parallel
```

### PowerShell script development cycle

1. Edit files under [Scripts/](./Scripts/).
2. Run [Build.Scripts.ps1](./Build.Scripts.ps1).

### Windows Script Host development cycle

1. Edit Windows Script Host JScript under [Scripts](./Scripts/). These `.js` files run in WSH, not in a browser or Node.js.
2. Run [Build.Scripts.ps1](./Build.Scripts.ps1).
3. If a `Config.psd1` is present next to `Run.wsf`, define one or more shortcuts in its `Shortcuts` key. `Install.Scripts.ps1` reads this file to create multiple shortcuts for the same script.

   Example `Config.psd1`:

   ```powershell
   @{
     Shortcuts = @(
       @{
         Name      = 'Shortcut1'
         Arguments = '/mode:1'
       }
       @{
         Name      = 'Shortcut2'
         Arguments = '/mode:2'
       }
     )
   }
   ```

   The `Arguments` value is appended to the `wscript.exe` command line. In `Main.js`, use `WScript.Arguments.Named` to read named arguments such as `/mode:1`.

## Coding Conventions

- Avoid breaking changes unless necessary, and always seek review for such changes.
- Keep changes minimal and consistent with existing file patterns.
- Keep functions and modules small and single-responsibility.
- Prefer explicit error handling and fail-fast behavior.
- Prefer self-documenting code; use comments for intent, not for restating code.

## Command Execution Guidelines

- Do not run one-line PowerShell commands directly for auditability and reproducibility.
- Run PowerShell scripts only with:
  - `pwsh.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -File ".\.temp\execute.ps1"`
- Run Windows Script Host scripts with:
  - `cscript.exe //B //Nologo ".\.temp\execute.js"`
