function Test-DbaIdentityUsage {
	<# 
	.SYNOPSIS 
		Displays information relating to IDENTITY seed usage.  Works on SQL Server 2008 and above.

	.DESCRIPTION 
		IDENTITY seeds have max values based off of their data type.  This module will locate identity columns and report the seed usage.

	.PARAMETER SqlInstance
		Allows you to specify a comma separated list of servers to query.

	.PARAMETER SqlCredential
		Allows you to login to servers using SQL Logins as opposed to Windows Auth/Integrated/Trusted. To use:
		$cred = Get-Credential, this pass this $cred to the param. 

		Windows Authentication will be used if DestinationSqlCredential is not specified. To connect as a different Windows user, run PowerShell as that user.	

	.PARAMETER Database
		The database(s) to process - this list is auto-populated from the server. If unspecified, all databases will be processed.

	.PARAMETER ExcludeDatabase
		The database(s) to exclude - this list is auto-populated from the server

	.PARAMETER Threshold
		Allows you to specify a minimum % of the seed range being utilized.  This can be used to ignore seeds that have only utilized a small fraction of the range.

	.PARAMETER ExcludeSystemDatabase
		Allows you to suppress output on system databases

	.PARAMETER Silent 
		Use this switch to disable any kind of verbose messages (this is required)

	.NOTES 
		Author: You, YourTwitterOrBlog
		Tags: Identity

		Website: https://dbatools.io
		Copyright: (C) Chrissy LeMaire, clemaire@gmail.com
		License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0

	.LINK 
		https://dbatools.io/Test-DbaIdentityUsage

	.EXAMPLE   
		Test-DbaIdentityUsage -SqlInstance sql2008, sqlserver2012
		Check identity seeds for servers sql2008 and sqlserver2012.

	.EXAMPLE   
		Test-DbaIdentityUsage -SqlInstance sql2008 -Database TestDB
		Check identity seeds on server sql2008 for only the TestDB database

	.EXAMPLE   
		Test-DbaIdentityUsage -SqlInstance sql2008 -Database TestDB -Threshold 20
		Check identity seeds on server sql2008 for only the TestDB database, limiting results to 20% utilization of seed range or higher
	#>
	[CmdletBinding()]
	Param (
		[parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $True)]
		[Alias("ServerInstance", "SqlServer", "SqlServers")]
		[DbaInstanceParameter[]]$SqlInstance,
		[PSCredential]
		$SqlCredential,
		[Alias("Databases")]
		[object[]]$Database,
		[object[]]$ExcludeDatabase,
		[parameter(Position = 1, Mandatory = $false)]
		[int]$Threshold = 0,
		[parameter(Position = 2, Mandatory = $false)]
		[switch]$ExcludeSystemDatabase,
		[switch]$Silent
	)

	BEGIN {
		
		 $sql = "SELECT  SERVERPROPERTY('MachineName') AS ComputerName,
        ISNULL(SERVERPROPERTY('InstanceName'), 'MSSQLSERVER') AS InstanceName,
        SERVERPROPERTY('ServerName') AS SqlInstance, etc etc from whatever"

		if ($Threshold -gt 0) { 
			$sql += " WHERE [PercentUsed] >= " + $Threshold + " ORDER BY [PercentUsed] DESC" 
		}
		else { 
			$sql += " ORDER BY [PercentUsed] DESC" 
		}
	}

	process {
		foreach ($instance in $SqlInstance) {
			Write-Message -Level Verbose -Message "Attempting to connect to $instance"
			
			try {
				$server = Connect-SqlInstance -SqlInstance $instance -SqlCredential $SqlCredential -MinimumVersion 10
			}
			catch {
				Stop-Function -Message "Failure" -Category ConnectionError -ErrorRecord $_ -Target $instance -Continue
			}
			
			$dbs = $server.Databases
			
			if ($Database) {
				$dbs = $dbs | Where-Object {$Database -contains $_.Name}
			}
			
			if ($ExcludeDatabase) {
				$dbs = $dbs | Where-Object Name -NotIn $ExcludeDatabase
			}
			
			if ($ExcludeSystemDatabase) {
				$dbs = $dbs | Where-Object IsSystemObject -eq $false
			}
			
			foreach ($db in $dbs) {
				Write-Message -Level Verbose -Message "Processing $db on $instance"
				
				if ($db.IsAccessible -eq $false) {
					Stop-Function -Message "The database $db is not accessible. Skipping database." -Continue
				}
				
				foreach ($row in $db.ExecuteWithResults($sql).Tables[0]) {
					if ($row.PercentUsed -eq [System.DBNull]::Value) {
						continue
					}
					
					if ($row.PercentUsed -ge $threshold) {
						[PSCustomObject]@{
							ComputerName   = $server.NetName
							InstanceName   = $server.ServiceName
							SqlInstance    = $server.DomainInstanceName
							Database       = $row.DatabaseName
							Schema         = $row.SchemaName
							Table          = $row.TableName
							Column         = $row.ColumnName
							SeedValue      = $row.SeedValue
							IncrementValue = $row.IncrementValue
							LastValue      = $row.LastValue
							MaxNumberRows  = $row.MaxNumberRows
							NumberOfUses   = $row.NumberOfUses
							PercentUsed    = $row.PercentUsed
						}
					}
				}
			}
		}
	}
}

