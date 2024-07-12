# function remove_from_computer_prestage {
#     Param($prestage_id,$serial,$versionlock)
#     $params = @{
#         Endpoint = "/api/v2/computer-prestages/$prestage_id/scope/delete-multiple"
#         Body = @{
#             serialNumbers = @($serial)
#             versionLock = $versionlock
#         }
#     }
#     jamf_post_json @params >$null
# }

# function add_to_computer_prestage {
#     Param($prestage_id,$serial,$versionlock)
#     $params = @{
#         Endpoint = "/api/v2/computer-prestages/$prestage_id/scope"
#         Body = @{
#             serialNumbers = @($serial)
#             versionLock = $versionlock
#         }
#     }
#     jamf_post_json @params >$null
# }

# function Set-JamfComputerPrestageAssignment {
#     Param(
#         [ValidateNotNullOrEmpty()]
#         [Parameter(Mandatory,ParameterSetName='Set')]
#         [Parameter(ParameterSetName='Clear')]
#         [String]$Computer,
    
#         [ValidateNotNullOrEmpty()]
#         [Parameter(Mandatory,ParameterSetName='Set')]
#         [String]$Prestage,

#         [Parameter(Mandatory,ParameterSetName='Clear')]
#         [Switch]$Clear
#     )

#     $enrollment = Get-JamfDeviceEnrollment -SerialNumber $Computer
#     if(-not $enrollment) {
#         throw "Device is not enrolled, and can not be prestaged."
#     }

#     #$device = Get-JamfComputer -Computer $Computer -Include GENERAL,HARDWARE

#     #$enrollment.serialNumber

#     $current_prestage = $enrollment.prestageId
    
#     switch($PSCmdlet.ParameterSetName) {
#         'Clear' {
#             if($current_prestage -and $Clear) {
#                 remove_from_computer_prestage -prestage_id $current_prestage -serial $enrollment.serialNumber -versionlock $current_prestage.versionLock
#             }
#         }
#         'Set' {
#             $target_prestage = Get-JamfComputerPrestage -Prestage $Prestage

#             if(-not $target_prestage) {
#                 Write-Error "Unable to find computer prestage with identifier '$Prestage'. Ensure the identifier is either the prestage id or name."
#                 return
#             }
#             if($current_prestage -and ($target_prestage.id -eq $current_prestage)) {
#                 return
#             }
            
#             if($current_prestage) {
#                 remove_from_computer_prestage -prestage_id $current_prestage -serial $enrollment.serialNumber -versionlock $current_prestage.versionLock           
#             }
#             add_to_computer_prestage -prestage_id $target_prestage.id -serial $enrollment.serialNumber -versionlock $target_prestage.versionLock
#         }
#     }
# }