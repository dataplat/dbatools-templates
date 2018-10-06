function Remove-Noun {
    <#
        .SYNOPSIS
            Removes a Noun from the SQL Server instance

        .DESCRIPTION
            Longer description of what Remove-Noun does.

        .PARAMETER SqlInstance
            The SQL Server instance. Server version must be SQL Server version XXXX or higher.

        .PARAMETER SqlCredential
           Login to the target instance using alternative credentials. Windows and SQL Authentication supported. Accepts credential objects (Get-Credential)

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
-           License: MIT https://opensource.org/licenses/MIT

        .LINK
            https://dbatools.io/Remove-Noun

        .EXAMPLE
            Remove-Noun -SqlInstance sqlserver2014

            Removes the Noun from the SQL Server instance sqlserver2014.
    #>
}
