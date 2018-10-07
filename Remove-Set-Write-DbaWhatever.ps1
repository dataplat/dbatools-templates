function Remove-DbaDatabase {
    <#
        .SYNOPSIS
            Drops a database, hopefully even the really stuck ones.

        .DESCRIPTION
            Tries a bunch of different ways to remove a database or two or more.

        .PARAMETER SqlInstance
            The SQL Server instance holding the databases to be removed.You must have sysadmin access and server version must be SQL Server version 2000 or higher.

        .PARAMETER SqlCredential
            Login to the target instance using alternate Windows or SQL Login Authentication. Accepts credential objects (Get-Credential).

        .PARAMETER Database
            The database(s) to process. This list is auto-populated from the server. If unspecified, all databases will be processed.

        .PARAMETER ExcludeDatabase
            The database(s) to exclude - this list is auto-populated from the server.

        .PARAMETER WhatIf
            If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

        .PARAMETER Confirm
            If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

        .PARAMETER EnableException
            By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
            This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
            Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

        .NOTES
            Tags: Migration, Backup
            Author: FirstName LastName (@twitterhandle and/or website)

            Website: https://dbatools.io
            Copyright: (c) 2018 by dbatools, licensed under MIT
            -           License: MIT https://opensource.org/licenses/MIT

        .LINK
            https://dbatools.io/Remove-DbaDatabase

        .EXAMPLE
            PS C:\> Remove-DbaDatabase -SqlInstance sql2016 -Database containeddb

            Prompts then removes the database containeddb on SQL Server sql2016

        .EXAMPLE
            PS C:\> Remove-DbaDatabase -SqlInstance sql2016 -ExcludeDatabase mydb, containeddb

            Prompts then removes all the user databases except mydb and containeddb on SQL Server sql2016.

        .EXAMPLE
            PS C:\> Remove-DbaDatabase -SqlInstance sql2016 -Database containeddb, mydb

            Prompts then removes the databases containeddb and mydb on SQL Server sql2016

        .EXAMPLE
            PS C:\> Remove-DbaDatabase -SqlInstance sql2016 -Database containeddb -Confirm:$false

            Does not prompt and swiftly removes containeddb on SQL Server sql2016

    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Alias("ServerInstance", "SqlServer")]
        [DbaInstance[]]$SqlInstance,
        [Alias("Credential")]
        [PSCredential]$SqlCredential,
        [parameter(Mandatory)]
        [object[]]$Database,
        [object[]]$ExcludeDatabase,
        [switch]$EnableException
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
                Stop-Function -Message "Failure" -Category ConnectionError -ErrorRecord $_ -Target $instance -Continue
            }

            if ($server.VersionMajor -lt 9) {
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
                            SqlInstance  = $server.DomainInstanceName
                            Database     = $db.name
                            Status       = "Dropped"
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
                                SqlInstance  = $server.DomainInstanceName
                                Database     = $db.name
                                Status       = "Dropped"
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
                                    SqlInstance  = $server.DomainInstanceName
                                    Database     = $db.Name
                                    Status       = "Dropped"
                                }
                            }
                        }
                        catch {
                            Write-Message -Level Verbose -Message "Could not drop database $db on $server"

                            [pscustomobject]@{
                                ComputerName = $server.NetName
                                InstanceName = $server.ServiceName
                                SqlInstance  = $server.DomainInstanceName
                                Database     = $db.Name
                                Status       = $_
                            }
                        }
                    }
                }
            }
        }
    }
}
