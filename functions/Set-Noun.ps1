function Set-Noun {
    <#
    .SYNOPSIS
        Set-Noun sets the configuration of Noun
        
    .DESCRIPTION
        Longer description of what Set-Noun does
        
    .PARAMETER SqlInstance
        The target SQL Server instance or instances. You must have sysadmin access and server version must be SQL Server version 2000 or greater.
  
    .PARAMETER SqlCredential
        Login to the target instance using alternative credentials. Accepts PowerShell credentials (Get-Credential).

        Windows Authentication, SQL Server Authentication, Active Directory - Password, and Active Directory - Integrated are all supported.

        For MFA support, please use Connect-DbaInstance.

    .PARAMETER InputObject
        Allows Nouns to be piped in from Get-DbaNoun

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
        
    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
        
    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.
        
    .NOTES
        Tags: TAGS_HERE
        Author: Your name (@TwitterHandle)
        
        Website: https://dbatools.io
        Copyright: (c) 2018 by dbatools, licensed under MIT
        License: MIT https://opensource.org/licenses/MIT
        
    .LINK
        https://dbatools.io/Set-Noun
        
    .EXAMPLE
        PS C:\> Set-Noun -SqlInstance sql2014
        
        Sets the configuration of Noun on SQL Server instance sql2014
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parmaeter(ValueFromPipeline)]
        [DbaInstanceParameter[]]$SqlInstance,
        [PSCredential]$SqlInstance,
        [string[]]$Noun,
        [string[]]$ExcludeNoun,
        [object[]]$InputObject,
        [switch]$EnableException
    )
    begin {
        # Check any parameters you need using Test-Bound
        # We **DO NOT** use parameter validation in the param block
        
        if ( (Test-Bound SqlInstance -Not) -and (Test-Bound InputObject -Not) {
            Stop-Function -Message "You must pipe in a Noun or provide an SqlInstance"
            return
        }
    }
    process {
        if (Test-FunctionInterrupt) { return }
        
        if (Test-Bound SqlInstance) {
            $InputObject += Get-DbaNoun -SqlInstance $SqlInstance -SqlCredential $SqlCredential -Noun $Noun -ExcludeNoun $ExcludeNoun
        }
        
        foreach ($noun in $InbputObject) {
            <# Magic happens here #>
            
            <#
            Write-Message is used for outputing verbose, output, or warning messages
            Stop-Function is used in the catch blocks
            #>
            
            <#
                Preference is to output an SMO object, so once the "set" action has been successfully could just recall Get-DbaNoun to output the given noun object
            #>
        }
    }
}
