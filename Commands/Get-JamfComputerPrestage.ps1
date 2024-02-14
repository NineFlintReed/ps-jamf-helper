function Update-JamfComputerPrestageCache {
    $script:jamf_computer_prestages = &{
        $result = [pscustomobject]@{
            FromPrestageId = @{}
            FromPrestageName = @{}
        }
        jamf_get_allpages "/api/v3/computer-prestages" |
        ForEach-Object {
            $result.FromPrestageId[$_.id.ToString()] = $_
            $result.FromPrestageName[$_.displayName] = $_
        }
        $result
    }
}


function Get-JamfComputerPrestage {
    [CmdletBinding(DefaultParameterSetName='All')]
    Param(
        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='Prestage')]
        [String]$Prestage,

        [ValidateNotNullOrEmpty()]
        [Alias('udid')]
        [Parameter(ParameterSetName='Computer',ValueFromPipelineByPropertyName)]
        [String]$Computer
    )

    process {
        if(-not (Test-Path 'variable:jamf_computer_prestages')) {
            Update-JamfComputerPrestageCache
        }
        
        switch($PSCmdlet.ParameterSetName) {
            'Prestage' {
                $cached = switch(get_jamf_id_type $Prestage) {
                    'numeric' { $script:jamf_computer_prestages.FromPrestageId[$Prestage] }
                    'text' { $script:jamf_computer_prestages.FromPrestageName[$Prestage] }
                }
                if($cached) {
                    jamf_get_single "/api/v3/computer-prestages/$($cached.id)"
                }
            }
            'Computer' {
                $scopes = (jamf_get_single "/api/v2/computer-prestages/scope" -As Hashtable).serialsByPrestageId
                $device = Get-JamfComputer -Computer $Computer -Include HARDWARE
                if($device -and $scopes[$device.hardware.serialNumber]) {
                    jamf_get_single "/api/v3/computer-prestages/$($scopes[$device.hardware.serialNumber])"
                }
            }
            'All' {
                jamf_get_allpages "/api/v3/computer-prestages"
            }
        }
    }
}