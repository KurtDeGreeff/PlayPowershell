Get-CimInstance -ClassName Win32_DiskDrive -Filter "mediatype=3" | Get-CimAssociatedInstance -Association Win32_DiskDriveToDiskPartition

Get-CimInstance -ClassName win32_share -Filter "Name='c$'" | Get-CimAssociatedInstance -Association Win32_ShareToDirectory | Get-CimAssociatedInstance -Association CIM_DirectoryCOntainsFile | select name

$adapter=Get-WMIObject -Class Win32_NetworkAdapter -filter "NetEnabled=$true"
$config=$adapter.GetRelated('Win32_NetworkAdapterConfiguration')
$config

Get-CimInstance win32_networkadapter -Filter "NetEnabled=$true"|
Get-CimAssociatedInstance  #-ResultClassName Win32_NetworkAdapterConfiguration

Get-CimInstance win32_networkadapter -Filter "NetConnectionStatus=2"|
Get-CimAssociatedInstance -Association  #-ResultClassName Win32_NetworkAdapterConfiguration

$nic = Get-CimInstance -Class Win32_NetworkAdapter -Filter "NetEnabled=$true" 
(Get-CimAssociatedInstance -InputObject $nic).CimClass

Get-CimClass -ClassName *Network* -Qualifier "Association"

get-ciminstance win32_userprofile | ? lastusetime | select lastusetime, localpath,
@{LABEL='user';EXPRESSION={(gwmi win32_useraccount -filter "SID = '$($_.sid)'").caption}}