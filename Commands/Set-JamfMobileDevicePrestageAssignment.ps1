function remove_from_mobile_prestage {
    Param($prestage_id,$serial,$versionlock)
    $params = @{
        Endpoint = "/api/v2/mobile-device-prestages/$prestage_id/scope/delete-multiple"
        Body = @{
            serialNumbers = @($serial)
            versionLock = $versionlock
        }
    }
    jamf_post_json @params >$null
}

function add_to_mobile_prestage {
    Param($prestage_id,$serial,$versionlock)
    $params = @{
        Endpoint = "/api/v2/mobile-device-prestages/$prestage_id/scope"
        Body = @{
            serialNumbers = @($serial)
            versionLock = $versionlock
        }
    }
    jamf_post_json @params >$null
}


function Set-JamfMobileDevicePrestageAssignment {
    Param(
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory,ParameterSetName='Set')]
        [Parameter(ParameterSetName='Clear')]
        [String]$MobileDevice,
    
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory,ParameterSetName='Set')]
        [String]$Prestage,

        [Parameter(Mandatory,ParameterSetName='Clear')]
        [Switch]$Clear
    )

    $device = Get-JamfMobileDevice -MobileDevice $MobileDevice -Include GENERAL,HARDWARE
    $current_prestage = Get-JamfMobileDevicePrestage -MobileDevice $device.general.udid
    
    switch($PSCmdlet.ParameterSetName) {
        'Clear' {
            if($current_prestage -and $Clear) {
                remove_from_mobile_prestage -prestage_id $current_prestage.id -serial $device.hardware.serialNumber -versionlock $current_prestage.versionLock
            }
        }
        'Set' {
            $target_prestage = Get-JamfMobileDevicePrestage -Prestage $Prestage

            if(-not $target_prestage) {
                Write-Error "Unable to find mobile device prestage with identifier '$Prestage'. Ensure the identifier is either the prestage id or name."
                return
            }
            if($current_prestage -and ($target_prestage.id -eq $current_prestage.id)) {
                return
            }
            
            if($current_prestage) {
                remove_from_mobile_prestage -prestage_id $current_prestage.id -serial $device.hardware.serialNumber -versionlock $current_prestage.versionLock           
            }
            add_to_mobile_prestage -prestage_id $target_prestage.id -serial $device.hardware.serialNumber -versionlock $target_prestage.versionLock
        }
    }
}