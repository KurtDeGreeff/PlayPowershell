#region Presentation Prep

#PowerShellGet Presentation from the PowerShell Summit North America 2015
#Author:  Mike F Robbins
#Website: http://mikefrobbins.com
#Twitter: @mikefrobbins

#Note: Everything shown in this presentation is subject to change.
#This presentation is based on the February 2015 WMF 5 preview.

#6 VM's are used during this demonstration. 3 running Windows 8.1,
#2 running Windows Server 2012 R2, one DC, one IIS web server.

#Set PowerShell ISE Zoom to 145%

$psISE.Options.Zoom = 145

#Tip learned from Ashley McGlone (@GoateePFE)
#Stop the script here if the whole thing is run accidentally instead of a selection

break

#Set location to the demo folder

Set-Location -Path c:\demo

#Test Internet Connectivity

Test-NetConnection -ComputerName bing.com -Port 80 -InformationLevel Quiet

#Create variables to the module paths & appdata

$UserModules = "$HOME\Documents\WindowsPowerShell\Modules"
$AllUsersModules = "$env:ProgramFiles\WindowsPowerShell\Modules"
$AppDataPoSH = "$env:LOCALAPPDATA\Microsoft\Windows\PowerShell"
$NuGetPath = 'C:\Program Files\OneGet\ProviderAssemblies'

#Show PowerShell version used in this demo (February 2015 WMF 5 Preview)

$PSVersionTable.PSVersion

#Clear the screen

Clear-Host

#endregion

#region PowerShellGet Basics

#Show the cmdlets that are part of the PowerShellGet module
#Bonus Tip: Show zooming in with Out-GridView (cntl & +). Who needs ZoomIt?

Get-Command -Module PowerShellGet |
Sort-Object -Property Noun |
Out-GridView -Title 'Get-Command -Module PowerShellGet'

#Show the default repository and note that it is untrusted

Get-PSRepository

#Show the PowerShell Gallery website and the relationship of PowerShellGet to OneGet

Start-Process iexplore.exe https://www.powershellgallery.com/

#Discover modules from the PSGallery using the Find-Module command.

Find-Module -OutVariable Modules

#Show the number of modules in the PSGallery

$Modules.Count

#I've previously exported a list of the modules just in case
#Find-Module | Export-Clixml -Path C:\demo\modules.xml -Force
#Import-Clixml -Path C:\demo\modules.xml -OutVariable Modules

#Show finding the xJea module

Find-Module -Name xJea

#Show the additional info when using the verbose parameter.
#Notice the Repository parameter reference.

Find-Module -Name xJea -Verbose

#Search only one repository & notice only the latest version of the module is returned
#Searching all repositories takes time to timeout if one or more aren't online

Find-Module -Name xJea -Repository PSGallery -Verbose

#Are you putting your PowerShell code in some type of source control system?
#PowerShellGet could be used as a simplistic source control system for modules

#Show all versions of the module in the repository

Find-Module -Name xJea -Repository PSGallery -AllVersions

#Wildcards are automatically added to the name if they are not specified

Find-Module -Name *ea -Repository PSGallery

Find-Module -Name ea -Repository PSGallery

#Verify the xJea module is not currently installed

Get-Module -Name xJea -ListAvailable

#Notice the message about the PSGallery being untrusted

Find-Module -Name xJea -Repository PSGallery | Install-Module -Verbose

#xJea was installed in the all users module location (which is the default)

Get-Module -Name xJea -ListAvailable

#Notice that there's no delete module cmdlet

Get-Command -Module PowerShellGet | Sort-Object -Property Name

#That means modules have to be removed manually

Remove-Module -Name xJea -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$AllUsersModules\xJea" -Recurse -Force

#Verify the module was removed

Get-Module -Name xJea -ListAvailable

#This time use Install-Module without piping Find-Module to it and specify the
#CurrentUser scope. Use the Force parameter to avoid the untrusted repository prompt

Install-Module -Name xJea -Repository PSGallery -Scope CurrentUser -Force

#Verify the xJea module was installed and notice the path where it was installed

Get-Module -Name xJea -ListAvailable

#Install-Module doesn't support wildcards like Find-Module does
#The solution is to use wildcards with Find-Module and pipe to Install-Module
#Install-Module works with wildcards when only one item is returned by the wildcard search

#endregion

#region SMB Repository

#Is the security policy at your company going to allow the installation of modules from a
#public untrusted repository? Do you have modules that must remain private to your company?
#Then you need a private repository. Be sure to backup & have a DR plan for your repository.

#SMB is the easy way to create a private PowerShellGet repository

Invoke-Command -ComputerName dc01 {
    New-Item -Path c:\SMBRepo -ItemType Directory
    New-SmbShare –Name SMBRepo –Path c:\SMBRepo -FullAccess mikefrobbins\administrator
}

#Register the SMB Share as a PowerShellGet Repository

$Params = @{
    Name = 'SMBRepo'
    SourceLocation = '\\dc01\SMBRepo'
    PublishLocation = '\\dc01\SMBRepo'
    InstallationPolicy = 'Trusted'
    OneGetProvider = 'Nuget'
}
Register-PSRepository @Params

#Show the newly added repository

Get-PSRepository

#Verify the MrSQL module does exist on the local computer

Get-Module -Name MrSQL -ListAvailable

#List the files that are part of the MrSQL module

Get-Module -Name MrSQL -ListAvailable |
Select-Object -ExpandProperty ModuleBase |
Get-ChildItem

#Attempt to publish the MrSQL module to the SMB repository

Publish-Module -Name MrSQL -Repository SMBRepo -NuGetApiKey 'DoesNotMatterForSMB'

#Create a module manifest

$Params = @{
    Path = "$UserModules\MrSQL\MrSQL.psd1"
    Author = 'Mike F Robbins'
    PowerShellVersion = '3.0'
    RootModule = 'MrSQL'
}
New-ModuleManifest @Params

#Now there is a MrSQL version 1.0 module

Get-Module -Name MrSQL -ListAvailable

#There's now a psd1 file (module manifest) in the directory

Get-Module -Name MrSQL -ListAvailable |
Select-Object -ExpandProperty ModuleBase |
Get-ChildItem

#Show the extra meta data in a module manifest created with PowerShell v5

psEdit -filenames (Get-Module -Name MrSQL -ListAvailable).path

#Attempt to publish the MrSQL module to the SMB repository again

Publish-Module -Name MrSQL -Repository SMBRepo -NuGetApiKey 'DoesNotMatterForSMB'

#Add a description and recreate the module manifest

$Params.Add('Description','Mike Robbins SQL PowerShell Module')
New-ModuleManifest @Params

#Attempt to publish the MrSQL module to the SMB repository again

Publish-Module -Name MrSQL -Repository SMBRepo -NuGetApiKey 'DoesNotMatterForSMB'

#List modules in the repository

Find-Module -Name MrSQL -Repository SMBRepo

#Show an SMB repository is nothing more than a fileshare & show the nuget package

Start-Process \\dc01\SMBRepo

#Trying to publish the same version of the same module twice will result in an error

Publish-Module -Name MrSQL -Repository SMBRepo -NuGetApiKey 'DoesNotMatterForSMB'

#Remove the MrSQL version 1.0 module from the local computer

Get-Module -ListAvailable -Name MrSQL |
Select-Object -ExpandProperty ModuleBase |
Remove-Item -Recurse -Force

#There is no longer a module named MrSQL on the local computer

Get-Module -Name MrSQL -ListAvailable

#Install the MrSQL module from the PowerShellGet repository

Install-Module -Name MrSQL -Repository SMBRepo -Verbose

#Show version 1.0 of the MrSQL module is now installed

Get-Module -Name MrSQL -ListAvailable

#Show the files in the MrSQL module directory

Get-Module -Name MrSQL -ListAvailable |
Select-Object -ExpandProperty ModuleBase |
Get-ChildItem

#Show hidden XML file

Get-Module -Name MrSQL -ListAvailable |
Select-Object -ExpandProperty ModuleBase |
Get-ChildItem -Force -OutVariable xmlFile

#Did you know that you can't open hidden files with psEdit?

$psISE.CurrentPowerShellTab.Files.Add(($xmlFile.Where{
$_ -like 'PSGetModuleInfo.xml'}).fullname) | Out-Null

#Show the MrSQL module directory in the GUI

Start-Process ($xmlFile.Where{$_ -like 'PSGetModuleInfo.xml'}).directory

#Prep - Make a copy of the MrSQL module to develop a new version

New-Item -Path $UserModules -Name MrSQL -ItemType Directory
Copy-Item -Path $UserModules\MrSQL1\* -Destination $UserModules\MrSQL

#Create a module manifest with version 1.1

$Params.Add('ModuleVersion','1.1')
New-ModuleManifest @Params

#Show we now have two MrSQL modules

Get-Module -Name MrSQL -ListAvailable

#Attempting to publish without specifying which one will generate an error

Publish-Module -Name MrSQL -Repository SMBRepo -NuGetApiKey 'DoesNotMatterForSMB'

#Publish version 1.1 of the MrSQL module

Publish-Module -Name "$UserModules\MrSQL" -Repository SMBRepo -NuGetApiKey 'NA'

#The results show why I don't recommend using an SMB Repository

Find-Module -Name MrSQL -Repository SMBRepo

#endregion

#region Repository

#Update the settings for an existing PowerShell repository

Get-PSRepository -Name SMBRepo
Set-PSRepository -Name SMBRepo -InstallationPolicy Untrusted
Get-PSRepository -Name SMBRepo

#Show where the repository information is stored

Start-Process "$AppDataPoSH\PowerShellGet"
(Import-Clixml -Path "$AppDataPoSH\PowerShellGet\PSRepositories.xml").values

#Remove a PowerShellGet repository

Unregister-PSRepository -Name SMBRepo
Get-PSRepository

#endregion

#region ProGet

#ProGet https://inedo.com/proget/overview
#ProGet Silent Installation:
#http://inedo.com/support/documentation/proget/installation/silent-installation

#Unattended install for ProGet. This takes a while so kick it off now.

#.\ProGetSetup3.5.5_SQLExpress.exe --% /S /Edition=Express /EmailAddress=mikefrobbins@msn.com
#   /FullName="Mike F Robbins" /InstallSqlExpress /UseIntegratedWebServer=false /ConfigureIIS

#Open the ProGet repository with IE and setup a NuGet feed

Start-Process iexplore.exe http://web03.mikefrobbins.com:81/

#Register the ProGet repository as a trusted PowerShellGet repository

$Params = @{
    Name = 'ProGet'
    SourceLocation = 'http://web03.mikefrobbins.com:81/nuget/ProGet'
    PublishLocation = 'http://web03.mikefrobbins.com:81/nuget/ProGet'
    InstallationPolicy = 'Trusted'
    OneGetProvider = 'NuGet'
}
Register-PSRepository @Params

#Show the newly added repository

Get-PSRepository

#Publish version 1.0 of the MrSQL module to the ProGet repository

Publish-Module -Name "$AllUsersModules\MrSQL" -Repository ProGet -NuGetApiKey 'Admin:Admin'

#Verify the module was published

Find-Module -Repository ProGet

#Publish version 1.1 of the MrSQL module to the ProGet repository

Publish-Module -Name "$UserModules\MrSQL\MrSQL.psd1" -Repository ProGet -NuGetApiKey 'Admin:Admin'

#Show version 1.1 was published

Find-Module -Repository ProGet

#Remove MrSQL modules from PC02

Get-Module -ListAvailable -Name MrSQL |
Select-Object -ExpandProperty ModuleBase |
Remove-Item -Recurse -Force

#Verify that MrSQL does not exist

Get-Module -Name MrSQL -ListAvailable

#Install version 1.0 from the ProGet repository

Find-Module -Name MrSQL -Repository ProGet -RequiredVersion 1.0 |
Install-Module

#Verify MrSQL v1.0 is installed

Get-Module -Name MrSQL -ListAvailable

#Remove the ProGet PowerShellGet repository

Unregister-PSRepository -Name ProGet
Get-PSRepository

#Attempt to update to version 1.1 (remember the ProGet repository is no longer registered).

Update-Module -Name MrSQL -Verbose

#Show MrSQL v1.1 is now installed

Get-Module -Name MrSQL -ListAvailable

#How did it update from a repository that is no longer registered?

$psISE.CurrentPowerShellTab.Files.Add(($xmlFile.Where{
$_ -like 'PSGetModuleInfo.xml'}).fullname) | Out-Null

#Create a PSSession to PC04, PC05, PC06

$Session = New-PSSession -ComputerName pc04, pc05, pc06

#Recreate credentials from password stored on disk

#$cred = Get-Credential
#$Cred | Export-CliXml -Path C:\demo\altcred.ps1.xml

$Cred = Import-CliXml -Path C:\demo\altcred.ps1.xml

#Create another PSSession to PC04, PC05, PC06 using alternate credentials

$Session2 = New-PSSession -ComputerName pc04, pc05, pc06 -Credential $cred

#Check to see what PowerShell version is on PC04, PC05, & PC06

Invoke-Command -Session $Session {
    $PSVersionTable.PSVersion
}

#Register the ProGet repository on PC04, PC05, PC06

Invoke-Command -Session $Session {
    $Params = @{
        Name = 'ProGet'
        SourceLocation = 'http://web03.mikefrobbins.com:81/nuget/ProGet'
        PublishLocation = 'http://web03.mikefrobbins.com:81/nuget/ProGet'
        InstallationPolicy = 'Trusted'
        OneGetProvider = 'NuGet'
    }
    Register-PSRepository @Params
    Get-PSRepository
}

#Install MrSQL module on PC04, PC05, 06

Invoke-Command -Session $Session {
    Install-Module -Name MrSQL -RequiredVersion 1.0 -Force
    Get-Module -Name MrSQL -ListAvailable
}

#Notice the ProGet repository does not exist as a different user

Invoke-Command -Session $Session2 {
    Get-PSRepository
}

#Update the MrSQL module as an alternate user

Invoke-Command -Session $Session2 {
    Update-Module -Name MrSQL -Force
    Get-Module -Name MrSQL -ListAvailable
}

#endregion

#region Visual Studio

#Create a repository with Visual Studio
#Create a new project, selecting Asp.Net empty web application
#Select manage NuGet packages
#Install NuGet.Server package
#Modify the webconfig
#Build the solution

#Walthrough by PowerShell MVP Boe Prox. The blog says OneGet, but it's the same process.
#http://learn-powershell.net/2014/04/11/setting-up-a-nuget-feed-for-use-with-oneget/

#Copy the solution to web03

Copy-Item -Path C:\demo\VSRepo\VSRepo\* -Recurse -Destination '\\web03\C$\inetpub\wwwroot' -Force

#PowerShellGet Module Repository created with Visual Studio

Start-Process iexplore.exe http://vsrepo.mikefrobbins.com/default.aspx

#Register Visual Studio created NuGet repository

$Params = @{
Name = 'VSRepo'
SourceLocation = 'http://vsrepo.mikefrobbins.com/nuget'
PublishLocation = 'http://vsrepo.mikefrobbins.com'
InstallationPolicy = 'Trusted'
OneGetProvider = 'Nuget'
}
Register-PSRepository @Params

#Show the VSRepo repository was added

Get-PSRepository

#Show the module that will be published

Get-Module -Name MrSQL -ListAvailable

#Publish the MrSQL module to the VSRepo repository
Publish-Module -Name MrSQL -Repository VSRepo -NuGetApiKey '12345'

#Show the module was published
Find-Module -Repository VSRepo

#endregion

#region Bonus

#The NuGet client binaries are installed the first time one of the PowerShellGet
#cmdlets is run: C:\Program Files\OneGet\ProviderAssemblies\nuget-anycpu.exe
#See Install-NuGetClientBinaries at line 1519

psEdit -filenames "$PSHome\Modules\PowerShellGet\PSGet.psm1"

#Make sure the xJea module does not exist on PC02

Get-Module -ListAvailable -Name xJea |
Select-Object -ExpandProperty ModuleBase |
Remove-Item -Recurse -Force

#Show the module no longer exists on the local computer

Get-Module -Name xJea -ListAvailable
Get-Package -ProviderName PSModule -Name xJea

#Unload the PowerShellGet module

Remove-Module -Name PowerShellGet

#Rename the PowerShellGet module

Rename-Item -Path "$PSHome\Modules\PowerShellGet" -NewName 'PowerShellGet1'

#Show the PowerShellGet module no longer exists

Import-Module -Name PowerShellGet

#Find modules using OneGet cmdlets

Find-Package -ProviderName PSModule | Format-Table -AutoSize

#Install the xJea module using OneGet

Find-Package -ProviderName PSModule -Name xJea |
Install-Package

#Uninstall doesn't work though

Get-Package -ProviderName PSModule -Name xJea |
Uninstall-Package

#Show the xJea module is still installed

Get-Module -Name xJea -ListAvailable

#PowerShellGet repositories also show up in oneGet

Get-PackageSource

#Create a PowerShellGet repository with the OneGet cmdlets

$Params = @{
    Name = 'SMBRepo'
    Location = '\\dc01\SMBRepo'
    PublishLocation = '\\dc01\SMBRepo'
    Trusted = $true
    ProviderName = 'PSModule'
}
Register-PackageSource @Params

Unregister-PackageSource -Name VSRepo
Get-PackageSource

#Rename the PowerShellGet repository back to the orignal name

Rename-Item -Path "$PSHome\Modules\PowerShellGet1" -NewName 'PowerShellGet' -ErrorAction SilentlyContinue

#Show the repositoy changes made with OneGet show up in PowerShellGet

Get-PSRepository

#This is how Publish-Module works (it uses pack and then publish)
& "$NuGetPath\nuget-anycpu.exe"

#endregion

#region References for comments made during presentation

#Never place your modules in the path where the help references it for New-ModuleManifest

help New-ModuleManifest -Parameter Path

#Parameter differences in Get-Help and Get-Command

Update-Help -Module PowerShellGet -Force -Verbose

(help Find-Module).parameters.parameter.name
(Get-Command -Name Find-Module).parameters.values.name

#When learning to use these cmdlets, realize this is a preview and the help is not completely accurate

help Find-Module -Parameter Name
help Install-Module -Parameter Name

#endregion

#region Cleanup and Reset Demo

#Set location back to default

Set-Location -Path C:\windows\System32

#Set PowerShell ISE Zoom to 100%

$psISE.Options.Zoom = 100

#Rename the PowerShellGet repository back to the orignal name

Rename-Item -Path "$PSHome\Modules\PowerShellGet1" -NewName 'PowerShellGet' -ErrorAction SilentlyContinue

#Remove the VSRepo Visual Studio solution

Remove-Item -Path C:\demo\VSRepo -Recurse -Force -ErrorAction SilentlyContinue

#Remove the non-default PowerShellGet Repositories

Get-PSRepository |
Where-Object Name -ne PSGallery |
Unregister-PSRepository

#Delete the xJea module from PC02

Get-Module -ListAvailable -Name xJea |
Select-Object -ExpandProperty ModuleBase |
Remove-Item -Recurse -Force

#Delete the MrSQL module from PC02

Get-Module -ListAvailable -Name MrSQL |
Select-Object -ExpandProperty ModuleBase |
Remove-Item -Recurse -Force

#Remove the SMB file share from DC01

Invoke-Command -ComputerName dc01 {
    Remove-SmbShare -Name SMBRepo -Force -ErrorAction SilentlyContinue
    Remove-Item -Path c:\SMBRepo -Recurse -Force -ErrorAction SilentlyContinue
}

#Remove the MrSQL module from PC04, PC05, PC06

Invoke-Command -ComputerName pc04, pc05, pc06 {
    Get-Module -ListAvailable -Name MrSQL |
    Select-Object -ExpandProperty ModuleBase |
    Remove-Item -Recurse -Force
}

#Remove the non-default PowerShellGet Repositories from PC04, PC05, PC06

Invoke-Command -ComputerName pc04, pc05, pc06 {
    Get-PSRepository |
    Where-Object Name -ne PSGallery |
    Unregister-PSRepository
}

#Remove the PSSessions

Get-PSSession | Remove-PSSession -ErrorAction SilentlyContinue

#Remove the session variables

Remove-Variable -Name Session, Session2 -ErrorAction SilentlyContinue

#Copy the MrSQL module so it exists without a module manifest

New-Item -Path "$HOME\Documents\WindowsPowerShell\Modules" -Name MrSQL -ItemType Directory
Copy-Item -Path "$HOME\Documents\WindowsPowerShell\Modules\MrSQL1\*" -Destination "$HOME\Documents\WindowsPowerShell\Modules\MrSQL"

#endregion