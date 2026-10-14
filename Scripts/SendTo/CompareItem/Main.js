'use strict';

var WshShell = new ActiveXObject('WScript.Shell');
var FileSystemObject = new ActiveXObject('Scripting.FileSystemObject');
var m = WScript.Arguments.Named.Exists('m')
  ? WScript.Arguments.Named.Item('m')
  : 'Full';
var files = [];
var folders = [];
for (var i = 0; i < WScript.Arguments.Unnamed.length; i++) {
  var path = WScript.Arguments.Unnamed.Item(i);
  if (FileSystemObject.FileExists(path)) files.push(path);
  else if (FileSystemObject.FolderExists(path)) folders.push(path);
}
files.sort(function (a, b) {
  return a.localeCompare(b, undefined, { numeric: true });
});
folders.sort(function (a, b) {
  return a.localeCompare(b, undefined, { numeric: true });
});
var winmerge = 'WinMerge.exe /e /u';
if (files.length === 1)
  WshShell.Run(winmerge + ' /self-compare "' + files[0] + '"');
else if (2 <= files.length && files.length <= 3)
  WshShell.Run(winmerge + ' /x "' + files.join('" "') + '"');
else if (2 <= folders.length && folders.length <= 3)
  WshShell.Run(winmerge + ' /x /r /m ' + m + ' "' + folders.join('" "') + '"');
