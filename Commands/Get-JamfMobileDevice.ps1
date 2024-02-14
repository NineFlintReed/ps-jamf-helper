$get_jamf_mobile_device_all_includes = @(
    'GENERAL','HARDWARE','USER_AND_LOCATION','PURCHASING',
    'SECURITY','APPLICATIONS','EBOOKS','NETWORK','SERVICE_SUBSCRIPTIONS',
    'CERTIFICATES','PROFILES','USER_PROFILES','PROVISIONING_PROFILES',
    'SHARED_USERS','EXTENSION_ATTRIBUTES'
)

function Get-JamfMobileDevice {
    [CmdletBinding(DefaultParameterSetName='All')]
    Param(
        [ValidateNotNullOrEmpty()]
        [Alias('mobileDeviceId')]
        [Parameter(ParameterSetName='MobileDevice',ValueFromPipelineByPropertyName)]
        [String]$MobileDevice,

        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='User')]
        [String]$User,

        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='Filter')]
        [String]$Filter,

        [ValidateSet(
            '*',
            'GENERAL','HARDWARE','USER_AND_LOCATION','PURCHASING',
            'SECURITY','APPLICATIONS','EBOOKS','NETWORK','SERVICE_SUBSCRIPTIONS',
            'CERTIFICATES','PROFILES','USER_PROFILES','PROVISIONING_PROFILES',
            'SHARED_USERS','EXTENSION_ATTRIBUTES'
        )]
        [String[]]$Include = @('GENERAL','HARDWARE','USER_AND_LOCATION'),

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