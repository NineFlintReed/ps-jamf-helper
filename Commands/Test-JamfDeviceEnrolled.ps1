function Test-JamfDeviceEnrolled {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$SerialNumber
    )

    if(-not (Test-Path -Path Variable:_jamf_device_enrollments)) {
        $global:_jamf_device_enrollments = [ordered]@{}
        jamf_get_allpages "/api/v1/device-enrollments/1/devices" |
        ForEach-Object {
            $global:_jamf_device_enrollments[$_.serialNumber] = $_
        }
    }

    return $global:_jamf_device_enrollments.Contains($SerialNumber)
}