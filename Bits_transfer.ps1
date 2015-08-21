Import-module BitsTransfer

$mapping = "\\10.5.21.173\D$"

#Ask for Credentials to connect to remote PC/Server
$cred = Get-Credential

#Map Network Drive
Test
New-PSDrive -Name W2K8 -Root $mapping -PSProvider FileSystem -Credential $cred

#Source & Destination paths, change if applicable
$source = "W2K8:\boot.wim"
$Destination = "c:\tmp"

if (-Not(Test-Path $Destination))
{
    $null = New-Item -Path $Destination -ItemType Directory
}

#Initiate Transfer
Start-BitsTransfer -Credential $cred -Source $source -Destination $Destination -Description "MDT Transfer" -DisplayName "MDT"

