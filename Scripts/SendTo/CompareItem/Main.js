'use strict';

var WshShell = new ActiveXObject('WScript.Shell');
var FileSystemObject = new ActiveXObject('Scripting.FileSystemObject');
var files = [];
var folders = [];
for (var i = 0; i < WScript.Arguments.Unnamed.Length; i++) {
  var path = WScript.Arguments.Unnamed.Item(i);
  if (FileSystemObject.FileExists(path))
    files.push(path);
  else if (FileSystemObject.FolderExists(path))
    folders.push(path);
}
if (files.length == 1)
  WshShell.Run('WinMerge.exe /e /u /self-compare "' + files[0] + '"', 1, false);
else if (2 <= files.length && files.length <= 3)
  WshShell.Run('WinMerge.exe /e /u /x "' + files.join('" "') + '"', 1, false);
else if (2 <= folders.length && folders.length <= 3)
  WshShell.Run('WinMerge.exe /e /u /x /r "' + folders.join('" "') + '"', 1, false);
