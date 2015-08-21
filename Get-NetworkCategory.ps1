$cat = 'Public', 'Private', 'Domain'
$GUID = [guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}'
$network = [Activator]::CreateInstance([type]::GetTypeFromCLSID($GUID))
$network.GetNetworkConnections() |
  ForEach-Object {
    $result = $_ | Select-Object -Property Name, Description, *, Category
    $result.Name = $_.GetNetwork().GetName()
    $result.Description = $_.GetNetwork().GetDescription()
    $result.Category = $cat[$_.GetNetwork().GetCategory()]
    $result
}