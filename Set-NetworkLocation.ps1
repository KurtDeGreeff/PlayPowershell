# Download Interop.Networklist.dll from http://blogs.technet.com/b/heyscriptingguy/archive/2012/06/10/weekend-scripter-use-powershell-to-manage-windows-network-locations.aspx?utm_source=twitterfeed&utm_medium=twitter

Add-Type –Path "$home\documents\microsoft script explorer\Interop.NETWORKLIST.dll"

$nlm = new-object NETWORKLIST.NetworkListManagerClass

$nlm.GetNetworks("NLM_ENUM_NETWORK_ALL") | select @{n="Name";e={$_.GetName()}},@{n="Category";e={$_.GetCategory()}},IsConnected,IsConnectedToInternet
# Property Category: 0 = Public, 1 = Private

#Change Name of disconnected location
# $nlm.GetNetworks(2) | % { if ($_.GetName() –eq "EIA_FREE_WIFI") { $_.SetName("EIA") } }

#change a currently connected location’s category from public to private:
$net = $nlm.GetNetworks("NLM_ENUM_NETWORK_CONNECTED") | select -first 1
$net.SetCategory(1)

#list active connections:
$nlm.GetNetworkConnections() | 
select @{n="Connectivity";e={$_.GetConnectivity()}}, 
@{n="DomainType";e={$_.GetDomainType()}}, 
@{n="Network";e={$_.GetNetwork().GetName()}}, 
IsConnectedToInternet,IsConnected

#register a ConnectivityChanged event:
# $nlm | gm –MemberType Event
# Register-ObjectEvent –InputObject $nlm –EventName ConnectivityChanged –Action { write-host "Connectivity Changed: $args" }

#monitor a connectivity change per network:
# Register-ObjectEvent -InputObject $nlm -EventName NetworkConnectivityChanged -Action { try { if($nlm.GetNetwork($args[0]).GetName() -match "YOW") { write-host ("YOW is now:" + $args[1]) } } catch {} }

#Via COM is also posssible but then you lose the events possibility
$nlm2 = [Activator]::CreateInstance([Type]::
GetTypeFromCLSID('DCB00C01-570F-4A9B-8D69-199FDBA5723B'))
$net = $nlm2.GetNetworks(1) | select -first 1
$net.SetCategory(1)
