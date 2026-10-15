'use strict';

var WshShell = new ActiveXObject('WScript.Shell');
var vs_installer = WshShell.ExpandEnvironmentStrings(
  '%ProgramFiles(x86)%\\Microsoft Visual Studio\\Installer\\vs_installer.exe'
);
// https://learn.microsoft.com/en-us/visualstudio/ide/reference/import-and-export-settings-command?view=visualstudio
WshShell.Run('"' + vs_installer + '" --locale en-US');
