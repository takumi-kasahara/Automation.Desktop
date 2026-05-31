@{
  # https://learn.microsoft.com/en-us/windows/apps/develop/launch/launch-settings
  Settings  = @(
    #region Apps
    @{
      Name = 'Installed apps'
      Uri  = 'ms-settings:appsfeatures'
    }
    @{
      Name = 'Apps for websites'
      Uri  = 'ms-settings:appsforwebsites'
    }
    @{
      Name = 'Default apps'
      Uri  = 'ms-settings:defaultapps'
    }
    @{
      Name = 'Optional features'
      Uri  = 'ms-settings:optionalfeatures'
    }
    @{
      Name = 'Startup'
      Uri  = 'ms-settings:startupapps'
    }
    #endregion
    #region Devices
    @{
      Name = 'Autoplay'
      Uri  = 'ms-settings:autoplay'
    }
    @{
      Name = 'Bluetooth'
      Uri  = 'ms-settings:bluetooth'
    }
    @{
      Name = 'Devices'
      Uri  = 'ms-settings:connecteddevices'
    }
    @{
      Name = 'Mouse'
      Uri  = 'ms-settings:mousetouchpad'
    }
    @{
      Name = 'Printers'
      Uri  = 'ms-settings:printers'
    }
    @{
      Name = 'Typing'
      Uri  = 'ms-settings:typing'
    }
    @{
      Name = 'Mobile devices'
      Uri  = 'ms-settings:mobile-devices'
    }
    #endregion
    #region System
    @{
      Name = 'Network & Internet'
      Uri  = 'ms-settings:network-status'
    }
    @{
      Name = 'Mobile hotspot'
      Uri  = 'ms-settings:network-mobilehotspot'
    }
    @{
      Name = 'Proxy'
      Uri  = 'ms-settings:network-proxy'
    }
    @{
      Name = 'VPN'
      Uri  = 'ms-settings:network-vpn'
    }
    @{
      Name = 'Wi-Fi'
      Uri  = 'ms-settings:network-wifi'
    }
    #endregion
    #region Personalization
    @{
      Name = 'Fonts'
      Uri  = 'ms-settings:fonts'
    }
    @{
      Name = 'Lock screen'
      Uri  = 'ms-settings:lockscreen'
    }
    @{
      Name = 'Start'
      Uri  = 'ms-settings:personalization-start'
    }
    @{
      Name = 'Taskbar'
      Uri  = 'ms-settings:taskbar'
    }
    @{
      Name = 'Themes'
      Uri  = 'ms-settings:themes'
    }
    #endregion
    #region Search
    @{
      Name = 'Search'
      Uri  = 'ms-settings:search'
    }
    #endregion
    #region Sound
    @{
      Name = 'Volume mixer'
      Uri  = 'ms-settings:apps-volume'
    }
    @{
      Name = 'Sound'
      Uri  = 'ms-settings:sound'
    }
    @{
      Name = 'Sound devices'
      Uri  = 'ms-settings:sound-devices'
    }
    #endregion
    #region System
    @{
      Name = 'Clipboard'
      Uri  = 'ms-settings:clipboard'
    }
    @{
      Name = 'Display'
      Uri  = 'ms-settings:display'
    }
    @{
      Name = 'Multitasking'
      Uri  = 'ms-settings:multitasking'
    }
    @{
      Name = 'Notifications'
      Uri  = 'ms-settings:notifications'
    }
    @{
      Name = 'Remote Desktop'
      Uri  = 'ms-settings:remotedesktop'
    }
    @{
      Name = 'Power'
      Uri  = 'ms-settings:powersleep'
    }
    @{
      Name = 'Storage'
      Uri  = 'ms-settings:storagesense'
    }
    @{
      Name = 'Disks & Volumes'
      Uri  = 'ms-settings:disksandvolumes'
    }
    #endregion
    #region Time and language
    @{
      Name = 'Date & Time'
      Uri  = 'ms-settings:dateandtime'
    }
    @{
      Name = 'Microsoft IME'
      Uri  = 'ms-settings:regionlanguage-jpnime'
    }
    @{
      Name = 'Language'
      Uri  = 'ms-settings:regionlanguage'
    }
    #endregion
    #region Update & Security
    @{
      Name = 'Activation'
      Uri  = 'ms-settings:activation'
    }
    @{
      Name = 'Windows Backup'
      Uri  = 'ms-settings:backup'
    }
    @{
      Name = 'Delivery Optimization'
      Uri  = 'ms-settings:delivery-optimization'
    }
    @{
      Name = 'Find My Device'
      Uri  = 'ms-settings:findmydevice'
    }
    @{
      Name = 'Advanced'
      Uri  = 'ms-settings:developers'
    }
    @{
      Name = 'Recovery'
      Uri  = 'ms-settings:recovery'
    }
    @{
      Name = 'Troubleshoot'
      Uri  = 'ms-settings:troubleshoot'
    }
    @{
      Name = 'Windows Security'
      Uri  = 'ms-settings:windowsdefender'
    }
    @{
      Name = 'Windows Insider Program'
      Uri  = 'ms-settings:windowsinsider'
    }
    @{
      Name = 'Windows Update'
      Uri  = 'ms-settings:windowsupdate'
    }
    #endregion
  )
  Shortcuts = @(
    @{
      Name       = 'Desktop Icon Settings'
      TargetPath = 'rundll32.exe'
      Arguments  = 'shell32.dll, Control_RunDLL desk.cpl, , 0'
    }
    @{
      Name       = 'System Properties'
      TargetPath = 'SystemPropertiesAdvanced.exe'
      Arguments  = $null
    }
    @{
      Name       = 'Windows Features'
      TargetPath = 'OptionalFeatures.exe'
      Arguments  = $null
    }
  )
  # https://learn.microsoft.com/en-us/windows/win32/shell/controlpanel-canonical-names
  # https://learn.microsoft.com/en-us/windows/win32/shell/executing-control-panel-items
  Controls  = @(
    'Microsoft.AdministrativeTools'
    'Microsoft.AutoPlay'
    'Microsoft.BackupAndRestore'
    'Microsoft.BitLockerDriveEncryption'
    'Microsoft.CredentialManager'
    'Microsoft.DateAndTime'
    'Microsoft.DeviceManager'
    'Microsoft.DevicesAndPrinters'
    'Microsoft.FileHistory'
    'Microsoft.FolderOptions'
    'Microsoft.IndexingOptions'
    'Microsoft.Keyboard'
    'Microsoft.Mouse'
    'Microsoft.NetworkAndSharingCenter'
    'Microsoft.PowerOptions'
    'Microsoft.ProgramsAndFeatures'
    'Microsoft.Recovery'
    'Microsoft.RegionAndLanguage'
    'Microsoft.StorageSpaces'
    'Microsoft.SyncCenter'
  )
}
