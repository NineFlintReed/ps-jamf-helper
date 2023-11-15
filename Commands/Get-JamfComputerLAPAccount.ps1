

function Get-JamfComputerLAPAccount {
    Param(
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [Parameter(Mandatory,ParameterSetName='Id',ValueFromPipelineByPropertyName)]
        [String]$ComputerId,

        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory,ParameterSetName='Serial')]
        [String]$SerialNumber,

        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory,ParameterSetName='ManagementId')]
        [String]$ManagementId
    )

    process {
        $management_id = switch($PSCmdlet.ParameterSetName) {
            'Id'           { (Get-JamfComputer -Id $ComputerId).general.managementId }
            'Serial'       { (Get-JamfComputer -SerialNumber $SerialNumber).general.managementId }
            'ManagementId' { $ManagementId }
        }

        Invoke-JamfRequest -Method 'GET' -Endpoint "/api/v2/local-admin-password/${management_id}/accounts"
    }
}