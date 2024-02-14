# base uri of jamf instance
# $env:JAMF_ROOT = ''
# $env:JAMF_USER is USERNAME:PASSWORD base64 encoded
# convert from: [Text.Encoding]::UTF8.GetString([convert]::FromBase64String($str))
# convert to  : [convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($str))
# $env:JAMF_USER = ''

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version '3.0'

$script:JamfAuth = @{
    Token = ''
    Expiry = $null
}

. "$PSScriptRoot/Private/Helpers.ps1"


(Get-ChildItem "$PSScriptRoot/Commands").ForEach({. "$_"})















