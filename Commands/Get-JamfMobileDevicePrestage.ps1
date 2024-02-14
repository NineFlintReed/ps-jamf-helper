function Update-JamfMobileDevicePrestageCache {
    Write-Information "Updating Jamf mobile device prestage cache"
    $script:jamf_mobile_device_prestages = &{
        $result = [pscustomobject]@{
            FromPrestageId = @{}
            FromPrestageName = @{}
        }
        jamf_get_allpages "/api/v2/mobile-device-prestages" |
        ForEach-Object {
            $result.FromPrestageId[$_.id.ToString()] = $_
            $result.FromPrestageName[$_.displayName] = $_
        }
        $result
    }
}


function Get-JamfMobileDevicePrestage {
    [CmdletBinding(DefaultParameterSetName='All')]
    Param(
        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='Prestage')]
        [String]$Prestage,

        [ValidateNotNullOrEmpty()]
        [Alias('udid')]
        [Parameter(ParameterSetName='MobileDevice',ValueFromPipelineByPropertyName)]
        [String]$MobileDevice
    )

    if(-not (Test-Path 'variable:jamf_mobile_device_prestages')) {
        Update-JamfMobileDevicePrestageCache
    }
    
    switch($PSCmdlet.ParameterSetName) {
        'Prestage' {
            $cached = switch(get_jamf_id_type $Prestage) {
                'numeric' { $script:jamf_mobile_device_prestages.FromPrestageId[$Prestage] }
                'text' { $script:jamf_mobile_device_prestages.FromPrestageName[$Prestage] }
            }
            if($cached) {
                jamf_get_single "/api/v2/mobile-device-prestages/$($cached.id)"
            }
        }
        'MobileDevice' {
            $scopes = (jamf_get_single "/api/v2/mobile-device-prestages/scope" -As Hashtable).serialsByPrestageId
            $device = Get-JamfMobileDevice -MobileDevice $MobileDevice -Include HARDWARE
            if($device -and $scopes[$device.hardware.serialNumber]) {
                jamf_get_single "/api/v2/mobile-device-prestages/$($scopes[$device.hardware.serialNumber])"
            }
        }
        'All' {
            jamf_get_allpages "/api/v2/mobile-device-prestages"
        }
    }
}