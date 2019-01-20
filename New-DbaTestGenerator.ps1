function New-DbaTestGenerator {
    <#
    .SYNOPSIS
        Creates a new Pester Test for new cmdlets without exisiting tests

    .DESCRIPTION
        Creates a new Pester Test for new cmdlets without exisiting tests

        Uses a sample test as the format, but will also append tests as well if desired

   .PARAMETER DevelopmentPath
        The Path to the location of your local GitHub branch of dbatools


    .NOTES
        Tags: Tests, Pester
        Author: Joshua Corrick (@joshcorr), corrick.io
        Website: https://dbatools.io
        Copyright: (c) 2018 by dbatools, licensed under MIT
        License: MIT https://opensource.org/licenses/MIT

    .LINK
        https://dbatools.io/New-DbaTestGenerator

    .EXAMPLE
        PS C:\GitHub\> . .\dbatools-templates\New-DbaTestGenerator.ps1
        PS C:\GitHub\> New-DbaTestGenerator -DevelopmentPath .\dbatools\

        Creates Unit Tests for all named parameters in the files found

    #>

    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string]$DevelopmentPath
    )

    begin {
        $functions = Get-ChildItem $DevelopmentPath\functions\ -Recurse -Include *.ps1
        $tests = Get-ChildItem $DevelopmentPath\tests\ -Recurse -Include *.ps1
        $null = Import-Module $DevelopmentPath\dbatools.psd1
        $commonParameters = @('Debug', 'ErrorAction', 'ErrorVariable', 'InformationAction', 'InformationVariable', 'OutVariable', 'OutBuffer', 'PipelineVariable', 'Verbose', 'WarningAction', 'WarningVariable', 'Whatif', 'Confirm')

        $sampleTest = @'
$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandPath" -ForegroundColor Cyan
. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        [object[]]$params = (Get-Command $CommandName).Parameters.Keys | Where-Object {$_ -notin ('whatif', 'confirm')}
        [object[]]$knownParameters = 'Computer', 'SqlInstance', 'SqlCredential', 'Credential', 'EnableException'
        $knownParameters += [System.Management.Automation.PSCmdlet]::CommonParameters
        It "Should only contain our specific parameters" {
            (@(Compare-Object -ReferenceObject ($knownParameters | Where-Object {$_}) -DifferenceObject $params).Count ) | Should Be 0
        }
    }
}
<#
    Integration test are custom to the command you are writing for.
    Read https://github.com/sqlcollaborative/dbatools/blob/development/contributing.md#tests
    for more guidence
#>
'@

        $NoTests = (Compare-Object $functions.basename $tests.basename.replace('.Tests', '')).Where( {$_.SideIndicator -eq '<='})

    }
    process {
        foreach ($t in $NoTests) {

            try{
                $currentcmdlet = Get-command -Name $($t.inputobject) -ErrorAction stop

            if (Test-Path $DevelopmentPath\tests\$($t.inputobject).Tests.ps1 ) {
                $currentTestFile = Get-Content -Path $DevelopmentPath\tests\$($t.inputobject).Tests.ps1
            }
            $currentTest = $sampleTest
            $currentcmdletparameters = $currentcmdlet.Parameters.Keys.Where( {$_ -notin $commonParameters})
            $currentTest = $currentTest.Replace("`$knownParameters = 'Computer', 'SqlInstance', 'SqlCredential', 'Credential', 'EnableException'", "`$knownParameters = '$($currentcmdletparameters -join ''',''')'")

            if ($currentFile) {
                Out-File -InputObject $currentTestFile -FilePath $DevelopmentPath\tests\$($t.inputobject).Tests.ps1 -Encoding utf8 -Append
            }
            else {
                Out-File -InputObject $currentTest -FilePath $DevelopmentPath\tests\$($t.inputobject).Tests.ps1 -Encoding utf8
            }
            }
            catch{
                Write-Error "Cmdlet $($t.inputobject) is not globally accessable"
            }
        }
    }
}