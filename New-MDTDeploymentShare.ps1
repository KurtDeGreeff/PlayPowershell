<#

************************************************************************************************************************

Created:	2015-03-01
Version:	1.1
Homepage:  	http://deploymentresearch.com

Disclaimer:
This script is provided "AS IS" with no warranties, confers no rights and 
is not supported by the authors or DeploymentArtist.

Author - Johan Arwidmark
    Twitter: @jarwidmark
    Blog   : http://deploymentresearch.com

************************************************************************************************************************

#>

If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Oupps, you need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
    Write-Warning "Aborting script..."
    Break
}
 
# Validation OK, load the MDT SnapIn
Add-PSSnapIn Microsoft.BDD.PSSnapIn -ErrorAction SilentlyContinue
 
# Create MDT deployment share
$MDTServer = (get-wmiobject win32_computersystem).Name
$InstallDrive = "C:"
New-Item -Path $InstallDrive\MDTProduction -ItemType directory
New-PSDrive -Name "DS001" -PSProvider "MDTProvider" -Root "$InstallDrive\MDTProduction" -Description "MDT Production" -NetworkPath "\\$MDTServer\MDTProduction$" | add-MDTPersistentDrive
New-SmbShare –Name MDTProduction$ –Path "$InstallDrive\MDTProduction" –ChangeAccess EVERYONE
 
# Create optional MDT Media content
New-Item -Path $InstallDrive\MEDIA001 -ItemType directory
New-PSDrive -Name "DS002" -PSProvider MDTProvider -Root "$InstallDrive\MDTProduction"
New-Item -Path "DS002:\Media" -enable "True" -Name "MEDIA001" -Comments "" -Root "$InstallDrive\MEDIA001" -SelectionProfile "Nothing" -SupportX86 "False" -SupportX64 "True" -GenerateISO "False" -ISOName "LiteTouchMedia.iso" -Force -Verbose
New-PSDrive -Name "MEDIA001" -PSProvider "MDTProvider" -Root "$InstallDrive\MEDIA001\Content\Deploy" -Description "MDT Production Media" -Force -Verbose
 
# Update the MDT Media (and another round of creation because of a bug in MDT internal processing)
Update-MDTMedia -path "DS002:\Media\MEDIA001" -Verbose
Remove-Item -path "DS002:\Media\MEDIA001" -force -verbose
New-Item -path "DS002:\Media" -enable "True" -Name "MEDIA001" -Comments "" -Root "$InstallDrive\MEDIA001" -SelectionProfile "Everything" -SupportX86 "False" -SupportX64 "True" -GenerateISO "False" -ISOName "LiteTouchMedia.iso" -Verbose -Force
New-PSDrive -Name "MEDIA001" -PSProvider "MDTProvider" -Root "$InstallDrive\MEDIA001\Content\Deploy" -Description "MDT Production Media" -Force -Verbose