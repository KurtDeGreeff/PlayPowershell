Import-Module WebAdministration
cd IIS:
ls

#Source: http://www.westerndevs.com/setting-up-an-iis-site-using-powershell/
#Have one AppPool for each application

if(Test-Path IIS:\AppPools\CoolWebSite)
{
	echo "App pool exists - removing"
	Remove-WebAppPool CoolWebSite
	gci IIS:\AppPools
}
$pool = New-Item IIS:\AppPools\CoolWebSite

<#This particular site needs to run as a particular user instead of the AppPoolUser or LocalSystem or anything like that. 
These will be passed in as a variable. 
We need to set the identity type to the confusing value of 3. 
This maps to using a specific user. 
The documentation on this is near impossible to find.#>

#Create App pool with specific user
$pool.processModel.identityType = 3
$pool.processModel.userName = $deployUserName
$pool.processModel.password = $deployUserPassword
$pool | set-item

#Creating website by deleting and adding it
if(Test-Path IIS:\Sites\CoolWebSite)
{
echo "Website exists - removing"

Remove-WebSite CoolWebSite
gci IIS:\Sites
}
echo "Creating new website"
New-Website -name "CoolWebSite" -PhysicalPath $deploy_dir -ApplicationPool "CoolWebSite" -HostHeader $deployUrl

#Turn off anonymous and turn on windows authentication
Set-WebConfigurationProperty -filter /system.webServer/security/authentication/windowsAuthentication -name enabled -value true -PSPath IIS:\Sites\CoolWebSite
Set-WebConfigurationProperty -filter /system.webServer/security/authentication/anonymousAuthentication -name enabled -value false -PSPath IIS:\Sites\CoolWebSite