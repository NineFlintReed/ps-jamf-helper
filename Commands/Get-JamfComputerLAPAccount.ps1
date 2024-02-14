function Get-JamfComputerLAPAccount {
    Param(
        [ValidateNotNullOrEmpty()]
        [Alias('udid')]
        [Parameter(Mandatory,ParameterSetName='Computer',ValueFromPipelineByPropertyName)]
        [String]$Computer,

        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory,ParameterSetName='ManagementId')]
        [String]$ManagementId
    )

    process {
        $management_id = switch($PSCmdlet.ParameterSetName) {
            'Computer' { (Get-JamfComputer -Computer $Computer).general.managementId }
            'ManagementId' { $ManagementId }
        }

        jamf_get_allpages "/api/v2/local-admin-password/${management_id}/accounts"
    }
}