<#
.SYNOPSIS
    This will export info on 20 randomly selected AD users to an html
    file located on the desktop of the user running it.
     
    It will provide the username, department, title, last logon time,
    last password change and account enabled / lockout status sorted by user.
 
    ***Notes***
    It will import the AD module in order to use Get-ADUser.
    Please change the SearchBase for your own domain / specific ou.
.DESCRIPTION
    This was written for Event 4 of the 2013 Scripting Games (Beginner).
.EXAMPLE
    .\UserAudit.ps1  
#>
 
$head = @"
<title>Active Directory Audit</title>
<style>
body {
font-family:Georgia, Arial, Helvetica, sans-serif;
}
table {
width:100%;
border-collapse:collapse;
}
td, th {
border:1px solid #98bf21;
padding:3px 7px 2px 7px;
}
th {
font-size:1.2em;
text-align:left;
padding-top:5px;
padding-bottom:4px;
background-color:#A7C942;
color:#ffffff;
}
td {
font-size:1.0em;
color:#000000;
background-color:#EAF2D3;
}
</style>
"@
$pre = "<H2><center>Active Directory Audit</center></H2>"
$post = @"
<br/>
Report Generated: $(Get-Date) by $env:username
"@
$path = "$env:userprofile\desktop\UserAudit.html"
$properties = "sAMAccountName", "Department", "Title", "lastLogonDate", "PasswordLastSet", "Enabled", "LockedOut"
 
Import-Module ActiveDirectory
Get-Random (Get-ADUser -Filter * -SearchBase "dc=tine,dc=no" -Properties $properties) -Count 20 |
    Select-Object @{name="User Name";expression={$_.sAMAccountName}},
        @{name="Department";expression={$_.Department}},
        @{name="Title";expression={$_.Title}},
        @{name="Last Logon";expression={$_.lastLogonDate}},
        @{name="Password Last Changed";expression={$_.PasswordLastSet}},
        @{name="Account Enabled";expression={$_.Enabled}},
        @{name="Account Locked Out";expression={$_.LockedOut}} |
    Sort-Object "User Name" | 
    ConvertTo-HTML -head $head -PreContent $pre -PostContent $post |
    Out-File -FilePath $path -Force