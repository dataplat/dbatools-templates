function Remove-DbaDatabase {
	<#
		.SYNOPSIS
			Drops a database, hopefully even the really stuck ones.

		.DESCRIPTION
			Tries a bunch of different ways to remove a database or two or more.

		.PARAMETER SqlInstance
			The SQL Server instance holding the databases to be removed.You must have sysadmin access and server version must be SQL Server version 2000 or higher.

		.PARAMETER SqlCredential
			Allows you to login to servers using SQL Logins as opposed to Windows Auth/Integrated/Trusted.

			$scred = Get-Credential, then pass $scred object to the -SqlCredential parameter.

			Windows Authentication will be used if SqlCredential is not specified. SQL Server does not accept Windows credentials being passed as credentials. To connect as a different Windows user, run PowerShell as that user.

		.PARAMETER Database
			The database(s) to process - this list is auto populated from the server. If unspecified, all databases will be processed.

		.PARAMETER ExcludeDatabase
			The database(s) to exclude - this list is auto populated from the server

		.PARAMETER WhatIf
			Shows what would happen if the command were to run. No actions are actually performed.

		.PARAMETER Confirm
			Prompts you for confirmation before executing any changing operations within the command.

		.PARAMETER Silent
			Use this switch to disable any kind of verbose messages

		.NOTES
			Tags: Migration, Backup
			Original Author: FirstName LastName (@twitterhandle and/or website)

			Website: https://dbatools.io
			Copyright: (C) Chrissy LeMaire, clemaire@gmail.com
			License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0

		.LINK
			https://dbatools.io/Remove-DbaDatabase

		.EXAMPLE
			Remove-DbaDatabase -SqlInstance sql2016 -Database containeddb

			Prompts then removes the database containeddb on SQL Server sql2016

		.EXAMPLE
			Remove-DbaDatabase -SqlInstance sql2016 -ExcludeDatabase mydb, containeddb

			Prompts then removes all the user databases except mydb and containeddb on SQL Server sql2016.

		.EXAMPLE
			Remove-DbaDatabase -SqlInstance sql2016 -Database containeddb, mydb

			Prompts then removes the databases containeddb and mydb on SQL Server sql2016

		.EXAMPLE
			Remove-DbaDatabase -SqlInstance sql2016 -Database containeddb -Confirm:$false

			Does not prompt and swiftly removes containeddb on SQL Server sql2016
	#>
	[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
	param (
		[parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[Alias("ServerInstance", "SqlServer")]
		[DbaInstanceParameter[]]$SqlInstance,
		[parameter(Mandatory = $false)]
		[Alias("Credential")]
		[PSCredential][System.Management.Automation.CredentialAttribute()]
		$SqlCredential,
		[parameter(Mandatory)]
		[object[]]$Database,
		[object[]]$ExcludeDatabase,
		[switch]$Silent
	)

	begin {
		<# include any input validations #>
		<# if you need the validation to stop the function further utilize following example #>
		$exists = Test-Path $InputVariable
		if (!$exists) {
			Stop-Function -Message "Input variable passed in is invalid"
			return
		}
	}
	process {
		if (Test-FunctionInterrupt) { return }

		foreach ($instance in $SqlInstance) {
			try {
				Write-Message -Level Verbose -Message "Connecting to $instance"
				$server = Connect-SqlInstance -SqlInstance $instance -SqlCredential $SqlCredential
			}
			catch {
				Stop-Function -Message "Failed to connect to: $instance" -Continue -Target $instance
			}

			if ($server.MajorVersion -lt 9) {
				Stop-Function -Message "Performing x process is not supported in this version of SQL Server"
				return
			}
			$databases = $server.Databases | Where-Object Name -in $Database
			if ($ExcludeDatabase) {
				$databases = $server.Databases | Where-Object Name -notin $ExcludeDatabase
			}

			foreach ($db in $databases) {
				try {
					if ($Pscmdlet.ShouldProcess("$db on $server", "KillDatabase")) {
						$server.KillDatabase($db.name)
						$server.Refresh()

						[pscustomobject]@{
							ComputerName = $server.NetName
							InstanceName = $server.ServiceName
							SqlInstance = $server.DomainInstanceName
							Database = $db.name
							Status = "Dropped"
						}
					}
				}
				catch {
					try {
						if ($Pscmdlet.ShouldProcess("$db on $server", "alter db set single_user with rollback immediate then drop")) {
							$null = $server.ConnectionContext.ExecuteNonQuery("alter database $db set single_user with rollback immediate; drop database $db")

							[pscustomobject]@{
								ComputerName = $server.NetName
								InstanceName = $server.ServiceName
								SqlInstance = $server.DomainInstanceName
								Database = $db.name
								Status = "Dropped"
							}
						}
					}
					catch {
						try {
							if ($Pscmdlet.ShouldProcess("$db on $server", "SMO drop")) {
								$server.Databases[$dbname].Drop()
								$server.Refresh()

								[pscustomobject]@{
									ComputerName = $server.NetName
									InstanceName = $server.ServiceName
									SqlInstance = $server.DomainInstanceName
									Database = $db.Name
									Status = "Dropped"
								}
							}
						}
						catch {
							Write-Message -Level Verbose -Message "Could not drop database $db on $server"

							[pscustomobject]@{
								ComputerName = $server.NetName
								InstanceName = $server.ServiceName
								SqlInstance = $server.DomainInstanceName
								Database = $db.Name
								Status = $_
							}
						}
					}
				}
			}
		}
	}
	end {
		if (Test-FunctionInterrupt) { return }
		<# any cleanup needed #>
	}
}