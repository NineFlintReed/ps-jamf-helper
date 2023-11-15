
function Get-JamfComputer {
    [CmdletBinding(DefaultParameterSetName='All')]
    Param(
        [ValidateNotNullOrEmpty()]    
        [Parameter(ParameterSetName='Id')]
        [String]$Id,

        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='SerialNumber')]
        [String]$SerialNumber,

        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='Username')]
        [String]$Username,

        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='UserEmail')]
        [String]$UserEmail,

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
        [String[]]$Include = @('GENERAL','HARDWARE')
    )

    $Body = @{
        'page' = 0
        'page-size' = 100
    }

    if($Include.Contains('*')) {
        $Body['section'] = @('GENERAL','DISK_ENCRYPTION','PURCHASING','APPLICATIONS','STORAGE',
            'USER_AND_LOCATION','CONFIGURATION_PROFILES','PRINTERS','SERVICES','HARDWARE',
            'LOCAL_USER_ACCOUNTS','CERTIFICATES','ATTACHMENTS','PLUGINS','PACKAGE_RECEIPTS','FONTS',
            'SECURITY','OPERATING_SYSTEM','LICENSED_SOFTWARE','IBEACONS','SOFTWARE_UPDATES',
            'EXTENSION_ATTRIBUTES','CONTENT_CACHING','GROUP_MEMBERSHIPS')
    } else {
        $Body['section'] = $Include
    }
    
    if($PSCmdlet.ParameterSetName -in 'Username','SerialNumber','Id','UserEmail') {
        $Body['filter'] = switch($PSCmdlet.ParameterSetName) {
            'Id'           { "id==${Id}"                              }
            'SerialNumber' { "hardware.serialNumber==${SerialNumber}" }
            'Username'     { "userAndLocation.username==${UserName}"  }
            'UserEmail'    { "userAndLocation.email==${UserEmail}"    }
            'Filter'       { $Filter                                  }
        }
    }
    
    do {
        $response = Invoke-JamfRequest -Method 'GET' -Endpoint "/api/v1/computers-inventory" -Body $Body
        $response.results | Write-Output
        $body['page'] += 1
    } while($response.results.Count -ge $body['page-size'])

}
