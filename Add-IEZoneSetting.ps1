<#
.SYNOPSIS
Configure Internet Explorer SecurityZone Settings.

.DESCRIPTION
Note: Configration is not applied immediately, Need to restart related services to apply zone settings.

.LINK
http://support.microsoft.com/kb/184456/en-us

.EXAMPLE
$params = @{
    SiteUrl = "http://172.16.0.1"
    Zone = "Intranet"
}
Add-InternetExploreZoneSetting @params -Verbose

.EXAMPLE
$params = @{
    HostName = "172.16.0.1"
    Protocol = "file"
    Zone = "TrustedSite"
}
Add-InternetExploreZoneSetting @params -Verbose
#>
function Add-InternetExploreZoneSetting
{
    [CmdletBinding(DefaultParametersetName = "BySiteUrl")]
    param (
        [Parameter(ParameterSetName = "BySiteUrl", Mandatory)]
        [string] $SiteUrl,
        [Parameter(ParameterSetName = "ByHostName", Mandatory)]
        [string] $HostName,
        [Parameter(ParameterSetName = "ByHostName", Mandatory)]
        [ValidateSet("file", "http", "https", "*")]
        [string] $Protocol,
        [Parameter(Mandatory, ParameterSetName = "BySiteUrl")]
        [Parameter(Mandatory, ParameterSetName = "ByHostName")]
        [ValidateSet("Intranet", "TrustedSite", "RestrictedSite")]
        [string] $Zone
    )

    $ErrorActionPreference = "Stop"
    Set-StrictMode -Version Latest

    Write-Verbose "Add Internet Explorer Zone settings..." #ZoneNetwork Share($key) to Intranet Zone"
		
    #Convert　Zone to ZoneId
    switch ($Zone)
    {
        "Intranet"{ $zoneId = 1 }
        "TrustedSite"{ $zoneId = 2 }
        "RestrictedSite"{ $zoneId = 4 }
        default{ throw "Not expected zone Name!" }
    }
	
    switch ($PsCmdlet.ParameterSetName)
    {
        "BySiteUrl"{
            if ($SiteUrl -contains "*")
            {
                throw "Don't support wildcard. use ByHostName ParameterSet instead"
            }
			
            try
            {
                $uri = New-Object Uri $SiteUrl
            } catch {
                throw "Can't parse Url:$SiteUrl"
            }
            $HostName = $uri.Host
            $Protocol = $uri.Scheme
        }
    }

    if ($HostName -like "*.*.*.*")
    {
        Write-Verbose ("`tAdd entry to Zone({0}), IPAddress({1}), Protocol({2})" -f $Zone, $HostName, $protocol)
        $basePath = "HKCU:Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Ranges"
	
        $entry = Get-ChildItem $basePath | Get-ItemProperty -Name ":Range" | where ":Range" -eq $HostName
        if ($entry -eq $null)
        {
            #Create Entry (Range1..N , other names is not recognized)
            $N = 1
            while (Test-Path (Join-Path $basePath "Range$N"))
            {
                ++$N
            }
            $entry = New-Item -Path $basePath -Name "Range$N" -Force
        }
			
        #Add IP range to Zone
        New-ItemProperty -Path $entry.PSPath -Name ":Range" -Value $HostName -PropertyType String -Force > $null
        New-ItemProperty -Path $entry.PSPath -Name $Protocol -Value $ZoneId -PropertyType DWORD -Force > $null
    }
    else
    {
        #Create Entry for hostname
        Write-Verbose ("`tAdd entry to Zone({0}), HostName({1}), Protocol({2})" -f $Zone, $HostName, $Protocol)
		
        #If hostname contain subdomain. need to split two parts, 
        $parts = $HostName.Split(".")
        if ($parts.Count -gt 2)
        {
            $containerName = [String]::Join(".", ($parts | select -Last 2))
            $leafName = [String]::Join(".", ($parts | select -First ($parts.Count - 2)))
        }
        else
        {
            $containerName = $null
            $leafName = $HostName
        }
		
        #TODO:Need to support ESCDomain for server OS?
        $entry = Get-Item -Path "HKCU:Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains"
		
        #Create container entry(if subdomain used)
        if ($containerName -ne $null)
        {
            $entry = New-Item -Path $entry.PSPath -Name $containerName -Force
        }

        $entry = New-Item -Path $entry.PSPath -Name $leafName -Force
        New-ItemProperty -Path $entry.PSPath -Name $Protocol -Value $ZoneId -PropertyType DWORD -Force > $null
    }
}