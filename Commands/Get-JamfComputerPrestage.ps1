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

<#
.SYNOPSIS
    Get a computer prestage object

.DESCRIPTION
    A wrapper over the computer prestages endpoints. Supports prestage lookup by name as well as id, with optional autocomplete for the prestage name.
    Note that the prestages themselves are cached on first run of this command, and may be out of date if prestages are edited while this tool is used.

.OUTPUTS
    A list of prestage objects as PSCustomObject's

.EXAMPLE
    Get-JamfComputerPrestage
    # Outputs list of all computer prestages

.EXAMPLE
    Get-JamfComputerPrestage -Prestage 'Laptop - CYOT Students'
    # Outputs the prestage with displayName 'Laptop - CYOT Students'

.EXAMPLE
    Get-JamfComputerPrestage -Prestage 15
    # Outputs the prestage with id 15

.EXAMPLE
    Get-JamfComputerPrestage -Computer 'C02JWM0MDNCR'
    # Outputs the prestage object associated with computer 'C02JWM0MDNCR'
#>
function Get-JamfComputerPrestage {
    [CmdletBinding(DefaultParameterSetName='All')]
    Param(
        # The computer prestage, specified as either a prestage id or displayName
        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='Prestage')]
        [String]$Prestage,

        # The computer, specified as either a serial number of udid. If specified, will return the prestage associated with this computer (if it has one).
        [ValidateNotNullOrEmpty()]
        [Alias('udid')]
        [Parameter(ParameterSetName='Computer',ValueFromPipelineByPropertyName)]
        [String]$Computer,

        # Internal, do not use
        [Parameter(DontShow)]
        [Switch]$_DontValidateSerial
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
                if($_DontValidateSerial) {
                    if($scopes[$Computer]) {
                        jamf_get_single "/api/v3/computer-prestages/$($scopes[$Computer])"
                    }
                } else {
                    $device = Get-JamfComputer -Computer $Computer -Include HARDWARE
                    if($device -and $scopes[$device.hardware.serialNumber]) {
                        jamf_get_single "/api/v3/computer-prestages/$($scopes[$device.hardware.serialNumber])"
                    }
                }

            }
            'All' {
                jamf_get_allpages "/api/v3/computer-prestages"
            }
        }
    }
}