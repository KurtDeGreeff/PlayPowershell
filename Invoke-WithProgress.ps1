function Main
{
    $ErrorActionPreference = "Stop"

    Invoke-WithProgress -Activity "Test" -Action {
        foreach ($i in 1..100)
        {
            $progress.UpdateProgress($i)
            sleep -Milliseconds 10
        }
    }
    #Automatically call Write-Progress -Completed
}

function Invoke-WithProgress
{
    [CmdletBinding(RemotingCapability = 'None')]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string] $Activity,
        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string] $Status,
        [Parameter(Position = 2)]
        [ValidateRange(0, 2147483647)]
        [int] $Id,
        [ValidateRange(-1, 100)]
        [int] $PercentComplete,
        [int] $SecondsRemaining,
        [string] $CurrentOperation,
        [ValidateRange(-1, 2147483647)]
        [int] $ParentId,
        #[switch] $Completed,
        [int] $SourceId,
        [Parameter(Mandatory)]
        [ScriptBlock] $Action
    )

    #TODO:Should be private variable, but it need to be used inside Add-Member block 
    $__params = $PSBoundParameters
    $__params.Remove("Action") > $null
    
    #$progress Automatic variable used in action block
    $progress = [pscustomobject] @{}

    $progress | Add-Member -Name UpdateProgress -MemberType ScriptMethod -Value {
        param ([int] $PercentComplete)
        Write-Progress @$__params -PercentComplete $i
    }

    Write-Progress @__params
    & $action
    Write-Progress @__params -Completed

}

. Main
