$get_jamf_mobile_device_all_includes = @(
    'GENERAL','HARDWARE','USER_AND_LOCATION','PURCHASING',
    'SECURITY','APPLICATIONS','EBOOKS','NETWORK','SERVICE_SUBSCRIPTIONS',
    'CERTIFICATES','PROFILES','USER_PROFILES','PROVISIONING_PROFILES',
    'SHARED_USERS','EXTENSION_ATTRIBUTES'
)

<#
.SYNOPSIS
    Get mobile device objects, including AppleTV's, iPads etc.

.DESCRIPTION
    A wrapper over the '/api/v2/mobile-devices/detail' endpoint

.OUTPUTS
    A PSCustomObject or OrderedDictionary that contains the fields specified in the 'Include' parameter. Other properties are present but null.

.EXAMPLE
    Get-JamfMobileDevice -User 'jsmith@orgname.edu.au'
    Outputs records of all mobile devices where 'jsmith@orgname.edu.au' is the user

.EXAMPLE
    Get-JamfMobileDevice -MobileDevice 'C02JJ077DHJW' -Include 'GENERAL','EXTENSION_ATTRIBUTES'
    Gets the mobile device matching that serial number, including the specified properties.

.EXAMPLE
    # user_device_mapping.csv
    # "Email","MobileDevice"
    # "jsmith@orgname.edu.au","C02JWM0MDNCR"
    # "tbrown@orgname.edu.au","C02ZT1NRJV3X"

    Import-Csv "user_device_mapping.csv" | Get-JamfMobileDevice
#>
function Get-JamfMobileDevice {
    [CmdletBinding(DefaultParameterSetName='All')]
    Param(
        # Filters returned mobile device by either serial number or mobileDeviceId. Note that serial number is not necessarily unique, since there can be zombie enrollments.
        [ValidateNotNullOrEmpty()]
        [Alias('mobileDeviceId')]
        [Parameter(ParameterSetName='MobileDevice',ValueFromPipelineByPropertyName)]
        [String]$MobileDevice,

        # Filters the returned devices by the email or username shown in `userAndLocation`
        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='User')]
        [String]$User,

        # Custom filter in RSQL format, see Jamf API docs for details
        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='Filter')]
        [String]$Filter,

        # Which mobile device properties to retrieve. A smaller set of properties is retrieved faster. Can use '*' as a shorthand for all properties.
        [ValidateSet(
            '*',
            'GENERAL','HARDWARE','USER_AND_LOCATION','PURCHASING',
            'SECURITY','APPLICATIONS','EBOOKS','NETWORK','SERVICE_SUBSCRIPTIONS',
            'CERTIFICATES','PROFILES','USER_PROFILES','PROVISIONING_PROFILES',
            'SHARED_USERS','EXTENSION_ATTRIBUTES'
        )]
        [String[]]$Include = @('GENERAL','HARDWARE','USER_AND_LOCATION'),

        # Specify the output type written to the pipeline. "Hashtable" is an OrderedDictionary, "Object" is a PSCustomObject
        [ValidateSet('Hashtable','Object')]
        $As = 'Object'
    )

    process {

        $params = @{
            Endpoint = "/api/v2/mobile-devices/detail"
            As = $As
            Body = @{
                'page-size' = 100
            }
        }

        if($Include -contains '*') {
            $params.Body['section'] = $get_jamf_mobile_device_all_includes
        } else {
            $params.Body['section'] = $Include
        }

        if($PSCmdlet.ParameterSetName -in 'MobileDevice','User','Filter') {
            $params.Body['filter'] = switch($PSCmdlet.ParameterSetName) {
                'MobileDevice' {
                    switch(get_jamf_id_type $MobileDevice) {
                        'numeric' { "mobileDeviceId==${MobileDevice}" }
                        'text' { "serialNumber==${MobileDevice}" }
                        'udid' { "udid==${MobileDevice}"}
                    }
                }
                'User' { "username=='${User}' or emailAddress=='${User}'" }
                'Filter'       { $Filter }
            }
        }

        jamf_get_allpages @params
    }

}