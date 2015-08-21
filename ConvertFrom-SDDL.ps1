filter ConvertFrom-SDDL
{
<#
.SYNOPSIS

    Convert a raw security descriptor from SDDL form to a parsed security descriptor.

    Author: Matthew Graeber (@mattifestation)

.DESCRIPTION

    ConvertFrom-SDDL generates a parsed security descriptor based upon any string in raw security descriptor definition language (SDDL) form. ConvertFrom-SDDL will parse the SDDL regardless of the type of object the security descriptor represents.

.PARAMETER RawSDDL

    Specifies the security descriptor in raw SDDL form.

.EXAMPLE

    ConvertFrom-SDDL -RawSDDL 'D:PAI(A;;0xd01f01ff;;;SY)(A;;0xd01f01ff;;;BA)(A;;0x80120089;;;NS)'

.EXAMPLE

    'O:BAG:SYD:(D;;0xf0007;;;AN)(D;;0xf0007;;;BG)(A;;0xf0005;;;SY)(A;;0x5;;;BA)', 'O:BAG:SYD:PAI(D;OICI;FA;;;BG)(A;OICI;FA;;;BA)(A;OICIIO;FA;;;CO)(A;OICI;FA;;;SY)' | ConvertFrom-SDDL

.INPUTS

    System.String

    ConvertFrom-SDDL accepts SDDL strings from the pipeline

.OUTPUTS

    System.Management.Automation.PSObject

.LINK

    http://www.exploit-monday.com
#>

    Param (
        [Parameter( Position = 0, Mandatory = $True, ValueFromPipeline = $True )]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $RawSDDL
    )

    Set-StrictMode -Version 2

    # Get reference to sealed RawSecurityDescriptor class
    $RawSecurityDescriptor = [Int].Assembly.GetTypes() | ? { $_.FullName -eq 'System.Security.AccessControl.RawSecurityDescriptor' }

    # Create an instance of the RawSecurityDescriptor class based upon the provided raw SDDL
    try
    {
        $Sddl = [Activator]::CreateInstance($RawSecurityDescriptor, [Object[]] @($RawSDDL))
    }
    catch [Management.Automation.MethodInvocationException]
    {
        throw $Error[0]
    }

    if ($Sddl.Group -eq $null)
    {
        $Group = $null
    }
    else
    {
        $SID = $Sddl.Group
        $Group = $SID.Translate([Security.Principal.NTAccount]).Value
    }
    
    if ($Sddl.Owner -eq $null)
    {
        $Owner = $null
    }
    else
    {
        $SID = $Sddl.Owner
        $Owner = $SID.Translate([Security.Principal.NTAccount]).Value
    }

    $ObjectProperties = @{
        Group = $Group
        Owner = $Owner
    }

    if ($Sddl.DiscretionaryAcl -eq $null)
    {
        $Dacl = $null
    }
    else
    {
        $DaclArray = New-Object PSObject[](0)

        $ValueTable = @{}

        $EnumValueStrings = [Enum]::GetNames([System.Security.AccessControl.CryptoKeyRights])
        $CryptoEnumValues = $EnumValueStrings | % {
                $EnumValue = [Security.AccessControl.CryptoKeyRights] $_
                if (-not $ValueTable.ContainsKey($EnumValue.value__))
                {
                    $EnumValue
                }
        
                $ValueTable[$EnumValue.value__] = 1
            }

        $EnumValueStrings = [Enum]::GetNames([System.Security.AccessControl.FileSystemRights])
        $FileEnumValues = $EnumValueStrings | % {
                $EnumValue = [Security.AccessControl.FileSystemRights] $_
                if (-not $ValueTable.ContainsKey($EnumValue.value__))
                {
                    $EnumValue
                }
        
                $ValueTable[$EnumValue.value__] = 1
            }

        $EnumValues = $CryptoEnumValues + $FileEnumValues

        foreach ($DaclEntry in $Sddl.DiscretionaryAcl)
        {
            $SID = $DaclEntry.SecurityIdentifier
            $Account = $SID.Translate([Security.Principal.NTAccount]).Value

            $Values = New-Object String[](0)

            # Resolve access mask
            foreach ($Value in $EnumValues)
            {
                if (($DaclEntry.Accessmask -band $Value) -eq $Value)
                {
                    $Values += $Value.ToString()
                }
            }

            $Access = "$($Values -join ',')"

            $DaclTable = @{
                Rights = $Access
                IdentityReference = $Account
                IsInherited = $DaclEntry.IsInherited
                InheritanceFlags = $DaclEntry.InheritanceFlags
                PropagationFlags = $DaclEntry.PropagationFlags
            }

            if ($DaclEntry.AceType.ToString().Contains('Allowed'))
            {
                $DaclTable['AccessControlType'] = [Security.AccessControl.AccessControlType]::Allow
            }
            else
            {
                $DaclTable['AccessControlType'] = [Security.AccessControl.AccessControlType]::Deny
            }

            $DaclArray += New-Object PSObject -Property $DaclTable
        }

        $Dacl = $DaclArray
    }

    $ObjectProperties['Access'] = $Dacl

    $SecurityDescriptor = New-Object PSObject -Property $ObjectProperties

    Write-Output $SecurityDescriptor
}