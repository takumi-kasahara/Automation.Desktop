'use strict';

var WshShell = new ActiveXObject('WScript.Shell');
var FileSystemObject = new ActiveXObject('Scripting.FileSystemObject');
var files = [];
var folders = [];
for (var i = 0; i < WScript.Arguments.length; i++) {
  var path = WScript.Arguments.Item(i);
  if (FileSystemObject.FileExists(path))
    files.push(path);
  else if (FileSystemObject.FolderExists(path))
    folders.push(path);
}
if (files.length == 1)
  WshShell.Run('WinMerge.exe /e /u /self-compare "' + files[0] + '"', 1, false);
else if (2 <= files.length && files.length <= 3)
  WshShell.Run('WinMerge.exe /e /u /x /m Full "' + files.join('" "') + '"', 1, false);
else if (2 <= folders.length && folders.length <= 3)
  WshShell.Run('WinMerge.exe /e /u /x /m Full /r "' + folders.join('" "') + '"', 1, false);
