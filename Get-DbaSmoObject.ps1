function Get-DbaJobCategory {
<#
    .SYNOPSIS
        Gets SQL Agent Job Category information for each instance(s) of SQL Server.
        
    .DESCRIPTION
        The Get-DbaJobCategory returns connected SMO object for SQL Agent Job Category information for each instance(s) of SQL Server.
        
    .PARAMETER SqlInstance
        SQL Server name or SMO object representing the SQL Server to connect to. This can be a collection and receive pipeline input to allow the function to be executed against multiple SQL Server instances.
        
    .PARAMETER SqlCredential
        Login to the target instance using alternate Windows or SQL Login Authentication. Accepts credential objects (Get-Credential).
        
    .PARAMETER JobCategory
        The job category(ies) to process. This list is auto populated from the server. If unspecified, all job categories will be processed.
        
    .PARAMETER ExcludeJobCategory
        The job category(ies) to exclude. This list is auto populated from the server.
        
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
        https://dbatools.io/Get-DbaJobCategory
        
    .EXAMPLE
        PS C:\> Get-DbaJobCategory -SqlInstance localhost
        
        Returns all SQL Agent Job Categories on the local default SQL Server instance
        
    .EXAMPLE
        PS C:\> Get-DbaJobCategory -SqlInstance localhost, sql2016
        
        Returns all SQL Agent Job Categories for the local and sql2016 SQL Server instances
        
    .EXAMPLE
        PS C:\> $servers = Get-Content C:\servers.txt
        PS C:\> $servers | Get-DbaJobCategory
        
        Returns all SQL Agent Job Categories for the local and sql2016 SQL Server instances
        
#>
    [CmdletBinding()]
    param (
        [parameter(Position = 0, Mandatory, ValueFromPipeline)]
        [Alias("ServerInstance", "SqlServer")]
        [DbaInstance[]]$SqlInstance,
        [Alias("Credential")]
        [PSCredential]$SqlCredential,
        [string[]]$JobCategory,
        [string[]]$ExcludeJobCategory,
        [Alias('Silent')]
        [switch]$EnableException
    )
    process {
        foreach ($instance in $SqlInstance) {
            Write-Message -Level Verbose -Message "Attempting to connect to $instance"

            try {
                $server = Connect-SqlInstance -SqlInstance $instance -SqlCredential $SqlCredential
            }
            catch {
                Stop-Function -Message "Failure" -Category ConnectionError -ErrorRecord $_ -Target $instance -Continue
            }

            $categories = $server.JobServer.JobCategory

            if ($JobCategory) {
                $categories = $categories | Where-Object Name -in $JobCategory
            }
            if ($ExcludeJobCategory) {
                $categories = $categories | Where-Object Name -notin $ExcludeJobCategory
            }

            foreach ($object in $categories) {
                Write-Message -Level Verbose -Message "Processing $object"
                Add-Member -Force -InputObject $object -MemberType NoteProperty ComputerName -value $server.ComputerName
                Add-Member -Force -InputObject $object -MemberType NoteProperty InstanceName -value $server.ServiceName
                Add-Member -Force -InputObject $object -MemberType NoteProperty SqlInstance -value $server.DomainInstanceName

                # Select all of the columns you'd like to show
                Select-DefaultView -InputObject $object -Property ComputerName, InstanceName, SqlInstance, ID, Name, Whatever, Whatever2
            }
        }
    }
}