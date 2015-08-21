<#   
.SYNOPSIS   
	Script to read firewall rules and output as an array of objects.
    
.DESCRIPTION 
	This script will gather the Windows Firewall rules from the registry and convert the information stored in the registry keys to PowerShell Custom Objects to enable easier manipulation and filtering based on this data.
	
.PARAMETER Local
    By setting this switch the script will display only the local firewall rules

.PARAMETER GPO
    By setting this switch the script will display only the firewall rules as set by group policy

.NOTES   
    Name: Get-FireWallRules.ps1
    Author: Jaap Brasser
    DateUpdated: 2013-01-10
    Version: 1.1

.LINK
http://www.jaapbrasser.com

.EXAMPLE   
	.\Get-FireWallRules.ps1

Description 
-----------     
The script will output all the local firewall rules

.EXAMPLE   
	.\Get-FireWallRules.ps1 -GPO

Description 
-----------     
The script will output all the firewall rules defined by group policies

.EXAMPLE   
	.\Get-FireWallRules.ps1 -GPO -Local

Description 
-----------     
The script will output all the firewall rules defined by group policies as well as the local firewall rules
#>
param(
    [switch]$Local,
    [switch]$GPO
)

# If no switches are set the script will default to local firewall rules
if (!($Local) -and !($Gpo)) {
    $Local = $true
}

$RegistryKeys = @()
if ($Local) {$RegistryKeys += 'Registry::HKLM\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules'}
if ($GPO) {$RegistryKeys += 'Registry::HKLM\Software\Policies\Microsoft\WindowsFirewall\FirewallRules'}

Foreach ($Key in $RegistryKeys) {
    if (Test-Path -Path $Key) {
        (Get-ItemProperty -Path $Key).PSObject.Members |
        Where-Object {(@('PSPath','PSParentPath','PSChildName') -notcontains $_.Name) -and ($_.MemberType -eq 'NoteProperty') -and ($_.TypeNameOfValue -eq 'System.String')} |
         ForEach-Object {
        
            # Prepare hashtable
            $HashProps = @{
                NameOfRule = $_.Name
                RuleVersion = ($_.Value -split '\|')[0]
                Action = $null
                Active = $null
                Dir = $null
                Protocol = $null
                LPort = $null
                App = $null
                Name = $null
                Desc = $null
                EmbedCtxt = $null
                Profile = $null
                RA4 = $null
                RA6 = $null
                Svc = $null
                RPort = $null
                ICMP6 = $null
                Edge = $null
                LA4 = $null
				LA6 = $null
                ICMP4 = $null
                LPort2_10 = $null
                RPort2_10 = $null
            }

            # Determine if this is a local or a group policy rule and display this in the hashtable
            if ($Key -match 'HKLM\\System\\CurrentControlSet') {
                $HashProps.RuleType = 'Local'
            } else {
                $HashProps.RuleType = 'GPO'
            }

            # Iterate through the value of the registry key and fill PSObject with the relevant data
            ForEach ($FireWallRule in ($_.Value -split '\|')) {
                switch (($FireWallRule -split '=')[0]) {
                    'Action' {$HashProps.Action = ($FireWallRule -split '=')[1]}
                    'Active' {$HashProps.Active = ($FireWallRule -split '=')[1]}
                    'Dir' {$HashProps.Dir = ($FireWallRule -split '=')[1]}
                    'Protocol' {$HashProps.Protocol = ($FireWallRule -split '=')[1]}
                    'LPort' {$HashProps.LPort = ($FireWallRule -split '=')[1]}
                    'App' {$HashProps.App = ($FireWallRule -split '=')[1]}
                    'Name' {$HashProps.Name = ($FireWallRule -split '=')[1]}
                    'Desc' {$HashProps.Desc = ($FireWallRule -split '=')[1]}
                    'EmbedCtxt' {$HashProps.EmbedCtxt = ($FireWallRule -split '=')[1]}
                    'Profile' {$HashProps.Profile = ($FireWallRule -split '=')[1]}
                    'RA4' {[array]$HashProps.RA4 += ($FireWallRule -split '=')[1]}
                    'RA6' {[array]$HashProps.RA6 += ($FireWallRule -split '=')[1]}
                    'Svc' {$HashProps.Svc = ($FireWallRule -split '=')[1]}
                    'RPort' {$HashProps.RPort = ($FireWallRule -split '=')[1]}
                    'ICMP6' {$HashProps.ICMP6 = ($FireWallRule -split '=')[1]}
                    'Edge' {$HashProps.Edge = ($FireWallRule -split '=')[1]}
                    'LA4' {[array]$HashProps.LA4 += ($FireWallRule -split '=')[1]}
					'LA6' {[array]$HashProps.LA6 += ($FireWallRule -split '=')[1]}
                    'ICMP4' {$HashProps.ICMP4 = ($FireWallRule -split '=')[1]}
                    'LPort2_10' {$HashProps.LPort2_10 = ($FireWallRule -split '=')[1]}
                    'RPort2_10' {$HashProps.RPort2_10 = ($FireWallRule -split '=')[1]}
                    Default {}
                }
            }
        
            # Create and output object using the properties defined in the hashtable
            New-Object -TypeName 'PSCustomObject' -Property $HashProps
        }
    }
}