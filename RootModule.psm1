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






function init_completions {
    Update-JamfComputerPrestageCache
    Update-JamfMobileDevicePrestageCache
    Update-JamfDeviceEnrollmentCache

    Register-ArgumentCompleter -CommandName 'Get-JamfComputerPrestage','Get-JamfComputerPrestageScope','Set-JamfComputerPrestageAssignment' -ParameterName 'Prestage' -ScriptBlock {
        Param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
        $script:jamf_computer_prestages.FromPrestageName.Keys.Where({
            $_ -like "*$WordToComplete*"
        }).ForEach({
            "'{0}'" -f $_
        })
    }

    Register-ArgumentCompleter -CommandName 'Get-JamfMobileDevicePrestage','Get-JamfMobileDevicePrestageScope','Set-JamfMobileDevicePrestageAssignment' -ParameterName 'Prestage' -ScriptBlock {
        Param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
        $script:jamf_mobile_device_prestages.FromPrestageName.Keys.Where({
            $_ -like "*$WordToComplete*"
        }).ForEach({
            "'{0}'" -f $_
        })
    }
    
    # Register-ArgumentCompleter -CommandName 'Get-JamfComputer' -ParameterName 'Computer' -ScriptBlock {
    #     Param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
    #     $script:jamf_device_enrollments.FromDeviceSerial.Keys.Where({
    #         $_ -like "*$WordToComplete*"
    #     }).ForEach({
    #         "'{0}'" -f $_
    #     })
    # }
}

init_completions






