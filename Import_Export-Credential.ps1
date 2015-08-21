Function Export-Credential
{
param
(
$Credential,
$Path
)
$Credential = $Credential | Select-Object *
$Credential.Password = $Credential.Password | ConvertFrom-SecureString
$Credential | Export-Clixml $Path
}
Function Import-Credential
{
param
(
$Path
)
$Credential = Import-Clixml $Path
$Credential.Password = $Credential.Password | ConvertTo-SecureString
New-Object System.Management.Automation.PSCredential($Credential.UserName, $Credential.Password)
}

#Export-Credential can save a credential to XML:
#Export-Credential (Get-Credential) $env:temp\cred.xml
#$cred = Import-Credential -Path $env:temp\cred.xml
#Get-WmiObject Win32_BIOS -ComputerName storage1 -Credential $cred
#Note that your password is encrypted and can only be imported by the same user that exported it.