function Get-JamfMobileDevicePrestageScope {
    [CmdletBinding(DefaultParameterSetName='All')]
    Param(
        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='Prestage')]
        [String]$Prestage
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
                jamf_get_single "/api/v2/mobile-device-prestages/$($cached.id)/scope" -As Hashtable
            }
        }
        'All' {
            (jamf_get_single "/api/v2/mobile-device-prestages/scope" -As Hashtable).serialsByPrestageId
        }
    }
}