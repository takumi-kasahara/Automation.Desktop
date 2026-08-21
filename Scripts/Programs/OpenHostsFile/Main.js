'use strict';

var WshShell = new ActiveXObject('WScript.Shell');
var Shell = new ActiveXObject('Shell.Application');
Shell.ShellExecute(
  'notepad++.exe',
  WshShell.ExpandEnvironmentStrings(
    '%SystemRoot%\\System32\\drivers\\etc\\hosts',
  ),
  '',
  'runas',
  1,
);
