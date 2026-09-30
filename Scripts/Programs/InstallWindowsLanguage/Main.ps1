<#
.SYNOPSIS
  Installs Japanese and English language packs and configures Windows language settings.

.DESCRIPTION
  This script installs Japanese and English language packs on Windows, configures the user interface language, system locale, UI language override, and default input method.
  It sets the timezone to Tokyo Standard Time and configures geographical location to Japan.

.NOTES
  Requires administrator privileges to install languages and configure system settings.
  The script modifies system locale and language settings which may require a reboot.
#>
[CmdletBinding()]
param ()

Set-StrictMode -Version Latest
Set-Location -LiteralPath $PSScriptRoot

$ja = 'ja-JP'
$en = 'en-US'
if ($null -eq (Get-InstalledLanguage -Language $ja)) {
  Install-Language -Language $ja
}
if ($null -eq (Get-InstalledLanguage -Language $en)) {
  Install-Language -Language $en
}
$langs = Get-WinUserLanguageList
if (@($langs | Where-Object -Property LanguageTag -EQ $en).Count -eq 0) {
  $langs.Add((New-WinUserLanguageList -Language $en)[0])
}
if (@($langs | Where-Object -Property LanguageTag -EQ $ja).Count -eq 0) {
  $langs.Add((New-WinUserLanguageList -Language $ja)[0])
}
Set-WinUserLanguageList -LanguageList $langs -Force
if ((Get-SystemPreferredUILanguage) -ne $en) {
  Set-SystemPreferredUILanguage -Language $en
}
if ((Get-WinSystemLocale) -ne $ja) {
  Set-WinSystemLocale -SystemLocale $ja
}
if ((Get-WinUILanguageOverride) -ne $en) {
  Set-WinUILanguageOverride -Language $en
}

Set-TimeZone -Id 'Tokyo Standard Time'
# https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/default-input-locales-for-windows-language-packs?view=windows-11
Set-WinDefaultInputMethodOverride -InputTip '0411:{03B5835F-F03C-411B-9CE2-AA23E1171E36}{A76C93D9-5523-4E90-AAFA-4DB112F9AC76}' # Microsoft IME
# https://learn.microsoft.com/en-us/windows/win32/intl/table-of-geographical-locations
Set-WinHomeLocation -GeoId 0x7a # Japan

if (Get-WinAcceptLanguageFromLanguageListOptOut) {
  Set-WinAcceptLanguageFromLanguageListOptOut -OptOut $false
}
if (Get-WinSystemLocaleFromLanguageListOptOut) {
  Set-WinSystemLocaleFromLanguageListOptOut -OptOut $false
}
Set-WinLanguageBarOption
