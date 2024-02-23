function Initialize-JamfCommandCompletion {
    Update-JamfComputerPrestageCache
    Update-JamfMobileDevicePrestageCache
    Update-JamfDeviceEnrollmentCache

    Register-ArgumentCompleter -CommandName 'Get-JamfComputerPrestage','Get-JamfComputerPrestageScope','Set-JamfComputerPrestageAssignment' -ParameterName 'Prestage' -ScriptBlock {
        Param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
        $script:jamf_computer_prestages.FromPrestageName.Keys.Where({
            $_ -like "*$WordToComplete*"
        }).ForEach({
            "'{0}'" -f $_
        })
    }

    Register-ArgumentCompleter -CommandName 'Get-JamfMobileDevicePrestage','Get-JamfMobileDevicePrestageScope','Set-JamfMobileDevicePrestageAssignment' -ParameterName 'Prestage' -ScriptBlock {
        Param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
        $script:jamf_mobile_device_prestages.FromPrestageName.Keys.Where({
            $_ -like "*$WordToComplete*"
        }).ForEach({
            "'{0}'" -f $_
        })
    }
    
    # Register-ArgumentCompleter -CommandName 'Get-JamfComputer' -ParameterName 'Computer' -ScriptBlock {
    #     Param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
    #     $script:jamf_device_enrollments.FromDeviceSerial.Keys.Where({
    #         $_ -like "*$WordToComplete*"
    #     }).ForEach({
    #         "'{0}'" -f $_
    #     })
    # }
}