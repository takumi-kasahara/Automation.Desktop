'use strict';

var WshShell = WScript.CreateObject('WScript.Shell');
var Shell = WScript.CreateObject('Shell.Application');
Shell.ShellExecute(
  'notepad++.exe',
  WshShell.ExpandEnvironmentStrings(
    '%SystemRoot%\\System32\\drivers\\etc\\hosts'
  ),
  '',
  'runas',
  1
);
