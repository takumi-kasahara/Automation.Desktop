'use strict';

// https://docs.microsoft.com/en-us/visualstudio/ide/reference/import-and-export-settings-command
WScript.CreateObject('WScript.Shell').Run(
  'devenv.exe /Command Tools.ImportandExportSettings'
);
