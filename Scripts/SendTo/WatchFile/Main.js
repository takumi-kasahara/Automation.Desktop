'use strict';

var WshShell = WScript.CreateObject('WScript.Shell');
var FileSystemObject = WScript.CreateObject('Scripting.FileSystemObject');
for (var i = 0; i < WScript.Arguments.Length; i++) {
  var path = WScript.Arguments.Item(i);
  if (FileSystemObject.FileExists(path))
    WshShell.Run('notepad++.exe -monitor "' + path + '"');
}
