function Test-Noun {
    <#
        .SYNOPSIS
            Tests Noun on a computer.

        .DESCRIPTION
            Longer description of the test(s) and how they're run.

        .PARAMETER ComputerName
            The target computer to test against. Defaults to localhost.

            NOTE: Function should use this parameter or SqlInstance. Select the appropriate parameter and corresponding help content, and remove the unused one.

        .PARAMETER SqlInstance
            The target SQL Server instance to test against. Defaults to the default instance on localhost.

            NOTE: Function should use this parameter or ComputerName. Select the appropriate parameter and corresponding help content, and remove the unused one.

        .PARAMETER Force
            If this switch is enabled, the Alert will be dropped and recreated on Destination.

        .PARAMETER EnableException
            By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
            This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
            Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

        .NOTES
            Tags: TAGS_HERE 
            Author: Your name (@TwitterHandle)

            Website: https://dbatools.io
            Copyright: (C) Chrissy LeMaire, clemaire@gmail.com
            License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0

        .LINK
            https://dbatools.io/Test-Noun

        .EXAMPLE
            Test-Noun -ComputerName sql2014

            Performs a test of Noun against the computer sql2014.

    #>
}