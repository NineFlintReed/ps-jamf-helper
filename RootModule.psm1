# base uri of jamf instance
# $env:JAMF_ROOT = ''
# $env:JAMF_USER is USERNAME:PASSWORD base64 encoded
# convert from: [Text.Encoding]::UTF8.GetString([convert]::FromBase64String($str))
# convert to  : [convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($str))
# $env:JAMF_USER = ''

Set-StrictMode -Version 'Latest'
$ErrorActionPreference = 'Stop' # Stop|Inquire|Continue|Suspend|SilentlyContinue

$script:JamfAuthExpiry = ''
$script:JamfAuth = ''

. "$PSScriptRoot/Private/Helpers.ps1"


(Get-ChildItem "$PSScriptRoot/Commands").ForEach({. "$_"})

Set-Alias -Name jamf -Value Invoke-JamfRequest -Force













