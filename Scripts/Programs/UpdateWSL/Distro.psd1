# wsl.exe --list --online --quiet
@{
  'Debian'         = @{
    'Script' = 'debian.sh'
  }
  'Ubuntu'         = @{
    'Script' = 'debian.sh'
  }
  'FedoraLinux-44' = @{
    'Script' = 'redhat.sh'
  }
  'AlmaLinux-10'   = @{
    'Script' = 'redhat.sh'
  }
}
