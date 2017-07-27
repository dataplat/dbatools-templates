#Thank you Warren http://ramblingcookiemonster.github.io/Testing-DSC-with-Pester-and-AppVeyor/

# For the developer, leave the above thanks in. Remove this and an important thing to note
# we have two instances that appveyor tests against localhost (sql2008r2) and localhost\sql2016
# the appveyor-lab is used to build sample objects that can be tested, talk to Chrissy
Describe "Get-DbaDatabase Integration Tests" -Tags "Integrationtests" {

    Context "Count system database on localhost" {
        $results = Get-DbaDatabase -SqlInstance localhost -NoUserDb 
        It "Should report the right number of database" {
            $results.Count | Should Be 4
        }
    }

    Context "Check that master database is in FULL recovery mode" {
            $results = Get-DbaDatabase -SqlInstance localhost -Database master
            It "Should say the recovery mode of master is Full" {
                $results.RecoveryModel | Should Be "Full"
            }
        }
}