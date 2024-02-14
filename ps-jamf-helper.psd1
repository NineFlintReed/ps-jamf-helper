@{
    RootModule = 'RootModule.psm1'
    ModuleVersion = '0.0.2'
    CompatiblePSEditions = @('Core')
    GUID = 'd87c02df-d19e-41e1-99b0-8ab1d767d770'
    Author = 'Tom Cousins'
    CompanyName = ''
    Copyright = '(c) Tom Cousins. All rights reserved.'
    Description = 'A collection of utilities for working with Jamf'
    PowerShellVersion = '7.3'
    RequiredModules = @()
    
    ScriptsToProcess = @()
    
    FunctionsToExport = @(
        'Get-JamfComputer'
        'Get-JamfComputerLAP'
        'Get-JamfComputerLAPAccount'
        'Get-JamfComputerPrestage'
        'Get-JamfComputerPrestageScope'
        'Get-JamfDeviceEnrollment'
        'Get-JamfMobileDevice'
        'Get-JamfMobileDevicePrestage'
        'Get-JamfMobileDevicePrestageScope'
        'Set-JamfComputerPrestageAssignment'
        'Set-JamfMobileDevicePrestageAssignment'
        'jamf_get_allpages'
        'jamf_get_single'
    )
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{}
    }
}
    
    