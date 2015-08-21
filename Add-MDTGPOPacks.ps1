<# This script ensures custom GPO packs are copied to linked deployment shares or media which does not happen by default.
MDT knows how to replicate certain folders to linked deployment shares and media, only the “Templates\GPOPacks” folder isn’t included in that list of folders.
The following commands assume you only have one “main” deployment share (which becomes DS001: when the Restore-MDTPersistentDrive cmdlet runs), 
one linked deployment share (which has a logical name of “LINKED001”), and one media definition (which is “MEDIA001”). 
You might need to adjust the values if you have more deployment shares or different objects. You also need to run this script again if new media is created after its last run.
(You can see the logical IDs in Workbench.)
#>
Import-Module 'C:\Program Files\Microsoft Deployment Toolkit\Bin\MicrosoftDeploymentToolkit.psd1' 
Restore-MDTPersistentDrive 
Set-ItemProperty -Path 'DS001:\Linked Deployment Shares\LINKED001' -Name ExtraFolders -Value @("Templates\GPOPacks") 
Set-ItemProperty -Path 'DS001:\Media\MEDIA001' -Name ExtraFolders -Value @("Templates\GPOPacks")