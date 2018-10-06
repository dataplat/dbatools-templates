function Copy-Noun {
<#
    .SYNOPSIS
        Copies Noun between SQL Server instances.
        
    .DESCRIPTION
        Longer description of what Copy-Noun does.
        
    .PARAMETER Source
        Source SQL Server. You must have sysadmin access and server version must be SQL Server version XXXX or higher.
        
    .PARAMETER SourceSqlCredential
        Login to the target instance using alternative credentials. Windows and SQL Authentication supported. Accepts credential objects (Get-Credential)
        
    .PARAMETER Destination
        Destination SQL Server. You must have sysadmin access and the server must be SQL Server XXXX or higher.
        
    .PARAMETER DestinationSqlCredential
        Allows you to login to servers using SQL Logins instead of Windows Authentication (AKA Integrated or Trusted). To use:
        
        $dcred = Get-Credential, then pass this $dcred to the -DestinationSqlCredential parameter.
        
        Windows Authentication will be used if DestinationSqlCredential is not specified. SQL Server does not accept Windows credentials being passed as credentials.
        
        To connect as a different Windows user, run PowerShell as that user.
        
    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
        
    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
        
    .PARAMETER Force
        If this switch is enabled, the Noun will be dropped and recreated on Destination.
        
    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.
        
    .NOTES
        Tags: TAGS_HERE
        Author: Your name (@TwitterHandle)
        
        Website: https://dbatools.io
        Copyright: (c) 2018 by dbatools, licensed under MIT
        -           License: MIT https://opensource.org/licenses/MIT
        
    .LINK
        https://dbatools.io/Copy-Noun
        
    .EXAMPLE
        Copy-Noun -Source sqlserver2014a -Destination sqlcluster
        
        Copies all Nouns from sqlserver2014a to sqlcluster using Windows credentials. If Nouns with the same name exist on sqlcluster, they will be skipped.
        
    .EXAMPLE
        Copy-Noun -Source sqlserver2014a -Destination sqlcluster -Noun SqlNoun -SourceSqlCredential $cred -Force
        
        Copies a single Noun (SqlNoun) from sqlserver2014a to sqlcluster using SQL credentials for sqlserver2014a and Windows credentials for sqlcluster. If a alert with the same name exists on sqlcluster, it will be dropped and recreated because -Force was used.
        
    .EXAMPLE
        Copy-Noun -Source sqlserver2014a -Destination sqlcluster -WhatIf -Force
        
        Shows what would happen if the command were executed using force.
        
#>
}