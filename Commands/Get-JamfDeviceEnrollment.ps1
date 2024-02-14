function Update-JamfDeviceEnrollmentCache {
    $script:jamf_device_enrollments = &{
        $result = [pscustomobject]@{
            FromDeviceSerial = @{}
        }
        jamf_get_allpages "/api/v1/device-enrollments/1/devices" |
        ForEach-Object {
            $result.FromDeviceSerial[$_.serialNumber] = $_
        }
        $result
    }
}


function Get-JamfDeviceEnrollment {
    [CmdletBinding(DefaultParameterSetName='All')]
    Param(
        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='SerialNumber')]
        [String]$SerialNumber
    )

    if(-not (Test-Path 'variable:jamf_device_enrollments')) {
        Update-JamfDeviceEnrollmentCache
    }

    switch($PSCmdlet.ParameterSetName) {
        'SerialNumber' {
            $script:jamf_device_enrollments.FromDeviceSerial[$SerialNumber]
        }
        'All' {
            $script:jamf_device_enrollments.FromDeviceSerial
        }
    }
}