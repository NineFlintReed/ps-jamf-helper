
function check_jamf_token {
    if(-not [Uri]::IsWellFormedUriString($env:JAMF_ROOT, [UriKind]::Absolute)) {
        throw "JAMF_ROOT environment variable malformed or missing: '${env:JAMF_ROOT}'"
    }
    if($env:JAMF_USER -cnotmatch "^[-A-Za-z0-9+/]*={0,3}$") {
        throw "JAMF_USER environment variable not valid base64: '${$env:JAMF_USER}'`nMust be base64 encoded 'USERNAME:PASSWORD'"
    }

    if([String]::IsNullOrEmpty($script:JamfAuth) -or ([DateTime]::Now -gt $script:JamfAuthExpiry)) {
        $params = @{
            Method = 'POST'
            Uri = $env:JAMF_ROOT + '/api/auth/tokens'
            Headers = @{ Authorization = "Basic " + $env:JAMF_USER }
        }
        
        $result = Invoke-RestMethod @params
        
        $script:JamfAuth = $result.token
        $script:JamfAuthExpiry = ([System.DateTimeOffset]::FromUnixTimeMilliseconds($result.expires)).DateTime.ToLocalTime().AddMinutes(-5)    
    }
}


function params_to_query_string {
    Param(
        $Body
    )
    $result = [Web.HttpUtility]::ParseQueryString('')

    if($null -eq $Body) {
        Write-Output $result -NoEnumerate
        return
    }
    if($Body -is [String]) {
        $is_json = Test-Json -Json $Body -ErrorAction SilentlyContinue
        if($is_json) {
            $Body = ConvertFrom-Json $Body -AsHashtable
        } else {
            $result.Add([Web.HttpUtility]::ParseQueryString($Body))
            Write-Output $result -NoEnumerate
            return
        }
    }

    if($Body -is [PSObject]) {
        $Body = ConvertTo-Json $Body | ConvertFrom-Json -AsHashtable
    }    

    if($Body -is [Collections.IList]) {
        foreach($item in $Body) {
            $result.Add([Web.HttpUtility]::ParseQueryString($item))
        }
    }
    # for hashtables, iter and add key/val pairs
    # workaround duplicate-key problem by unwrapping 1 level of nested list
    if($Body -is [Collections.IDictionary]) {
        foreach($kv in $Body.GetEnumerator()) {
            if($kv.Value -is [Collections.IList]) {
                foreach($item in $kv.Value) {
                    $result.Add($kv.Key, $item)
                }
            } else {
                $result.Add($kv.Key, $kv.Value)
            }
        }
    }

    Write-Output $result -NoEnumerate
}








function jamf_get {
    Param(
        $Endpoint,
        $Body
    )

    $query_params = params_to_query_string $Body

    $uri = [UriBuilder]::new($env:JAMF_ROOT)
    $uri.Path = $Endpoint
    $uri.Query = $query_params.ToString()

    $params = @{
        Method = 'GET'
        Uri = $uri.ToString()
        Headers = @{
            Authorization = "Bearer $script:JamfAuth"
            Accept = 'application/json'
        }
    }

    Write-Debug "$($params.Method) $($params.Uri)"
    Invoke-WebRequest @params
}

function jamf_patch {
    Param(
        $Endpoint,
        $Body
    )

    $uri = [UriBuilder]::new($env:JAMF_ROOT)
    $uri.Path = $Endpoint

    if($Body -is [PSObject]) {
        $Body = $Body | ConvertTo-Json -Depth 4
    } elseif($Body -is [Collections.IDictionary]) {
        $Body = $Body | ConvertTo-Json -Depth 4
    }
    Test-Json $Body >$null

    $params = @{
        Method = 'PATCH'
        Uri = $uri.ToString()
        Headers = @{
            Authorization = "Bearer $script:JamfAuth"
            Accept = 'application/json'
        }
        ContentType = 'application/json'
        Body = $Body
    }

    Write-Debug "$($params.Method) $($params.Uri)"
    Write-Debug "$($Body)"
    Invoke-WebRequest @params    
}

function jamf_delete {
    Param(
        $Endpoint,
        $Body # unused
    )

    $uri = [UriBuilder]::new($env:JAMF_ROOT)
    $uri.Path = $Endpoint

    if($null -ne $Body) {
        Write-Error -ErrorAction Stop "'DELETE' does not support a 'Body' parameter"
    }

    $params = @{
        Method = 'DELETE'
        Uri = $uri.ToString()
        Headers = @{
            Authorization = "Bearer $script:JamfAuth"
            Accept = 'application/json'
        }
    }

    Write-Debug "$($params.Method) $($params.Uri)"
    Invoke-WebRequest @params
}

function jamf_post {
    Param(
        $Endpoint,
        $Body
    )
    $uri = [UriBuilder]::new($env:JAMF_ROOT)
    $uri.Path = $Endpoint

    if($Body -is [PSObject]) {
        $Body = $Body | ConvertTo-Json -Depth 4
    } elseif($Body -is [Collections.IDictionary]) {
        $Body = $Body | ConvertTo-Json -Depth 4
    }
    Test-Json $Body >$null

    $params = @{
        Method = 'POST'
        Uri = $uri.ToString()
        Headers = @{
            Authorization = "Bearer $script:JamfAuth"
            Accept = 'application/json'
        }
        ContentType = 'application/json'
        Body = $Body
    }

    Write-Debug "$($params.Method) $($params.Uri)"
    Write-Debug "$($Body)"
    Invoke-WebRequest @params
}

function jamf_put {
    Param(
        $Endpoint,
        $Body
    )
    $uri = [UriBuilder]::new($env:JAMF_ROOT)
    $uri.Path = $Endpoint

    if($Body -is [PSObject]) {
        $Body = $Body | ConvertTo-Json -Depth 4
    } elseif($Body -is [Collections.IDictionary]) {
        $Body = $Body | ConvertTo-Json -Depth 4
    }
    Test-Json $Body >$null

    $params = @{
        Method = 'PUT'
        Uri = $uri.ToString()
        Headers = @{
            Authorization = "Bearer $script:JamfAuth"
            Accept = 'application/json'
        }
        ContentType = 'application/json'
        Body = $Body
    }

    Write-Debug "$($params.Method) $($params.Uri)"
    Write-Debug "$($Body)"
    Invoke-WebRequest @params
}