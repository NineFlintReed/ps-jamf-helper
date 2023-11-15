@{
    RootModule = 'RootModule.psm1'
    ModuleVersion = '0.0.1'
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
        'Get-JamfMobileDevice'
        'Get-JamfComputerLAP'
        'Get-JamfComputerLAPAccount'
        'Invoke-JamfRequest'
    )
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @(
        'jamf'
    )
    
    PrivateData = @{
        PSData = @{}
    }
}
    
    