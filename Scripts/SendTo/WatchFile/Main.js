'use strict';

var WshShell = new ActiveXObject('WScript.Shell');
var FileSystemObject = new ActiveXObject('Scripting.FileSystemObject');
for (var i = 0; i < WScript.Arguments.length; i++) {
  var path = WScript.Arguments.Item(i);
  if (FileSystemObject.FileExists(path))
    WshShell.Run('notepad++.exe -monitor "' + path + '"');
}
