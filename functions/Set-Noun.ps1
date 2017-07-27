function Set-Noun {
    <#
        .SYNOPSIS 
            Set-Noun sets the configuration of Noun

        .DESCRIPTION
            Longer description of what Set-Noun does

 		.PARAMETER SqlInstance
			The SQL Server instance. Server version must be SQL Server version 2012 or higher.

        .PARAMETER SqlCredential
			Allows you to login to servers using SQL Logins instead of Windows Authentication (AKA Integrated or Trusted). To use:

			$scred = Get-Credential, then pass $scred object to the -SqlCredential parameter.

			Windows Authentication will be used if SqlCredential is not specified. SQL Server does not accept Windows credentials being passed as credentials.

			To connect as a different Windows user, run PowerShell as that user.

		.PARAMETER WhatIf
			If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

		.PARAMETER Confirm
			If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

		.PARAMETER Silent
			If this switch is enabled, the internal messaging functions will be silenced.

        .NOTES
            Tags: TAGS_HERE 
            Original Author: Your name (@TwitterHandle)

            Website: https://dbatools.io
            Copyright: (C) Chrissy LeMaire, clemaire@gmail.com
            License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0

        .LINK
            https://dbatools.io/Set-Noun

        .EXAMPLE
            Set-Noun -SqlInstance sql2014

            Sets the configuration of Noun on SQL Server instance sql2014
#>
}