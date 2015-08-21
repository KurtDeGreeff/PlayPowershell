function InitializeWindowsCredential
{
    Write-Verbose ("Loading PasswordVault Class.")
    [void][Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]
}

InitializeWindowsCredential

function ConvertTo-PasswordCredential
{
<#
.Synopsis
   Convert PSCredential to WindowsCredential
.DESCRIPTION
   WindowsCredential class should use PasswordVault thus PSCredential converter is required.
   This function will convert PSCredential to PasswordCredential Class.
.EXAMPLE
   ConvertTo-PasswordCredential -Credential (Get-Credential) -ResourceName hoge
#>

    [OutputType([Windows.Security.Credentials.PasswordCredential])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = 1, Position = 0, ValueFromPipeline = 1, ValueFromPipelineByPropertyName = 1)]
        [PSCredential[]]$Credential,

        [parameter(Mandatory = 1, Position = 1)]
        [string]$ResourceName
    )

    process
    {
        foreach ($item in $Credential)
        {
            Write-Verbose ("Converting PSCredential to WindowsCredential")
            New-Object Windows.Security.Credentials.PasswordCredential -ArgumentList ($ResourceName, $item.UserName, $item.GetNetworkCredential().Password)
        }
    }
}

function ConvertFrom-PasswordCredential
{
<#
.Synopsis
   Convert WindowsCredential to PSCredential
.DESCRIPTION
   WindowsCredential class should use PasswordVault thus PSCredential converter is required.
   This function will convert PasswordCredential Class to PSCredential.
.EXAMPLE
   ConvertFrom-PasswordCredential -Credential $Credential
#>

    [OutputType([PSCredential])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = 1, Position = 0, ValueFromPipeline = 1, ValueFromPipelineByPropertyName = 1)]
        [Windows.Security.Credentials.PasswordCredential[]]$Credential
    )

    process
    {
        foreach ($item in $Credential)
        {
            Write-Verbose ("Converting WindowsCredential to PSCredential")
            if ($item.UserName -eq [string]::Empty){ throw New-Object System.NullReferenceException }
            New-Object System.Management.Automation.PSCredential -ArgumentList ($item.UserName, (ConvertTo-SecureString $item.Password -AsPlainText -Force))
        }
    }
}

function Get-WindowsCredential
{
<#
.Synopsis
   Get PSCredential from Windows Credential Vault
.DESCRIPTION
   Retrieve Credential from Windows Credential Vault and return as PSCredential
.EXAMPLE
   Get-WindowsCredential -ResourceName hoge
.EXAMPLE
   Get-WindowsCredential -ResourceName hoge -UserName username
.EXAMPLE
   Get-WindowsCredential -ResourceName hoge -UserName username, fuga
.EXAMPLE
   Get-WindowsCredential -All
#>
    [OutputType([PSCredential])]
    [CmdletBinding(DefaultParameterSetName = "Specific")]
    param
    (
        [parameter(Mandatory = 1, Position = 0, ParameterSetName = "Specific")]
        [string]$ResourceName,

        [parameter(Mandatory = 0, Position = 1, ValueFromPipeline = 1, ValueFromPipelineByPropertyName = 1, ParameterSetName = "Specific")]
        [string[]]$UserName = [string]::Empty,

        [parameter(Mandatory = 0, Position = 0, ValueFromPipeline = 1, ValueFromPipelineByPropertyName = 1, ParameterSetName = "All")]
        [switch]$All
    )
    
    process
    {
        try
        {
            if ($All)
            {
                (New-Object Windows.Security.Credentials.PasswordVault).RetrieveAll() | % { $_.RetrievePassword(); $_ } | ConvertFrom-PasswordCredential
                return;
            }

            foreach ($item in $UserName)
            {
                if ($item -ne [string]::Empty)
                {
                    Write-Verbose ("Retrieving WindowsCredential from ResourceName : '{0}', UserName : '{1}'" -f $ResourceName, $item)
                    (New-Object Windows.Security.Credentials.PasswordVault).Retrieve($ResourceName, $item) | % { $_.RetrievePassword(); $_ } | ConvertFrom-PasswordCredential
                }
                else
                {
                    Write-Verbose ("Retrieving All Windows Credential for ResourceName : '{0}'" -f $ResourceName)
                    (New-Object Windows.Security.Credentials.PasswordVault).FindAllByResource($ResourceName) | % { $_.RetrievePassword(); $_ } | ConvertFrom-PasswordCredential
                    return;
                }
            }
        }
        catch
        {
            throw $_
        }
    }
}

function Set-WindowsCredential
{
<#
.Synopsis
   Set to Windows Credential Vault with specific ResourceName
.DESCRIPTION
   This function will store your PSCredential to Password Vault.
.EXAMPLE
    Set-WindowsCredential -ResourceName hoge -Credential (Get-Credential)
.EXAMPLE
    Set-WindowsCredential -ResourceName hoge -Credential (Get-Credential), (Get-Credential)
#>
    [OutputType([Void])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = 1, Position = 0)]
        [string]$ResourceName,

        [parameter(Mandatory = 1, Position = 1, ValueFromPipeline = 1, ValueFromPipelineByPropertyName = 1)]
        [PSCredential[]]$Credential
    )
    
    process
    {
        try
        {
            foreach ($item in $Credential)
            {
                Write-Verbose ("Set Windows Credential for UserName : '{0}'" -f $item.UserName)
                $winCred = $item | ConvertTo-PasswordCredential -ResourceName $ResourceName
                (New-Object Windows.Security.Credentials.PasswordVault).Add($winCred)
            }
        }
        catch
        {
            throw $_
        }
    }
}

function Test-WindowsCredential
{
<#
.Synopsis
   Test Windows Credential Vault is exist as desired parameter
.DESCRIPTION
   Test desired credential can be retrieve from Credential Vault.
.EXAMPLE
   Test-WindowsCredential -ResourceName hoge
.EXAMPLE
   Test-WindowsCredential -ResourceName hoge -UserName username
#>
    [OutputType([Boolean])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = 1, Position = 0)]
        [string]$ResourceName,

        [parameter(Mandatory = 0, Position = 1, ValueFromPipeline = 1, ValueFromPipelineByPropertyName = 1)]
        [string]$UserName = ([string]::Empty)
    )
    
    process
    {
        try
        {
            # Check Windows Credential Vault
            $result = if ($UserName -ne [string]::Empty)
            {
                Write-Verbose ("Testing get Windows Credential from ResourceName : '{0}', UserName : '{1}'" -f $ResourceName, $UserName)
                (New-Object Windows.Security.Credentials.PasswordVault).Retrieve($ResourceName, $UserName)
            }
            else
            {
                Write-Verbose ("Testing get All Windows Credential for ResourceName : '{0}'" -f $ResourceName)
                (New-Object Windows.Security.Credentials.PasswordVault).FindAllByResource($ResourceName)
            }
        
            # return result
            if (@($result).Count -ne 0){ return $true }
        }
        catch
        {
            return $false
        }
    }
}

function Remove-WindowsCredential
{
<#
.Synopsis
   Remove Windows Credential Vault from specific ResourceName
.DESCRIPTION
   This function will remove your PSCredential from Password Vault.
.EXAMPLE
    Remove-WindowsCredential -ResourceName hoge -UserName username
.EXAMPLE
    Remove-WindowsCredential -ResourceName hoge -All
#>
    [OutputType([Void])]
    [CmdletBinding(DefaultParameterSetName = "Specific")]
    param
    (
        [parameter(Mandatory = 1, Position = 0)]
        [string]$ResourceName,

        [parameter(Mandatory = 0, Position = 1, ValueFromPipeline = 1, ValueFromPipelineByPropertyName = 1, ParameterSetName = "Specific")]
        [string[]]$UserName = [string]::Empty,

        [parameter(Mandatory = 0, Position = 1, ValueFromPipeline = 1, ValueFromPipelineByPropertyName = 1, ParameterSetName = "All")]
        [switch]$All
    )

    begin
    {
        filter RemoveCredential
        {
            $_ | ConvertTo-PasswordCredential -ResourceName $ResourceName `
            | %{
                Write-Verbose ("Removing Windows Password Vault for ResourceName : '{0}', UserName : '{1}'" -f $ResourceName, $_.UserName)
                (New-Object Windows.Security.Credentials.PasswordVault).Remove($_)
            }
        }
    }
    process
    {
        try
        {
            if ($All)
            {
                Get-WindowsCredential -ResourceName $ResourceName | RemoveCredential
                return;
            }

            $UserName `
            | where {Test-WindowsCredential -UserName $_ -ResourceName $ResourceName} `
            | Get-WindowsCredential -ResourceName $ResourceName `
            | RemoveCredential
        }
        catch
        {
            throw $_
        }
    }
}

Export-ModuleMember -Function *-WindowsCredential