function Get-DbaIdentityUsage {
    <#
        .SYNOPSIS
            Displays information relating to IDENTITY seed usage.  Works on SQL Server 2008 and above.

        .DESCRIPTION
            IDENTITY seeds have max values based off of their data type.  This module will locate identity columns and report the seed usage.

        .PARAMETER SqlInstance
            Allows you to specify a comma separated list of servers to query.

        .PARAMETER SqlCredential
            Login to the target instance using alternate Windows or SQL Login Authentication. Accepts credential objects (Get-Credential).

        .PARAMETER Database
            The database(s) to process - this list is auto-populated from the server. If unspecified, all databases will be processed.

        .PARAMETER ExcludeDatabase
            The database(s) to exclude - this list is auto-populated from the server

        .PARAMETER Threshold
            Allows you to specify a minimum % of the seed range being utilized.  This can be used to ignore seeds that have only utilized a small fraction of the range.

        .PARAMETER ExcludeSystemDatabase
            Allows you to suppress output on system databases

        .PARAMETER EnableException
            By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
            This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
            Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

        .NOTES
            Author: You, YourTwitterOrBlog
            Tags: Identity

            Website: https://dbatools.io
            Copyright: (c) 2018 by dbatools, licensed under MIT
-           License: MIT https://opensource.org/licenses/MIT

        .LINK
            https://dbatools.io/Get-DbaIdentityUsage

        .EXAMPLE
            Get-DbaIdentityUsage -SqlInstance sql2008, sqlserver2012
            Check identity seeds for servers sql2008 and sqlserver2012.

        .EXAMPLE
            Get-DbaIdentityUsage -SqlInstance sql2008 -Database TestDB
            Check identity seeds on server sql2008 for only the TestDB database

        .EXAMPLE
            Get-DbaIdentityUsage -SqlInstance sql2008 -Database TestDB -Threshold 20
            Check identity seeds on server sql2008 for only the TestDB database, limiting results to 20% utilization of seed range or higher
        #>
    [CmdletBinding()]
    Param (
        [parameter(Position = 0, Mandatory, ValueFromPipeline)]
        [Alias("ServerInstance", "SqlServer", "SqlServers")]
        [DbaInstanceParameter[]]$SqlInstance,
        [PSCredential]$SqlCredential,
        [Alias("Databases")]
        [string[]]$Database,
        [string[]]$ExcludeDatabase,
        [parameter(Position = 1, Mandatory = $false)]
        [int]$Threshold = 0,
        [parameter(Position = 2, Mandatory = $false)]
        [switch]$ExcludeSystemDatabase,
        [switch]$EnableException
    )

    begin {

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

                foreach ($row in $db.Query($sql)) {
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

