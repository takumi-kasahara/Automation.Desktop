
[CmdletBinding()]
param ()

Set-StrictMode -Version Latest
Set-Location -LiteralPath $PSScriptRoot

$savedPictures = Get-SpecialFolder -Name SavedPictures
if (-not (Test-Path -LiteralPath $savedPictures)) {
  return
}
if (@(Get-Item -Path "$savedPictures\*").Count -eq 0) {
  return
}
Get-DuplicateFile -LiteralPath $savedPictures -Recurse | Move-ItemToRecycleBin
Move-NormalizedPath -LiteralPath $savedPictures -Recurse -Force -PassThru
Get-EmptyDirectory -LiteralPath $savedPictures -Recurse | Move-ItemToRecycleBin
$log = $env:TEMP | Join-Path -ChildPath "SimilarNames.$(Get-Date -Format 'yyyyMMddHHmmss').log"
$log | Out-Host
Measure-Directory -LiteralPath $savedPictures -SimilarNames |
Select-Object -ExpandProperty SimilarNames |
ForEach-Object {
  return [PSCustomObject]@{
    OlderName  = $_.OlderItem.Name
    NewerName  = $_.NewerItem.Name
    Similarity = $_.Similarity
  }
} |
Export-Csv -LiteralPath $log
