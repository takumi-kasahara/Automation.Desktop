@{
  RootModule           = 'Automation.Desktop.psm1'
  ModuleVersion        = '1.0.0'
  CompatiblePSEditions = @('Core')
  FunctionsToExport    = @(
    #region Item.psm1
    'Get-DuplicateFile'
    'Get-EmptyDirectory'
    'Measure-Directory'
    'Set-ItemAttribute'
    'Remove-ItemAttribute'
    'Set-ItemDate'
    'Sync-DirectoryDate'
    'Sync-ItemDate'
    'Export-ItemDate'
    'Import-ItemDate'
    #endregion
    #region Path.psm1
    'Compress-EnvironmentVariable'
    'Expand-EnvironmentVariable',
    'ConvertTo-LocalPath'
    'ConvertTo-NetworkPath'
    'ConvertTo-WSLPath'
    'Get-NormalizedPath'
    'Move-NormalizedPath'
    'Test-ArchiveExtension'
    'Test-PdfExtension'
    'Test-PictureExtension'
    #endregion
    #region Shell.psm1
    'Get-ItemDetail'
    'Find-Application'
    'Get-Application'
    'Get-SpecialFolder'
    'Get-Startup'
    'Get-UriScheme'
    'Move-ItemToRecycleBin'
    'New-Shortcut'
    'New-UrlShortcut'
    'Get-Shortcut'
    'Test-Shortcut'
    'New-NetworkDrive'
    'New-NetworkShortcut'
    #endregion
    #region Utilities.*.psm1
    'Get-ArchivedItem'
    'Sync-ArchivedItemDate'
    'Get-ExifDate'
    'Set-ExifDate'
    'Remove-ExifDate'
    'Export-PdfDump'
    'Import-PdfDump'
    'Join-Pdf'
    'Split-Pdf'
    'ConvertTo-Qdf'
    'ConvertFrom-Qdf'
    'Unblock-Pdf'
    'Get-PdfPage'
    'Invoke-Robocopy'
    'Get-OllamaModel'
    'Remove-OllamaModel'
    'Update-OllamaModel'
    'Invoke-OllamaModel'
    'Stop-OllamaModel'
    #endregion
  )
  CmdletsToExport      = @()
  VariablesToExport    = @()
  AliasesToExport      = @()
}
