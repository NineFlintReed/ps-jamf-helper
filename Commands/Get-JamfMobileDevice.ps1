
function Get-JamfMobileDevice {
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
            'GENERAL','HARDWARE','USER_AND_LOCATION','PURCHASING','SECURITY','APPLICATIONS',
            'EBOOKS','NETWORK','SERVICE_SUBSCRIPTIONS','CERTIFICATES','PROFILES','USER_PROFILES',
            'PROVISIONING_PROFILES','SHARED_USERS','EXTENSION_ATTRIBUTES'
        )]
        [String[]]$Include = @('GENERAL','HARDWARE')
    )

    $Body = @{
        'page' = 0
        'page-size' = 100
    }

    $Body['section'] = if($Include.Contains('*')) {
        @('GENERAL','HARDWARE','USER_AND_LOCATION','PURCHASING','SECURITY',
        'APPLICATIONS', 'EBOOKS','NETWORK','SERVICE_SUBSCRIPTIONS','CERTIFICATES','PROFILES','USER_PROFILES',
        'PROVISIONING_PROFILES','SHARED_USERS','EXTENSION_ATTRIBUTES')
    } else {
        $Include
    }

    if($PSCmdlet.ParameterSetName -in 'Username','SerialNumber','Id','UserEmail') {
        $Body['filter'] = switch($PSCmdlet.ParameterSetName) {
            'Id'           { "mobileDeviceId==${Id}"         }
            'SerialNumber' { "serialNumber==${SerialNumber}" }
            'Username'     { "username==${UserName}"         }
            'UserEmail'    { "emailAddress==${UserEmail}"    }
            'Filter'       { $Filter                         }
        }
    }

    do {
        $response = Invoke-JamfRequest -Method 'GET' -Endpoint "/api/v2/mobile-devices/detail" -Body $Body
        $response.results | Write-Output
        $body['page'] += 1
    } while($response.results.Count -ge $body['page-size'])

}