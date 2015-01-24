<#
    .Synopsis 
        Adds a user or group to local administrator group
 
    .Description
        This scripts adds the given user or group to local administrators group on given list of servers.
 
    .Parameter ComputerName
        Computer Name(s) on which you want to add user/group to local administrators
 
    .Parameter ObjectType
        This parameter takes either of two values, User or Group. This parameter indicates the type of object
        you want to add to local administrators
 
    .Parameter ObjectName
        Name of the object (user or group) which you want to add to local administrators group. This should be in 
        Domain\UserName or Domain\GroupName format
 
    .Example
        Set-LocalAdminGroupMembers.ps1 -ObjectType User -ObjectName "AD\TestUser1" -ComputerName srvmem1, srvmem2 
 
        Adds AD\TestUser1 user account to local administrators group on srvmem1 and srvmeme2
 
    .Example
        Set-LocalAdminGroupMembers.ps1 -ObjectType Group -ObjectName "ADDomain\AllUsers" -ComputerName (Get-Content c:\servers.txt) 
 
        Adds AD\TestUser1 Group to local administrators group on servers listed in c:\servers.txt
    .Notes

 
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true,Position=1)]
    [ValidateSet("User","Group")]
    [String]
    $ObjectType,
 
    [Parameter(Mandatory=$true,Position=2)]
    [ValidateScript({($_.split("\").count -eq 2)})]
    [string]$ObjectName,
 
    [Parameter(Position=3)]
    [String[]]$ComputerName=$env:COMPUTERNAME
)
 
#Name and location of the output file. Change this line if you want to alter the location
$ResultsFile = "c:\temp\ResultsofLocalGroupAddition.csv"
$ObjDomain = $ObjectName.Split("\")[0]
$ObjName = $ObjectName.Split("\")[1]
$ComputerCount = $ComputerName.Count
$count = 0
Add-Content -Path $ResultsFile -Value "ComputerName,Status,Comments"
foreach($Computer in $ComputerName) {
    $count++
    $Status=$null
    $Comment = $null
    Write-Host ("{0}. Working on {1}" -f $Count, $Computer)
    if(Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
        Write-Verbose "$Computer : Online"
        try {
            $GroupObj = [ADSI]"WinNT://$Computer/Administrators"
            $GroupObj.Add("WinNT://$ObjDomain/$ObjName")
            $Status = "Success"
            $Comment = "Added $ObjectName $ObjectType to Local administrators group"
            Write-Verbose "Successfully added $ObjectName $ObjectType to $Computer"
        } catch {
            $Status = "Failed"
            $Comment = $_.toString().replace("`n","").replace("`r","")
            Write-Verbose "Failed to add $ObjectName $ObjectType to $Computer"
        }
 
        Add-Content -Path $ResultsFile -Value ("{0},{1},{2}" -f $Computer,$Status,$Comment )    
 
    } else {
        Write-Warning "$Computer : Offline"
        Add-Content -Path $ResultsFile -Value ("{0},{1}" -f $Computer,"Offline")
    }
 
}