function Get-Noun {
	<#
		.SYNOPSIS
			Outputs the Noun found on the server.

		.DESCRIPTION
            Longer description of what Get-Noun does.

		.PARAMETER SqlInstance
			The SQL Server instance. Server version must be SQL Server version 2012 or higher.

        .PARAMETER SqlCredential
			Allows you to login to servers using SQL Logins instead of Windows Authentication (AKA Integrated or Trusted). To use:

			$scred = Get-Credential, then pass $scred object to the -SqlCredential parameter.

			Windows Authentication will be used if SqlCredential is not specified. SQL Server does not accept Windows credentials being passed as credentials.

			To connect as a different Windows user, run PowerShell as that user.

		.PARAMETER Silent
			If this switch is enabled, the internal messaging functions will be silenced.

		.NOTES
            Tags: TAGS_HERE 
            Original Author: Your name (@TwitterHandle)

			Website: https://dbatools.io
			Copyright: (C) Chrissy LeMaire, clemaire@gmail.com
			License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0

		.LINK
			https://dbatools.io/Get-Noun

		.EXAMPLE
			Get-Noun -SqlInstance sqlserver2014a

			Returns basic information on all Nouns found on sqlserver2014a

    #>
}