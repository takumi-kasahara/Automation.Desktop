var FileSystemObject = WScript.CreateObject('Scripting.FileSystemObject');
var WshShell = WScript.CreateObject('WScript.Shell');
var args = [];
for (var i = 0; i < WScript.Arguments.Length; i++) {
  args.push(WScript.Arguments.Item(i));
}
WshShell.CurrentDirectory = FileSystemObject.GetParentFolderName(
  WScript.ScriptFullName
);
var files = [
  'Main.bat',
  'Main.ps1',
  'Main.RunAs.bat',
  'Main.RunAs.ps1',
  'Main.js'
];
for (var j = 0; j < files.length; j++) {
  var file = files[j];
  var path = FileSystemObject.BuildPath(WshShell.CurrentDirectory, file);
  if (!FileSystemObject.FileExists(path)) continue;
  switch (FileSystemObject.GetFileName(path)) {
    case 'Main.bat':
      WshShell.Run(
        'cmd.exe /c "' +
          file +
          '"' +
          (args.length ? ' "' + args.join('" "') + '"' : ''),
        0,
        true
      );
      break;
    case 'Main.ps1':
      WshShell.Run(
        'pwsh.exe -NoLogo -NoProfile -ExecutionPolicy RemoteSigned -File "' +
          file +
          '"' +
          (args.length ? ' "' + args.join('" "') + '"' : ''),
        0,
        true
      );
      break;
    case 'Main.RunAs.bat':
      WshShell.Run(
        'sudo.exe --inline cmd.exe /c "' +
          file +
          '"' +
          (args.length ? ' "' + args.join('" "') + '"' : ''),
        0,
        true
      );
      break;
    case 'Main.RunAs.ps1':
      WshShell.Run(
        'sudo.exe --inline pwsh.exe -NoLogo -NoProfile -ExecutionPolicy RemoteSigned -File "' +
          file +
          '"' +
          (args.length ? ' "' + args.join('" "') + '"' : ''),
        0,
        true
      );
      break;
    case 'Main.js':
      WshShell.Run(
        'wscript.exe //B //NoLogo "' +
          file +
          '"' +
          (args.length ? ' "' + args.join('" "') + '"' : ''),
        0,
        true
      );
      break;
  }
  WScript.Quit(0);
}
