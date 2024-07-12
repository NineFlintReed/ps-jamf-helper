
# <#
# .SYNOPSIS
#     Retrieves the computers scoped to a prestage
# #>
# function Get-JamfComputerPrestageScope {
#     [CmdletBinding(DefaultParameterSetName='All')]
#     Param(
#         [ValidateNotNullOrEmpty()]
#         [Parameter(ParameterSetName='Prestage')]
#         [String]$Prestage
#     )

#     if(-not (Test-Path 'variable:jamf_computer_prestages')) {
#         Update-JamfComputerPrestageCache
#     }

#     switch($PSCmdlet.ParameterSetName) {
#         'Prestage' {
#             $cached = switch(get_jamf_id_type $Prestage) {
#                 'numeric' { $script:jamf_computer_prestages.FromPrestageId[$Prestage] }
#                 'text' { $script:jamf_computer_prestages.FromPrestageName[$Prestage] }
#             }
#             if($cached) {
#                 jamf_get_single "/api/v2/computer-prestages/$($cached.id)/scope" -As Hashtable
#             }
#         }
#         'All' {
#             (jamf_get_single "/api/v2/computer-prestages/scope" -As Hashtable).serialsByPrestageId
#         }
#     }
# }