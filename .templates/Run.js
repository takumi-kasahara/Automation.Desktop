'use strict';

var FileSystemObject = WScript.CreateObject('Scripting.FileSystemObject');
var WshShell = WScript.CreateObject('WScript.Shell');
var args = [];
for (var i = 0; i < WScript.Arguments.Length; i++)
  args.push(WScript.Arguments.Item(i));
var cmdArgs = args.length ? ' "' + args.join('" "') + '"' : '';

WshShell.CurrentDirectory = FileSystemObject.GetParentFolderName(
  WScript.ScriptFullName
);
var files = [
  'Main.cmd',
  'Main.ps1',
  'Main.RunAs.cmd',
  'Main.RunAs.ps1',
  'Main.js'
];
for (var j = 0; j < files.length; j++) {
  var file = files[j];
  var path = FileSystemObject.BuildPath(WshShell.CurrentDirectory, file);
  if (!FileSystemObject.FileExists(path)) continue;
  switch (FileSystemObject.GetFileName(path)) {
    case 'Main.cmd':
      WshShell.Run(
        'cmd.exe /D /E:ON /V:OFF /S /C call "' + file + '"' + cmdArgs,
        0,
        false
      );
      break;
    case 'Main.ps1':
      WshShell.Run(
        'pwsh.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -File "' +
          file +
          '"' +
          cmdArgs,
        0,
        false
      );
      break;
    case 'Main.RunAs.cmd':
      WshShell.Run(
        'sudo.exe --disable-input cmd.exe /D /E:ON /V:OFF /S /C call "' +
          file +
          '"' +
          cmdArgs,
        0,
        false
      );
      break;
    case 'Main.RunAs.ps1':
      WshShell.Run(
        'sudo.exe --disable-input pwsh.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -File "' +
          file +
          '"' +
          cmdArgs,
        0,
        false
      );
      break;
    case 'Main.js':
      WshShell.Run(
        'wscript.exe //B //Nologo "' + file + '"' + cmdArgs,
        0,
        false
      );
      break;
  }
  WScript.Quit(0);
}
