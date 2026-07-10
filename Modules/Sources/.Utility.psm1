using namespace System.Diagnostics.CodeAnalysis
using namespace System.IO
using namespace System.Management.Automation

Set-StrictMode -Version Latest

function New-ErrorRecord {
  [CmdletBinding()]
  [OutputType([System.Management.Automation.ErrorRecord])]
  [SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Function creates error records but does not change state')]
  param (
    [Parameter(Mandatory)]
    [ValidateSet(
      'FileIsReadOnly'
      , 'ItemAlreadyExists'
      , 'ItemNotFound'
      , 'DestinationRequiredForFile'
    )]
    [string]
    $ErrorId,
    [string]
    $TargetObject
  )
  switch -Exact -CaseSensitive ($ErrorId) {
    'FileIsReadOnly' {
      return [ErrorRecord]::new(
        [IOException]::new("$($TargetObject.FullName) is read-only.")
        , 'FileIsReadOnly'
        , [ErrorCategory]::PermissionDenied
        , $TargetObject
      )
    }
    'ItemAlreadyExists' {
      return [ErrorRecord]::new(
        [IOException]::new("$TargetObject already exists. Use -Force to overwrite the file.")
        , 'ItemAlreadyExists'
        , [ErrorCategory]::ResourceExists
        , $TargetObject
      )
    }
    'ItemNotFound' {
      return [ErrorRecord]::new(
        [ItemNotFoundException]::new("$TargetObject not found.")
        , 'ItemNotFound'
        , [ErrorCategory]::ObjectNotFound
        , $TargetObject
      )
    }
    'DestinationRequiredForFile' {
      return [ErrorRecord]::new(
        [ArgumentException]::new("Destination is required when the input is a file. Specify -Destination or export a directory instead.")
        , 'DestinationRequiredForFile'
        , [ErrorCategory]::InvalidArgument
        , $TargetObject
      )
    }
    default {
      throw [ArgumentException]::new("Invalid:$ErrorId", 'ErrorId')
    }
  }
}
