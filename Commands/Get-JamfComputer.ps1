$get_jamf_computer_all_includes = @(
    'GENERAL','DISK_ENCRYPTION','PURCHASING','APPLICATIONS','STORAGE',
    'USER_AND_LOCATION','CONFIGURATION_PROFILES','PRINTERS','SERVICES',
    'HARDWARE','LOCAL_USER_ACCOUNTS','CERTIFICATES','ATTACHMENTS',
    'PLUGINS','PACKAGE_RECEIPTS','FONTS','SECURITY','OPERATING_SYSTEM',
    'LICENSED_SOFTWARE','IBEACONS','SOFTWARE_UPDATES',
    'EXTENSION_ATTRIBUTES','CONTENT_CACHING','GROUP_MEMBERSHIPS'
)

<#
.SYNOPSIS
    Get a computer object

.DESCRIPTION
    A wrapper over the '/api/v1/computers-inventory' endpoint

.OUTPUTS
    A PSCustomObject or OrderedDictionary that contains the fields specified in the 'Include' parameter. Other properties are present but null.

.EXAMPLE
    Get-JamfComputer -Include *
    Outputs all properties of all computer records currently in Jamf

.EXAMPLE
    Get-JamfComputer -User 'jsmith@orgname.edu.au'
    Outputs records of all computers where 'jsmith@orgname.edu.au' is the user

.EXAMPLE
    Get-JamfComputer -Computer 'C02JJ077DHJW' -Include 'GENERAL','EXTENSION_ATTRIBUTES'
    Gets the computer matching that serial number, including the specified properties.

.EXAMPLE
    # user_device_mapping.csv
    # "Email","Computer"
    # "jsmith@orgname.edu.au","C02JWM0MDNCR"
    # "tbrown@orgname.edu.au","C02ZT1NRJV3X"

    Import-Csv "user_device_mapping.csv" | Get-JamfComputer
#>
function Get-JamfComputer {
    [CmdletBinding(DefaultParameterSetName='All')]
    Param(
        # Filters returned computer by either serial number or udid. Note that serial number is not necessarily unique, since there can be zombie enrollments.
        [ValidateNotNullOrEmpty()]
        [Alias('udid')]
        [Parameter(ParameterSetName='Computer',ValueFromPipelineByPropertyName)]
        [String]$Computer,

        # Filters the returned devices by the email or username shown in `userAndLocation`
        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='User')]
        [String]$User,

        # Custom filter in RSQL format, see Jamf API docs for details
        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='Filter')]
        [String]$Filter,

        # Which computer object properties to retrieve. A smaller set of properties is retrieved faster. Can use '*' as a shorthand for all properties.
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

        # Specify the output type written to the pipeline. "Hashtable" is an OrderedDictionary, "Object" is a PSCustomObject
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