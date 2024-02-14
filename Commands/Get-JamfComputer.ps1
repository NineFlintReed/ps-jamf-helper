$get_jamf_computer_all_includes = @(
    'GENERAL','DISK_ENCRYPTION','PURCHASING','APPLICATIONS','STORAGE',
    'USER_AND_LOCATION','CONFIGURATION_PROFILES','PRINTERS','SERVICES',
    'HARDWARE','LOCAL_USER_ACCOUNTS','CERTIFICATES','ATTACHMENTS',
    'PLUGINS','PACKAGE_RECEIPTS','FONTS','SECURITY','OPERATING_SYSTEM',
    'LICENSED_SOFTWARE','IBEACONS','SOFTWARE_UPDATES',
    'EXTENSION_ATTRIBUTES','CONTENT_CACHING','GROUP_MEMBERSHIPS'
)


function Get-JamfComputer {
    [CmdletBinding(DefaultParameterSetName='All')]
    Param(
        [ValidateNotNullOrEmpty()]
        [Alias('udid')]
        [Parameter(ParameterSetName='Computer',ValueFromPipelineByPropertyName)]
        [String]$Computer,

        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='User')]
        [String]$User,

        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='Filter')]
        [String]$Filter,

        
        [ValidateSet(
            '*',
            'GENERAL','DISK_ENCRYPTION','PURCHASING','APPLICATIONS','STORAGE',
            'USER_AND_LOCATION','CONFIGURATION_PROFILES','PRINTERS','SERVICES',
            'HARDWARE','LOCAL_USER_ACCOUNTS','CERTIFICATES','ATTACHMENTS',
            'PLUGINS','PACKAGE_RECEIPTS','FONTS','SECURITY','OPERATING_SYSTEM',
            'LICENSED_SOFTWARE','IBEACONS','SOFTWARE_UPDATES',
            'EXTENSION_ATTRIBUTES','CONTENT_CACHING','GROUP_MEMBERSHIPS'
        )]
        [String[]]$Include = @('GENERAL','HARDWARE','USER_AND_LOCATION'),

        [ValidateSet('Hashtable','Object')]
        $As = 'Object'
    )

    process {

        $params = @{
            Endpoint = "/api/v1/computers-inventory"
            As = $As
            Body = @{
                'page-size' = 100
            }
        }
        if($Include -contains '*') {
            $params.Body['section'] = $get_jamf_computer_all_includes
        } else {
            $params.Body['section'] = $Include
        }

        if($PSCmdlet.ParameterSetName -in 'Computer','User','Filter') {
            $params.Body['filter'] = switch($PSCmdlet.ParameterSetName) {
                'Computer' {
                    switch(get_jamf_id_type $Computer) {
                        'numeric' { "id==${Computer}" }
                        'text' { "hardware.serialNumber==${Computer}" }
                        'udid' { "udid==${Computer}" }
                    }
                }
                'User' { "userAndLocation.username=='${User}' or userAndLocation.email=='${User}'" }
                'Filter' { $Filter }
            }
        }
        
        jamf_get_allpages @params
    }
}