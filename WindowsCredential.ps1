# Sample Retrieve All Windows Credential
[void][Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]
(new-object Windows.Security.Credentials.PasswordVault).RetrieveAll() | % { $_.RetrievePassword(); $_ }

# Set Credential
[void][Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]
$credential = New-Object Windows.Security.Credentials.PasswordCredential -ArgumentList ("hoge", "user", "password")
(New-Object Windows.Security.Credentials.PasswordVault).Add($credential)

# Get by Resource Name (if you are not sure about resource username.)
(New-Object Windows.Security.Credentials.PasswordVault).FindAllByResource("hoge") | %{$_.RetrievePassword(); $_ }

# Convert PSCredential to WindowsCredential
function ConvertTo-PasswordCredential
{
    param
    (
        [parameter(Mandatory = 1, Position = 0)]
        [PSCredential]$Credential,

        [parameter(Mandatory = 1, Position = 1)]
        [string]$ResourceName
    )

    [void][Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]
    $winCred = New-Object Windows.Security.Credentials.PasswordCredential -ArgumentList ($ResourceName, $Credential.UserName, $Credential.GetNetworkCredential().Password)

    return $winCred
}

# Test
ConvertTo-PasswordCredential -Credential (Get-Credential) -ResourceName hoge