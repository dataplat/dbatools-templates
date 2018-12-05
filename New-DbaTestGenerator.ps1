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
        $paramCount = x
        $defaultParamCount = x
        [object[]]$params = (Get-ChildItem function:\Verb-DbaXyz).Parameters.Keys
        $knownParameters = 'Computer', 'SqlInstance', 'SqlCredential', 'Credential', 'EnableException'
        It "Should contain our specific parameters" {
            ( (Compare-Object -ReferenceObject $knownParameters -DifferenceObject $params -IncludeEqual | Where-Object SideIndicator -eq "==").Count ) | Should Be $paramCount
        }
        It "Should only contain $paramCount parameters" {
            $params.Count - $defaultParamCount | Should Be $paramCount
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

            $currentTest = $currentTest.Replace('$paramCount = x', "`$paramCount = $($currentcmdletparameters.count)")


            if ($currentcmdlet.Parameters.keys.Contains('WhatIf')) {
                $currentTest = $currentTest.Replace('$defaultParamCount = x', '$defaultParamCount = 13')
            }
            else {
                $currentTest = $currentTest.Replace('$defaultParamCount = x', '$defaultParamCount = 11')
            }

            $currentTest = $currentTest.Replace('Verb-DbaXyz', "$($t.inputobject)")
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