
function Invoke-JamfRequest {
    [CmdletBinding()]
    Param(
    [ValidateSet('GET','PATCH','DELETE','POST','PUT')]
    [Parameter(Position=0,Mandatory)]
    [String]$Method,

    [ValidateNotNullOrEmpty()]
    [Parameter(Position=1,Mandatory)]
    [String]$Endpoint,

    [Parameter(Position=2)]
    $Body,

    [ValidateSet('Json','PSObject','HashTable')]
    [String]$As = 'PSObject'
    )
    check_jamf_token

    $script = switch($Method) {
        'GET'    { ${Function:jamf_get}       }
        'PATCH'  { ${Function:jamf_patch}     }
        'DELETE' { ${Function:jamf_delete}    }
        'POST'   { ${Function:jamf_post}      }
        'PUT'    { ${Function:jamf_put}       }
        default  { throw 'unsupported method' }
    }

    $result = & $script -Endpoint $Endpoint -Body $Body

    if($result) {
        switch($As) {
            'Json' { $result.Content }
            'PSObject' { $result.Content | ConvertFrom-Json }
            'HashTable' { $result.Content | ConvertFrom-Json -AsHashtable }
        }
    }
}