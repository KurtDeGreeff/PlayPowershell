function Get-StoredCredential
{
    [CmdletBinding()]
    Param
    (
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        $Credential,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Alias('DomainName')]
        [String]$ComputerName,

        $CachePath = "$Env:APPDATA\StoredCredentials.xml"
    )

    Begin
    {
        # Side note: in PSv3 these functions are not needed since 
        # Export-Clixml/Import-Clixml will do this for you

        function Serialize-Credential
        {
	        param ($Credential)

            New-Object PSObject -Property @{
                UserName = $Credential.UserName
                EncryptedPassword = ConvertFrom-SecureString $Credential.Password
            }
        }

        function Deserialize-Credential
        {
	        param ($CachedCredential)

	        $SecurePassword = ConvertTo-SecureString $CachedCredential.EncryptedPassword
            New-Object PSCredential $CachedCredential.Username, $SecurePassword
        }

        [bool]$CacheIsChanged = $false
        try
        {
            # Load the password cache
            $PasswordCache = Import-Clixml $CachePath
        }
        catch
        {
            # Create a new one if it does not exist
            $PasswordCache = @{}
        }
    }

    Process
    {
        if ($Credential -Is [String])
        {
            # If the Credential is blank substitute an empty (default) credential
            if ($Credential -eq '')
            {
                $Credential = [PSCredential]::Empty
            }
            else
            {
                try
                {
                    # Load credential from password cache
                    $Credential = Deserialize-Credential $PasswordCache.$Credential
                }
                catch
                {
                    # Credential not found: prompt for it and store in the cache
                    $SaveCredential = Get-Credential $Credential -Message "This credential will be saved as ${Credential}:"
                    if ($SaveCredential)
                    {
                        $PasswordCache.$Credential = Serialize-Credential $SaveCredential 
                        $Credential = $SaveCredential
                        $CacheIsChanged = $true
                    }
                }
                # Use ComputerName as domain name if no domain specified
                if ($ComputerName -and -not ($Credential.UserName -match '\\'))
                {
                    $Credential = New-Object PSCredential "$ComputerName\$($Credential.UserName)", $Credential.Password
                }
            }
            # Substitute the saved credential on the pipeline object
            if ($_)
            {
                $_.Credential = $Credential
            }
        }
        if ($_)
        {
            $_
        }
        else
        {
            $Credential
        }
    }

    End
    {
        # Save the password cache
        if ($CacheIsChanged)
        {
            $PasswordCache | Export-Clixml $CachePath
        }
    }
}