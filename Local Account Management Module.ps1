# ------------------------------------------------------------------
# Title: Local Account Management Module
# Author: Raimund Andree [MSFT]
# Description: Version 1.01 released on November 27 2011 IntroductionThis module allows managing local groups and user accounts, local group memberhip and some other useful tasks. It is based on the ADSI interface and some classes written in C# that are also attached.All cmdlets suport the pipl
# Date Published: 11/2/2011 1:00:42 AM
# Source: http://gallery.technet.microsoft.com/scriptcenter/Local-Account-Management-a777191b
# Tags: Group Membership;Local Security;Users and Groups
# Rating: 4.89285714285714 rated by 28
# ------------------------------------------------------------------

$testUsers = 1..10 | ForEach-Object { New-LocalUser -Name ("Test_{0:00}" -f $_) -Password ("Test_{0:00}" -f $_) -Description Testing }
$testGroup = New-LocalGroup -Name TestGroup1 -Description Testing -PassThru

$testGroup | Add-LocalGroupMembership -Members $testUsers