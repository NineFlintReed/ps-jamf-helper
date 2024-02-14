function Get-JamfComputerLAP {
    Param(
        [ValidateNotNullOrEmpty()]
        [Alias('udid')]
        [Parameter(Mandatory,ParameterSetName='Computer',ValueFromPipelineByPropertyName)]
        [String]$Computer,

        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory,ParameterSetName='ManagementId')]
        [Guid]$ManagementId,

        [ValidateNotNullOrEmpty()]
        [String]$AccountName = 'administrator'
    )

    process {
        $management_id = switch($PSCmdlet.ParameterSetName) {
            'Computer' { (Get-JamfComputer -Computer $Computer).general.managementId }
            'ManagementId' { $ManagementId }
        }
        jamf_get_single "/api/v2/local-admin-password/${management_id}/account/${AccountName}/password"
    }
}