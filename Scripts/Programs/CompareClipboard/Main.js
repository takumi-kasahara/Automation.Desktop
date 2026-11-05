'use strict';

WScript.CreateObject('WScript.Shell').Run(
  'WinMerge.exe /e /u /clipboard-compare'
);
