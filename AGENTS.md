# Project Guidelines

This repository is a collection of PowerShell modules and helper scripts for Windows file system, path, shell, and utility automation.

## Overview

- `Modules/` contains PowerShell module manifests and implementation.
- `Modules/*.psd1` exports commands from `Modules/Sources/*.psm1`.
- `Modules/Sources/` contains modules and tests.
- `Scripts/Programs/` contains standalone program helper scripts.
- `Scripts/SendTo/` contains SendTo menu helper wrappers.

## Workflow

### PowerShell module development cycle

1. Edit files under `Modules/Sources/`.
2. When editing `Modules/Sources/Module.psm1`, also update or create the corresponding test file `Modules/Sources/Module.Tests.ps1` and ensure tests cover your changes.
3. When adding or removing cmdlets, also update the module manifest files (`Modules/*.psd1`) to reflect the changes.

#### Pester Invocation

Run tests with `Pester.ps1`:

- `powershell.exe -NoLogo -NoProfile -ExecutionPolicy RemoteSigned -File "Pester.ps1" -Path ".\Module.Tests.ps1"`
- Filter by line: add `-LineNumber 42`

Requires PowerShell Core (`$PSEdition -eq 'Core'`).

### PowerShell script development cycle

1. Edit files under `Scripts/`.
2. Run `Build.ps1`.

## Coding Conventions

- Avoid breaking changes unless necessary, and always seek review for such changes.
- Keep changes minimal and consistent with existing file patterns.
- Keep functions and modules small and single-responsibility.
- Prefer explicit error handling and fail-fast behavior.
- Prefer self-documenting code; use comments for intent, not for restating code.

## Command Execution Guidelines

- Do not run one-line PowerShell commands directly for auditability and reproducibility.
- Write the command content to `./.temp/execute.ps1` first.
- Run PowerShell scripts only with:
  - `pwsh.exe -NoLogo -NoProfile -ExecutionPolicy RemoteSigned -File "./.temp/execute.ps1"`
