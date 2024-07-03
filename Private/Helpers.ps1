function check_jamf_token {
    if([String]::IsNullOrEmpty($JamfAuth.Token) -or ([DateTime]::Now -gt $JamfAuth.Expiry)) {
        $params = @{
            Method = 'POST'
            Uri = "${env:JAMF_ROOT}/api/v1/auth/token"
            Headers = @{ Authorization = "Basic ${env:JAMF_USER}" }
        }
        
        $result = Invoke-RestMethod @params
        
        $script:JamfAuth.Token = $result.token
        $script:JamfAuth.Expiry = $result.expires.ToLocalTime().AddMinutes(-5)
        #$script:JamfAuth.Expiry = ([DateTimeOffset]::FromUnixTimeMilliseconds($result.expires)).DateTime.ToLocalTime().AddMinutes(-5)    
    }
}


function make_query {
    Param (
        [Collections.IDictionary]$QueryDict
    )
    # @{val='abcd';pets=@('cats','dogs')} -> 'pets=cats&pets=dogs&val=abcd'
    $result = [Web.HttpUtility]::ParseQueryString('')
    if($null -ne $QueryDict -and $QueryDict.Count -gt 0) {
        foreach($key in $QueryDict.Keys) {
            $val = $QueryDict[$key]
            if($val -is [Collections.IList]) {
                foreach($item in $val) {
                    $result.Add($key, $item)
                }
            } else {
                $result.Add($key, $val)
            }
        }
    }

    return @(,$result)
}


function jamf_get_single {
    Param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Endpoint,
        
        [Collections.IDictionary]$Body,

        [ValidateSet('Xml','Hashtable','Object')]
        $As = 'Object'
    )

    $query = make_query $Body

    $uri = [System.UriBuilder]::new($env:JAMF_ROOT)
    $uri.Path = $Endpoint
    $uri.Query = $query.ToString()
    
    $params = @{
        Method = 'GET'
        Uri = $Uri.ToString()
        Headers = @{
            Authorization = "Bearer $($script:JamfAuth.Token)"
            Accept = $As -in 'Object','Hashtable' ? 'application/json' : 'application/xml' 
        }
    }
    
    Invoke-WebRequest @params |
    Select-Object -ExpandProperty Content |
    ForEach-Object {
        if($As -eq 'Xml') {
            [xml]$_
        } elseif($As -eq 'Hashtable') {
            $_ | ConvertFrom-Json -Depth 10 -AsHashtable
        } elseif($As -eq 'Object') {
            $_ | ConvertFrom-Json -Depth 10
        }
    }
}


function jamf_get_allpages {
    Param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Endpoint,

        [Collections.IDictionary]$Body,

        [ValidateSet('Xml','Hashtable','Object')]
        $As = 'Object'
    )
    check_jamf_token
    $params = @{
        Endpoint = $Endpoint
        As = $As
        Body = $Body
    }
    if($null -eq $Body -or $Body.Count -eq 0) {
        $params.Body = @{ page = 0 }
    } else {
        $params.Body['page'] = 0
    }

    $num_results = 0
    do {
        $response = jamf_get_single @params
        $results = $response.results
        $num_results += $results.Count
        $results
        $params.Body.page += 1
    } while($num_results -lt $response.totalCount)
}

function jamf_post_json {
    Param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Endpoint,
        
        [Collections.IDictionary]$Body,

        [ValidateSet('Hashtable','Object')]
        $As = 'Object'
    )
    check_jamf_token

    $uri = [System.UriBuilder]::new($env:JAMF_ROOT)
    $uri.Path = $Endpoint
    
    $params = @{
        Method = 'POST'
        Uri = $Uri.ToString()
        Headers = @{
            Authorization = "Bearer $($script:JamfAuth.Token)"
            Accept = 'application/json'
        }
        ContentType = 'application/json'
        Body = $Body | ConvertTo-Json -Depth 10
    }
    
    Invoke-WebRequest @params |
    ForEach-Object {
        if($As -eq 'Hashtable') {
            $_ | ConvertFrom-Json -Depth 10 -AsHashtable
        } elseif($As -eq 'Object') {
            $_ | ConvertFrom-Json -Depth 10
        }
    }
}

function get_jamf_id_type {
    Param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$id
    )
    if($id -match '^\d+$') { # standard id
        'numeric'
    } elseif($id -cmatch '^[0-9a-f]{40}$') { # old style mobile device
        'udid'
    } elseif($id -cmatch '^[0-9A-F]{8}-[0-9A-F]{16}$') { # new old style mobile device
        'udid'
    } elseif($id -as [guid]) { # computer
        'udid'
    } else { # serialnumber or name
        'text'
    }
}