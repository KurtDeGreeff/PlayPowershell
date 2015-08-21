#=============================================================================# 
#                                                                             # 
# Microsoft.DHCP.PowerShell.Admin.psm1                                        # 
# Powershell Module for DHCP Administration                                   # 
# Author: Jeremy Engel                                                        # 
# Creation Date: 12.16.2010                                                   # 
# Modified Date: 06.22.2011                                                   # 
# Version: 1.8.2                                                              # 
#                                                                             # 
#=============================================================================# 
 
Add-Type -TypeDefinition @" 
  public struct DHCPDNSConfiguration { 
    public string Level; 
    public bool AllowDynamicUpdate; 
    public string UpdateTrigger; 
    public bool DiscardStaleRecords; 
    public bool AllowLegacyClientUpdate; 
    public int Value; 
    public override string ToString() { 
      switch(Value) { 
        case -1: return (Level=="Server")?"(Default) Update by Client Request With Cleanup":"Inherited from Parent"; 
        case 0: return "Dynamic Updates Disabled"; 
        case 1: return "Update by Client Request Without Cleanup"; 
        case 2: return "Dynamic Updates Disabled"; 
        case 3: return "Update Legacy Clients and by Client Request Without Cleanup"; 
        case 4: return "Dynamic Updates Disabled"; 
        case 5: return "Update by Client Request With Cleanup"; 
        case 6: return "Dynamic Updates Disabled"; 
        case 7: return "Update Legacy Clients and by Client Request With Cleanup"; 
        case 16: return "Dynamic Updates Disabled"; 
        case 17: return "Always Update Clients Without Cleanup"; 
        case 18: return "Dynamic Updates Disabled"; 
        case 19: return "Always Update [Legacy] Clients Without Cleanup"; 
        case 20: return "Dynamic Updates Disabled"; 
        case 21: return "Always Update Clients With Cleanup"; 
        case 22: return "Dynamic Updates Disabled"; 
        case 23: return "Always Update [Legacy] Clients With Cleanup"; 
        default: return "Invalid Configuration"; 
        } 
      } 
    } 
 
  public struct DHCPFilter { 
    public string MACAddress; 
    public string Description; 
    public override string ToString() { return MACAddress; } 
    } 
 
  public struct DHCPFilterConfiguration { 
    public string Server; 
    public string AllowList; 
    public string DenyList; 
    public DHCPFilter[] AllowFilters; 
    public DHCPFilter[] DenyFilters;     
    public override string ToString() { return "AllowList - "+AllowList+"\r\nDenyList - "+DenyList; } 
    } 
 
  public struct DHCPIPRange { 
    public string StartAddress; 
    public string EndAddress; 
    public override string ToString() { return StartAddress+" - "+EndAddress; } 
    } 
   
  public struct DHCPOption { 
    public int OptionID; 
    public string OptionName; 
    public string ArrayType; 
    public string OptionType; 
    public string[] Values; 
    public string Level; 
    public override string ToString() { return OptionName; } 
    } 
 
  public struct DHCPReservation { 
    public string IPAddress; 
    public string MACAddress; 
    public string Scope; 
    public string Server; 
    public DHCPOption[] Options; 
    public DHCPDNSConfiguration DNSConfiguration; 
    public override string ToString() { return IPAddress; } 
    } 
 
  public struct DHCPScope { 
    public string Address; 
    public string SubnetMask; 
    public string Name; 
    public string Description; 
    public string State; 
    public string Server; 
    public DHCPIPRange[] IPRanges; 
    public DHCPIPRange[] ExclusionRanges; 
    public DHCPReservation[] Reservations; 
    public int Lease; 
    public DHCPOption[] Options; 
    public DHCPDNSConfiguration DNSConfiguration; 
    public override string ToString() { return Address; } 
    } 
 
  public struct DHCPServer { 
    public string Name; 
    public string IPAddress; 
    public DHCPDNSConfiguration DNSConfiguration; 
    public int ConflictDetectionAttempts; 
    public DHCPScope[] Scopes; 
    public DHCPOption[] Options; 
    public override string ToString() { return Name; } 
    } 
 
  public struct DHCPScopeStatistics { 
    public string Scope; 
    public string Server; 
    public int TotalAddresses; 
    public int UsedAddresses; 
    public int PendingOffers; 
    public override string ToString() { return Scope; } 
    } 
 
  public struct DHCPServerStatistics { 
    public string Server; 
    public int Discovers; 
    public int Offers; 
    public int Requests; 
    public int Acks; 
    public int Naks; 
    public int Declines; 
    public int Releases; 
    public System.DateTime StartTime; 
    public int Scopes; 
    public DHCPScopeStatistics[] ScopeStatistics; 
    public override string ToString() { return Server; } 
    } 
"@ 
 
function Add-DHCPExclusionRange { 
  <# 
    .Synopsis 
     Adds an exclusion range to a DHCP scope. 
    .Example 
     Add-DHCPExclusionRange -Server dhcp01.contoso.com -Scope 192.168.1.0 -StartAddress 192.168.1.200 -EndAddress 192.168.1.254 
     This example adds an exclusion range to the 192.168.1.0 scope on dhcp01.contoso.com that is between 192.168.1.200 and 192.168.1.254. 
    .Example 
     $scope | Add-DHCPExclusionRange -StartAddress 192.168.1.200 -EndAddress 192.168.1.254 
     Given that $scope is the DHCPScope object for subnet 192.168.1.0 on dhcp01.contoso.com, this example accomplishes the same as the one in Example 1. 
    .Description 
     The Add-DHCPExclusionRange cmdlet is used to define a new exclusion range within a given DHCP scope. The return value for success is the parent DHCPScope object. 
    .Parameter Server 
     The value for this parameter can be a DHCPServer object or the name or FQDN of the DHCP server. The designated server must by a valid DHCP server. 
    .Parameter Scope 
     The value for this parameter can be a DHCPScope object or the subnet address of the scope. If entering the subnet address, the Server parameter must be defined and be the host of this scope. 
 
     Note: This cmdlet will process significantly faster if the Scope variable supplied is a DHCPScope object. 
    .Parameter StartAddress 
     This parameter signifies the beginning of the range of IPs that you want excluded from the addresses available for lease. The value for this parameter must be in an IP address string format (ie: 0.0.0.0). 
    .Parameter EndAddress 
     This parameter signifies the end of the range of IPs that you want excluded from the addresses available for lease. The value for this parameter must be in an IP address string format (ie: 0.0.0.0). 
    .Outputs 
     DHCPScope 
    .Notes 
     Name:   Add-DHCPExclusionRange 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   12.16.2010 
  #> 
  Param([Parameter(Mandatory=$false)][PSObject]$Server, 
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][PSObject]$Scope, 
        [Parameter(Mandatory=$true)][ValidatePattern("\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b")][string]$StartAddress, 
        [Parameter(Mandatory=$true)][ValidatePattern("\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b")][string]$EndAddress 
        ) 
  if($Scope.GetType() -eq [DHCPScope] -and !$Server) { $Server = $Scope.Server } 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server \\$Server scope $Scope add excluderange $StartAddress $EndAddress") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("completed successfully")) { 
    if($Scope.GetType() -eq [DHCPScope]) { 
      $range = New-Object DHCPIPRange 
      $range.StartAddress = $StartAddress 
      $range.EndAddress = $EndAddress 
      $Scope.ExclusionRanges += $range 
      return $Scope 
      } 
    else { return Get-DHCPScope -Server $Server -Scope $Scope } 
    } 
  elseif($result.Contains("Server may not function properly")) { Write-Host "ERROR: $Server is inaccessible or is not a DHCP server." -ForeGroundColor Red } 
  elseif($result.Contains("The command needs a valid Scope IP Address")) { Write-Host "ERROR: $Scope is not a valid scope on $Server." -ForeGroundColor Red } 
  elseif($result.Contains("No items to display")) { Write-Host "ERROR: $Scope must first have a defined IP range!" -ForeGroundColor Red } 
  else { Write-Host "ERROR: $result" -ForeGroundColor Red } 
  if($Scope.GetType() -eq [DHCPScope]) { return $Scope } 
  } 
 
function Add-DHCPFilter { 
  <# 
    .Synopsis 
     Adds a MAC filter to the DHCP server. 
    .Example 
     Add-DHCPFilter -Server dhcp01.contoso.com -Deny -MACAddress 00-00-00-00-00 -Description "Example Filter" 
     Adds a deny filter for the given MAC address on dhcp01.contoso.com. 
    .Description 
     The Add-DHCPFilter cmdlet is used to add allow and deny MAC address filters to a given server. 
    .Parameter Server 
     The value for this parameter can be a DHCPServer object or the name or FQDN of the DHCP server. The designated server must by a valid DHCP server. 
     Note: This cmdlet will process significantly faster if the Server variable supplied is a DHCPServer object. 
    .Parameter Allow 
     This parameter defines the MAC address filter for the allow list. 
    .Parameter Deny 
     This parameter defines the MAC address filter for the deny list. 
    .Parameter MACAddress 
     This parameter defines the MAC address for the filter. The value for this parameter must be in one of three standard hardware address string formats: 
       00:00:00:00:00:00 
       00-00-00-00-00-00 
       000000000000 
    .Parameter Description 
     This parameter defines the description of the filter. 
    .Outputs 
     DHCPFilterConfiguration 
    .Notes 
     Name:   Add-DHCPFilter 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   06.16.2011 
  #> 
  Param([Parameter(Mandatory=$true)][PSObject]$Server, 
        [Parameter(Mandatory=$true,ParameterSetName="Allow")][switch]$Allow, 
        [Parameter(Mandatory=$true,ParameterSetName="Deny")][switch]$Deny, 
        [Parameter(Mandatory=$true)][ValidatePattern("([0-9a-fA-F]{2}[:-]{0,1}){5}[0-9a-fA-F]{2}")][string]$MACAddress, 
        [Parameter(Mandatory=$true)][string]$Description 
        ) 
  $MACAddress = $MACAddress.Replace("-","").Replace(":","") 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server \\$Server v4 add filter $(if($Allow){"allow"}else{"deny"}) $MACAddress `"$Description`"") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("completed successfully")) { 
    if($text.Count -ge 4 -and $text[3].Contains("not a valid DNS Server")) { Write-Host "ERROR: $($text[3])" -ForeGroundColor Red; return } 
    } 
  elseif($result.Contains("Server may not function properly")) { Write-Host "ERROR: $server is inaccessible or is not a DHCP server." -ForeGroundColor Red; return } 
  elseif($result.Contains("Address or Address pattern is already")) { Write-Host "ERROR: There is an existing $($PSCmdlet.ParameterSetName.ToLower()) filter for $MACAddress on $Server." -ForeGroundColor Red; return } 
  else { Write-Host "ERROR: $result" -ForeGroundColor Red; return } 
  return Get-DHCPFilterConfiguration -Server $Server 
  } 
 
function Add-DHCPIPRange { 
  <# 
    .Synopsis 
     Adds a range of IP addresses available for lease to a DHCP scope. 
    .Example 
     Add-DHCPIPRange -Server dhcp01.contoso.com -Scope 192.168.1.0 -StartAddress 192.168.1.30 -EndAddress 192.168.1.254 
     This example adds an ip range to the 192.168.1.0 scope on dhcp01.contoso.com that is between 192.168.1.30 and 192.168.1.254. 
    .Example 
     $scope | Add-DHCPIPRange -StartAddress 192.168.1.30 -EndAddress 192.168.1.254 
     Given that $scope is the DHCPScope object for subnet 192.168.1.0 on dhcp01.contoso.com, this example accomplishes the same as the one in Example 1. 
    .Description 
     The Add-DHCPIPRange cmdlet is used to define a new range of IP addresses available for lease within a given DHCP scope. The return value for success is the parent DHCPScope object. 
    .Parameter Server 
     The value for this parameter can be a DHCPServer object or the name or FQDN of the DHCP server. The designated server must by a valid DHCP server. 
    .Parameter Scope 
     The value for this parameter can be a DHCPScope object or the subnet address of the scope. If entering the subnet address, the Server parameter must be defined and be the host of this scope. 
 
     Note: This cmdlet will process significantly faster if the Scope variable supplied is a DHCPScope object. 
    .Parameter StartAddress 
     This parameter signifies the beginning of the range of IP addresses available for lease. The value for this parameter must be in an IP address string format (ie: 0.0.0.0). 
    .Parameter EndAddress 
     This parameter signifies the end of the range of IP addresses available for lease. The value for this parameter must be in an IP address string format (ie: 0.0.0.0). 
    .Outputs 
     DHCPScope 
    .Notes 
     Name:   Add-DHCPIPRange 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   12.16.2010 
  #> 
  Param([Parameter(Mandatory=$false)][PSObject]$Server, 
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][PSObject]$Scope, 
        [Parameter(Mandatory=$true)][ValidatePattern("\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b")][string]$StartAddress, 
        [Parameter(Mandatory=$true)][ValidatePattern("\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b")][string]$EndAddress 
        ) 
  if($Scope.GetType() -eq [DHCPScope] -and !$Server) { $Server = $Scope.Server } 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server \\$Server scope $Scope add iprange $StartAddress $EndAddress") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("completed successfully")) { 
    if($Scope.GetType() -eq [DHCPScope]) { 
      $range = New-Object DHCPIPRange 
      $range.StartAddress = $StartAddress 
      $range.EndAddress = $EndAddress 
      $Scope.IPRanges += $range 
      return $Scope 
      } 
    else { return Get-DHCPScope -Server $Server -Scope $Scope } 
    } 
  elseif($result.Contains("Server may not function properly")) { Write-Host "ERROR: $Server is inaccessible or is not a DHCP server." -ForeGroundColor Red } 
  elseif($result.Contains("The command needs a valid Scope IP Address")) { Write-Host "ERROR: $Scope is not a valid scope on $Server." -ForeGroundColor Red } 
  else { Write-Host "ERROR: $result" -ForeGroundColor Red } 
  if($Scope.GetType() -eq [DHCPScope]) { return $Scope } 
  } 
 
function Disable-DHCPScope { 
  <# 
    .Synopsis 
     Deactivates a given DHCP scope. 
    .Example 
     Disable-DHCPScope -Server dhcp01.contoso.com -Scope 192.168.1.0 
     This example deactivates the 192.168.1.0 scope on dhcp01.contoso.com. 
    .Example 
     $scope | Disable-DHCPScope 
     Given that $scope is the DHCPScope object for subnet 192.168.1.0 on dhcp01.contoso.com, this example accomplishes the same as the one in Example 1. 
    .Description 
     The Disable-DHCPScope cmdlet is used to deactivate scopes. The return value for success is the parent DHCPScope object. 
    .Parameter Server 
     The value for this parameter can be a DHCPServer object or the name or FQDN of the DHCP server. The designated server must by a valid DHCP server. 
    .Parameter Scope 
     The value for this parameter can be a DHCPScope object or the subnet address of the scope. If entering the subnet address, the Server parameter must be defined and be the host of this scope. 
 
     Note: This cmdlet will process significantly faster if the Scope variable supplied is a DHCPScope object. 
    .Parameter SwitchedNetwork 
     This is typically used for switched networks, or networks where multiple logical networks are hosted on a single physical network. 
    .Outputs 
     DHCPScope 
    .Notes 
     Name:   Disable-DHCPScope 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   12.16.2010 
  #> 
  Param([Parameter(Mandatory=$false)][PSObject]$Server, 
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][PSObject]$Scope, 
        [Parameter(Mandatory=$false)][switch]$SwitchedNetwork 
        ) 
  $val = if($SwitchedNetwork){2}else{0}  
  if($Scope.GetType() -eq [DHCPScope] -and !$Server) { $Server = $Scope.Server } 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server \\$Server scope $Scope set state $val") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("completed successfully")) { 
    if($Scope.GetType() -eq [DHCPScope]) { 
      $Scope.State = if($SwitchedNetwork){"Disabled(Switched)"}else{"Disabled"} 
      return $Scope 
      } 
    else { return Get-DHCPScope -Server $Server -Scope $Scope } 
    } 
  elseif($result.Contains("Server may not function properly")) { Write-Host "ERROR: $Server is inaccessible or is not a DHCP server." -ForeGroundColor Red } 
  elseif($result.Contains("The command needs a valid Scope IP Address")) { Write-Host "ERROR: $Scope is not a valid scope on $Server." -ForeGroundColor Red } 
  else { Write-Host "ERROR: $result" -ForeGroundColor Red } 
  if($Scope.GetType() -eq [DHCPScope]) { return $Scope } 
  } 
 
function Enable-DHCPScope { 
  <# 
    .Synopsis 
     Activates a given DHCP scope. 
    .Example 
     Enable-DHCPScope -Server dhcp01.contoso.com -Scope 192.168.1.0 
     This example activates the 192.168.1.0 scope on dhcp01.contoso.com. 
    .Example 
     $scope | Enable-DHCPScope 
     Given that $scope is the DHCPScope object for subnet 192.168.1.0 on dhcp01.contoso.com, this example accomplishes the same as the one in Example 1. 
    .Description 
     The Enable-DHCPScope cmdlet is used to activate scopes. The return value for success is the parent DHCPScope object. 
    .Parameter Server 
     The value for this parameter can be a DHCPServer object or the name or FQDN of the DHCP server. The designated server must by a valid DHCP server. 
    .Parameter Scope 
     The value for this parameter can be a DHCPScope object or the subnet address of the scope. If entering the subnet address, the Server parameter must be defined and be the host of this scope. 
      
     Note: This cmdlet will process significantly faster if the Scope variable supplied is a DHCPScope object. 
    .Parameter SwitchedNetwork 
     This is typically used for switched networks, or networks where multiple logical networks are hosted on a single physical network. 
    .Outputs 
     DHCPScope 
    .Notes 
     Name:   Enable-DHCPScope 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   12.16.2010 
  #> 
  Param([Parameter(Mandatory=$false)][PSObject]$Server, 
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][PSObject]$Scope, 
        [Parameter(Mandatory=$false)][switch]$SwitchedNetwork 
        ) 
  $val = if($SwitchedNetwork){3}else{1}  
  if($Scope.GetType() -eq [DHCPScope] -and !$Server) { $Server = $Scope.Server } 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server \\$Server scope $Scope set state $val") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("completed successfully")) { 
    if($Scope.GetType() -eq [DHCPScope]) { 
      $Scope.State = if($SwitchedNetwork){"Active(Switched)"}else{"Active"} 
      return $Scope 
      } 
    else { return Get-DHCPScope -Server $Server -Scope $Scope } 
    } 
  elseif($result.Contains("Server may not function properly")) { Write-Host "ERROR: $Server is inaccessible or is not a DHCP server." -ForeGroundColor Red } 
  elseif($result.Contains("The command needs a valid Scope IP Address")) { Write-Host "ERROR: $Scope is not a valid scope on $Server." -ForeGroundColor Red } 
  else { Write-Host "ERROR: $result" -ForeGroundColor Red } 
  if($Scope.GetType() -eq [DHCPScope]) { return $Scope } 
  } 
 
function Get-DHCPDNSConfiguration { 
  <# 
    .Synopsis 
     Retrieves the DNS update configuration for a given DHCP object. 
    .Example 
     Get-DHCPDNSConfiguration -Owner dhcp01.contoso.com/192.168.1.0/192.168.1.237 
     This example retrieves the DNS update configuration for the reservation 192.168.1.237 in the scope of 192.168.1.0 on server dhcp01.contoso.com. 
    .Description 
     The Get-DHCPDNSConfiguration cmdlet is used to retrieve the DNS update configuration for a given DHCP server, scope, or reservation. If no configuration is defined, then the configuration from its parent is inherited, except at the server level, which uses the default configuration. 
    .Parameter Owner 
     The value for this parameter can be a DHCPServer, DHCPScope, or DHCPReservation object. It can also be a string representation of these objects, defined thus: 
       ServerNameOrFQDN 
       ServerNameOrFQDN/ScopeAddress 
       ServerNameOrFQDN/ScopeAddress/ReservationAddress 
    .Outputs 
     DHCPDNSConfiguration 
    .Notes 
     Name:   Get-DHCPDNSConfiguration 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   04.22.2011 
  #> 
  Param([Parameter(Mandatory=$true,ValueFromPipeline=$true)][PSObject]$Owner) 
  if($Owner.GetType() -eq [string]) { 
    switch($Owner.Split("/").Count) { 
      1 { $level = "Server" } 
      2 { $level = "Scope" } 
      3 { $level = "Reservation" } 
      default { return } 
      } 
    } 
  else { $level = $Owner.GetType().ToString().Substring(4) } 
  if(!($option = Get-DHCPOption -Owner $Owner -OptionID 81 -Force)) { return } 
  $value = [int]$option.Values[0] 
  $dnsConfig = New-Object DHCPDNSConfiguration 
  $dnsConfig.Level = $level 
  $dnsConfig.Value = $value 
  if($value -eq -1) {  
    if($level -ne "Server") { 
      if($Owner.GetType() -eq [string]) { 
        $parts = $Owner.Split("/") 
        $Owner = $parts[0..($parts.Count-2)] -Join "/" 
        } 
      elseif($Owner.GetType() -eq [DHCPReservation]) { $Owner = "$($Owner.Server)/$($Owner.Scope)" } 
      elseif($Owner.GetType() -eq [DHCPScope]) { $Owner = $Owner.Server } 
      else { return } 
      $dnsConfig = Get-DHCPDNSConfiguration -Owner $Owner 
      $dnsConfig.Level = $level 
      return $dnsConfig 
      } 
    else { $value = 5 } 
    } 
  if($value -ge 16) { 
    $dnsConfig.UpdateTrigger = "Always" 
    $value -= 16 
    } 
  else { $dnsConfig.UpdateTrigger = "ClientRequest" } 
  if($value -ge 4) { 
    $dnsConfig.DiscardStaleRecords = $true 
    $value -= 4 
    } 
  else { $dnsConfig.DiscardStaleRecords = $false } 
  if($value -ge 2) { 
    $dnsConfig.AllowLegacyClientUpdate = $true 
    $value -= 2 
    } 
  else { $dnsConfig.AllowLegacyClientUpdate = $false } 
  $dnsConfig.AllowDynamicUpdate = if($value -eq 1){$true}else{$false} 
  return $dnsConfig 
  } 
 
function Get-DHCPFilters { 
  Param([string[]]$Text,[int]$Start) 
  $filters = @() 
  for($i=$Start;$i -lt $Text.Count;$i++) { 
    $parts = $Text[$i].Split("`t") | %{ $_.Trim() } 
    if($parts.Count -ne 4) { break } 
    $filter = New-Object DHCPFilter 
    $filter.MACAddress = $parts[2] 
    $filter.Description = $parts[3] 
    $filters += $filter 
    } 
  return $filters 
  } 
 
function Get-DHCPFilterConfiguration { 
  <# 
    .Synopsis 
     Gets the MAC Filter configuration for a given DHCP server. 
    .Example 
     Get-DHCPFilterConfiguration -Server dhcp01.contoso.com 
     Returns the Filter configuration for dhcp01.contoso.com. 
    .Description 
     The Get-DHCPFilterConfiguration cmdlet is used to retrieve the Allow and Deny MAC address filter configuration. 
    .Parameter Server 
     The value for this parameter can be a DHCPServer object or the name or FQDN of the DHCP server. The designated server must by a valid DHCP server. 
     Note: This cmdlet will process significantly faster if the Server variable supplied is a DHCPServer object. 
    .Outputs 
     DHCPFilterConfiguration 
    .Notes 
     Name:   Get-DHCPFilterConfiguration 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   06.16.2011 
  #> 
  Param([Parameter(Mandatory=$true)][PSObject]$Server) 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server \\$Server v4 show filter") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("completed successfully")) { 
    if($text[3].Contains("not a valid DNS Server")) { Write-Host "ERROR: $($text[3])" -ForeGroundColor Red; return } 
    } 
  elseif($result.Contains("Server may not function properly")) { Write-Host "ERROR: $server is inaccessible or is not a DHCP server." -ForeGroundColor Red; return } 
  else { Write-Host "ERROR: $result" -ForeGroundColor Red; return } 
  $filterConfig = New-Object DHCPFilterConfiguration 
  $filterConfig.Server = "$Server" 
  $filterConfig.AllowList = if($($text[9].Split("=") | %{ $_.Trim() })[1] -eq "1"){"Enabled"}else{"Disabled"} 
  $filterConfig.DenyList = if($($text[10].Split("=") | %{ $_.Trim() })[1] -eq "1"){"Enabled"}else{"Disabled"} 
  $filterConfig.AllowFilters = Get-DHCPFilters -Text $text -Start 19 
  for($i=20;$i -lt $text.Count;$i++) { if($text[$i].Contains("Total No. of MAC")) { break } } 
  $filterConfig.DenyFilters = Get-DHCPFilters -Text $text -Start ($i+7) 
  return $filterConfig 
  } 
 
 
function Get-DHCPIPRanges { 
  Param([Parameter(Mandatory=$false)][PSObject]$Server, 
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][PSObject]$Scope, 
        [Parameter(Mandatory=$true)][string]$Type 
        ) 
  $ipranges = @() 
  if($Scope.GetType() -eq [DHCPScope] -and !$Server) { $Server = $Scope.Server } 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server \\$Server scope $Scope show $Type") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("The command needs a valid Scope IP Address")) { Write-Host "ERROR: $Scope is not a valid scope on $Server." -ForeGroundColor Red; return } 
  if($result.Contains("Server may not function properly")) { Write-Host "ERROR: $Server is inaccessible or is not a DHCP server." -ForeGroundColor Red; return } 
  for($i=6;$i -lt $text.Count;$i++) { 
    if(!$text[$i]) { break } 
    $parts = $text[$i].Split("-") | %{ $_.Trim() } 
    $ipRange = New-Object DHCPIPRange 
    $ipRange.StartAddress = $parts[0] 
    $ipRange.EndAddress = $parts[1] 
    $ipRanges += $ipRange 
    } 
  return $ipRanges 
  } 
 
function Get-DHCPOption { 
  <# 
    .Synopsis 
     Retrieves all or specific DHCP options and their values for a given level. 
    .Example 
     Get-DHCPOption -Owner dhcp01.contoso.com/192.168.1.0/192.168.1.237 
     This example retrieves all the options set for the reservation 192.168.1.237 in the scope of 192.168.1.0 on server dhcp01.contoso.com. 
    .Example 
     $scope | Get-DHCPOption -OptionID 3 
     Given that $scope is the DHCPScope object for subnet 192.168.1.0 on dhcp01.contoso.com, this examples retrieves scope option 3, the gateway address. 
    .Example 
     Get-DHCPOption -Owner $server -OptionID 81 -Force 
     Given that $server is the DHCPServer object for dhcp01.contoso.com, this example retrieves server option 81, dynamic dns configuration. For more information on why the -Force parameter was needed, please read its parameter 
     description under -full. 
    .Description 
     The Get-DHCPOption cmdlet is used to retrieve all or specific standard DHCP options and their values for a given server, scope, or reservation. Non-standard classes (eg: BOOTP) are not currently being recorded. The return value for success is one or an array of DHCPOption objects. 
    .Parameter Owner 
     The value for this parameter can be a DHCPServer, DHCPScope, or DHCPReservation object. It can also be a string representation of these objects, defined thus: 
       ServerNameOrFQDN 
       ServerNameOrFQDN/ScopeAddress 
       ServerNameOrFQDN/ScopeAddress/ReservationAddress 
    .Parameter OptionID 
     The value for this parameter must be the id of a valid DHCP option as listed by Get-DHCPOptionDefinitions. 
    .Parameter Force 
     This switch parameter is only needed if you want to retrieve options 51 (lease time in seconds) or 81 (int value for the dynamic dns configuration). These are otherwise not returned as their values are expressed elsewhere. 
    .Outputs 
     DHCPOption 
    .Notes 
     Name:   Get-DHCPOption 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   12.16.2010 
  #> 
  Param([Parameter(Mandatory=$true,ValueFromPipeline=$true)][PSObject]$Owner, 
        [Parameter(Mandatory=$false)][ValidateRange(1,254)][int]$OptionID, 
        [Parameter(Mandatory=$false)][switch]$Force 
        ) 
  $server = $null 
  $scope = $null 
  $reservation = $null 
  if($Owner.GetType() -eq [DHCPServer]) { $server = $Owner.Name } 
  elseif($Owner.GetType() -eq [DHCPScope]) { 
    $server = $Owner.Server 
    $scope = $Owner.Address 
    } 
  elseif($Owner.GetType() -eq [DHCPReservation]) { 
    $server = $Owner.Server 
    $scope = $Owner.Scope 
    $reservation = $Owner.IPAddress 
    } 
  else { 
    $parts = $Owner.ToString().Split("/") 
    $server = $parts[0] 
    if($parts.Count -gt 1) { $scope = $parts[1] } 
    if($parts.Count -gt 2) { $reservation = $parts[2] } 
    } 
  $command = if($scope){"\\$server scope $scope show optionvalue"}else{"\\$server show optionvalue"} 
  if($reservation) { $command = "\\$server scope $scope show reservedoptionvalue $reservation" } 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server $command") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("Server may not function properly")) { Write-Host "ERROR: $server is inaccessible or is not a DHCP server." -ForeGroundColor Red; return } 
  if($result.Contains("The command needs a valid Scope IP Address")) { Write-Host "ERROR: $scope is not a valid scope on $server." -ForeGroundColor Red; return }     
  if($result.Contains("client is not a reserved")) { Write-Host "ERROR: $reservation is not a valid reservation in $scope on $server." -ForeGroundColor Red; return } 
  $options = @() 
  $work = @{} 
  $optiondefs = Get-DHCPOptionDefinitions -Server $server 
  $option = New-Object PSOBject 
  $option | Add-Member NoteProperty OptionName("DNS Configuration") 
  $option | Add-Member NoteProperty ArrayType("UNARY") 
  $option | Add-Member NoteProperty OptionType("DWORD") 
  $optiondefs.Add(81,$option) 
  $id = $null 
  $block = $false 
  for($i=0;$i -lt $text.Count;$i++) { 
    if($text[$i] -eq "Command completed successfully.") { 
      if(!!$id) { 
        $option = New-Object DHCPOption 
        $option.OptionID = $id 
        $option.OptionName = $optiondefs[$id].OptionName 
        $option.ArrayType = $optiondefs[$id].ArrayType 
        $option.OptionType = $optiondefs[$id].OptionType 
        $option.Values += $work[$optiondefs[$id].OptionName] 
        $option.Level = if($reservation){"Reservation"}elseif($scope){"Scope"}else{"Server"} 
        $options += $option 
        } 
      } 
    if($block) { 
      if($text[$i].Contains("DHCP Standard Options")) { $block = $false } 
      continue 
      } 
    if($text[$i].Contains("For vendor class") -or $text[$i].Contains("For user class")) { $block = $true; continue } 
    if($text[$i].Contains("OptionId")) { 
      if(!!$id) { 
        $option = New-Object DHCPOption 
        $option.OptionID = $id 
        $option.OptionName = $optiondefs[$id].OptionName 
        $option.ArrayType = $optiondefs[$id].ArrayType 
        $option.OptionType = $optiondefs[$id].OptionType 
        $option.Values += $work[$optiondefs[$id].OptionName] 
        $option.Level = if($reservation){"Reservation"}elseif($scope){"Scope"}else{"Server"} 
        $options += $option 
        } 
      $id = [int]($text[$i].Split(":")[1].Trim()) 
      if($OptionID -and $OptionID -ne $id) { $id = $null; continue } 
      if(!$Force -and ($id -eq 81 -or $id -eq 51)) { $id = $null; continue } 
      $work.Add($optiondefs[$id].OptionName,$null) 
      } 
    elseif(!$id) { continue } 
    else { 
      if(!($text[$i].Contains("Option Element Value"))) { continue } 
      $desc = $optiondefs[$id].OptionName 
      $type = $optiondefs[$id].ArrayType 
      $values = $work[$desc] 
      $val = $text[$i].Split("=")[1].Trim() 
      if($type-eq"ARRAY") { $values += @($val) } 
      else { $values = $val } 
      $work[$desc] = $values 
      } 
    } 
  if($Force -and !($options | Where-Object { $_.OptionID -eq 81 }) -and $OptionID -eq 81) { 
    $id = 81 
    $option = New-Object DHCPOption 
    $option.OptionID = $id 
    $option.OptionName = $optiondefs[$id].OptionName 
    $option.ArrayType = $optiondefs[$id].ArrayType 
    $option.OptionType = $optiondefs[$id].OptionType 
    $option.Values += -1 
    $option.Level = if($reservation){"Reservation"}elseif($scope){"Scope"}else{"Server"} 
    $options += $option 
    } 
  return $options 
  } 
 
function Get-DHCPOptionDefinitions { 
  <# 
    .Synopsis 
     Retrieves all DHCP options defined on a given server. 
    .Example 
     Get-DHCPOptionDefinitions -Server dhcp01.contoso.com 
     This example retrieves all the options defined on server dhcp01.contoso.com. 
    .Example 
     $server | Get-DHCPOptionDefinitions 
     Given that $server is the DHCPServer object for dhcp01.contoso.com, this example accomplishes the same as the one in Example 1. 
    .Description 
     The Get-DHCPOptionDefinitions cmdlet is used to retrieve all DHCP options defined on a given server. 
    .Parameter Server 
     The value for this parameter can be a DHCPServer object or the name or FQDN of the DHCP server. The designated server must by a valid DHCP server. 
    .Outputs 
     HashTable 
    .Notes 
     Name:   Get-DHCPOptionDefinitions 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   12.16.2010 
  #> 
  Param([Parameter(Mandatory=$true,ValueFromPipeline=$true)][PSObject]$Server) 
  $options = @{} 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server \\$Server show optiondef") 
  if($text[2].Contains("Server may not function properly")) { Write-Host "ERROR: $Server is inaccessible or is not a DHCP server." -ForeGroundColor Red; return } 
  for($i=7;$i -lt $text.Count;$i++) { 
    if(!$text[$i]) { break } 
    $parts = $text[$i].Split("-") | %{ $_.Trim() } 
    if($parts[2] -eq "to") { 
      $parts[1] = $parts[1]+"-"+$parts[2]+"-"+$parts[3] 
      $parts[2] = $parts[4] 
      $parts[3] = $parts[5] 
      } 
    $option = New-Object PSOBject 
    $option | Add-Member NoteProperty OptionName($parts[1]) 
    $option | Add-Member NoteProperty ArrayType($parts[2]) 
    $option | Add-Member NoteProperty OptionType($parts[3]) 
    if($options.Keys -notcontains [int]$parts[0]) { $options.Add([int]$parts[0],$option) } #Needed if clause for some weird funkiness on Windows 2003 servers 
    } 
  return $options 
  } 
 
function Get-DHCPReservation { 
  <# 
    .Synopsis 
     Retieves all or specific DHCP reservations for a given scope. 
    .Example 
     Get-DHCPReservation -Server dhcp01.contoso.com -Scope 192.168.1.0 
     This example retrieves all reservations in the 192.168.1.0 scope on dhcp01.contoso.com. 
    .Example 
     $scope | Get-DHCPReservation -IPAddress 192.168.1.237 
     Given that $scope is the DHCPScope object for subnet 192.168.1.0 on dhcp01.contoso.com, this example retrieves the 192.168.1.237 reservation. 
    .Description 
     The Get-DHCPReservation cmdlet is used to retieves all or specific DHCP reservations for a given scope. The return value for success is one or an array of DHCPReservation objects. 
    .Parameter Server 
     The value for this parameter can be a DHCPServer object or the name or FQDN of the DHCP server. The designated server must by a valid DHCP server. 
    .Parameter Scope 
     The value for this parameter can be a DHCPScope object or the subnet address of the scope. If entering the subnet address, the Server parameter must be defined and be the host of this scope. 
    .Parameter IPAddress 
     The value for this parameter must be in an IP address string format (ie: 0.0.0.0). 
    .Outputs 
     DHCPReservation 
    .Notes 
     Name:   Get-DHCPReservation 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   12.16.2010 
  #> 
  Param([Parameter(Mandatory=$false)][PSObject]$Server, 
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][PSObject]$Scope, 
        [Parameter(Mandatory=$false)][ValidatePattern("\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b")][string]$IPAddress 
        ) 
  $reservations = @() 
  if($Scope.GetType() -eq [DHCPScope] -and !$Server) { $Server = $Scope.Server } 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server \\$Server scope $Scope show reservedip") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("The command needs a valid Scope IP Address")) { Write-Host "ERROR: $Scope is not a valid scope on $Server." -ForeGroundColor Red; return } 
  if($result.Contains("Server may not function properly")) { Write-Host "ERROR: $Server is inaccessible or is not a DHCP server." -ForeGroundColor Red; return } 
  for($i=7;$i -lt $text.Count;$i++) { 
    if(!$text[$i]) { break } 
    $parts = $text[$i].Split("-") | %{ $_.Trim() } 
    if($IPAddress -and $parts[0] -ne $IPAddress) { continue } 
    $reservation = New-Object DHCPReservation 
    $reservation.IPAddress = $parts[0] 
    $reservation.MACAddress = [string]::Join("-",$parts[1..6]) 
    $reservation.Scope = $Scope 
    $reservation.Server = $Server 
    $reservation.Options = Get-DHCPOption -Owner $reservation 
    $reservation.DNSConfiguration = Get-DHCPDNSConfiguration -Owner $reservation 
    $reservations += $reservation 
    } 
  return $reservations 
  } 
 
function Get-DHCPScope { 
  <# 
    .Synopsis 
     Retieves all or specifics scopes for a given server. 
    .Example 
     Get-DHCPScope -Server dhcp01.contoso.com 
     This example retrieves all scopes on dhcp01.contoso.com. 
    .Example 
     $server | Get-DHCPScope -Scope 192.168.1.0 
     Given that $server is the DHCPServer object for dhcp01.contoso.com, this example retrieves the scope 192.168.1.0. 
    .Description 
     The Get-DHCPScope cmdlet is used to retieves all or specific DHCP scopes on a given server. The return value for success is one or an array of DHCPScope objects. 
    .Parameter Server 
     The value for this parameter can be a DHCPServer object or the name or FQDN of the DHCP server. The designated server must by a valid DHCP server. 
    .Parameter Scope 
     The value for this parameter must be the subnet address of the scope. 
    .Outputs 
     DHCPScope 
    .Notes 
     Name:   Get-DHCPScope 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   12.16.2010 
  #> 
  Param([Parameter(Mandatory=$true,ValueFromPipeline=$true)][PSObject]$Server, 
        [Parameter(Mandatory=$false)][string]$Scope 
        ) 
  $dhcpScopes = @() 
  $scopeList = @{} 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server \\$Server show scope") 
  if($text[2].Contains("Server may not function properly")) { Write-Host "ERROR: $Server is inaccessible or is not a DHCP server." -ForeGroundColor Red; return } 
  for($i=5;$i -lt $text.Count;$i++) { 
    if(!$text[$i]) { break } 
    $parts = $text[$i].Split("-") | %{ $_.Trim() } 
    $scopeList.Add($parts[0],@($parts[1],$parts[2],$parts[3],$parts[4])) 
    } 
  foreach($address in $scopeList.Keys) { 
    if($Scope -and $address -ne $Scope) { continue } 
    $dhcpScope = New-Object DHCPScope 
    $dhcpScope.Address = $address 
    $dhcpScope.Server = $Server.ToString() 
    $dhcpScope.SubnetMask = $scopeList[$address][0] 
    $dhcpScope.State = $scopeList[$address][1] 
    $dhcpScope.Name = $scopeList[$address][2] 
    $dhcpScope.Description = $scopeList[$address][3] 
    $dhcpScope.IPRanges = Get-DHCPIPRanges -Server $Server -Scope $address -Type "ipRange" 
    $dhcpScope.ExclusionRanges = Get-DHCPIPRanges -Server $Server -Scope $address -Type "excluderange" 
    $dhcpScope.Reservations = Get-DHCPReservation -Server $Server -Scope $address 
    $lease = Get-DHCPOption -Owner $dhcpScope -OptionID 51 -Force 
    $dhcpScope.Lease = if($lease){$lease.Values[0]}else{0} 
    $dhcpScope.Options = Get-DHCPOption -Owner $dhcpScope 
    $dhcpScope.DNSConfiguration = Get-DHCPDNSConfiguration -Owner $dhcpScope 
    $dhcpScopes += $dhcpScope 
    } 
  return $dhcpScopes 
  } 
 
function Get-DHCPServer { 
  <# 
    .Synopsis 
     Retieves a specific DHCP server, or all DHCP servers in the current domain. 
    .Example 
     Get-DHCPServer -Server dhcp01.contoso.com 
     This example retrieves the DHCP server object for dhcp01.contoso.com. 
    .Description 
     The Get-DHCPServer cmdlet is used to retieve a specific DHCP server, or all DHCP servers in the current domain. The return value for success is one or an array of DHCPServer objects. 
 
     Note: Due to the nature of calling netsh commands from powershell, this cmdlet can take an exceptionally long time to complete. 
    .Parameter Server 
     The value for this parameter must be the name or FQDN of the DHCP server. 
    .Outputs 
     DHCPServer 
    .Notes 
     Name:   Get-DHCPServer 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   12.16.2010 
  #> 
  Param([Parameter(Mandatory=$true,ValueFromPipeline=$true)][string]$Server) 
  $dhcpServers = @() 
  if(!$Server) { 
    $configDN = ([adsi]"LDAP://RootDSE").configurationNamingContext 
    $objADSearch = New-Object System.DirectoryServices.DirectorySearcher 
    $objADSearch.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry("LDAP://CN=NetServices,CN=Services,$configDN") 
    $objADSearch.PageSize = 1000 
    $objADSearch.Filter = "(&(objectClass=dhcpClass)(dhcpIdentification=DHCP Server object))" 
    $objADSearch.SearchScope = "OneLevel" 
    $serverList = $objADSearch.FindAll() | %{ $_.Properties["cn"][0] } 
    } 
  else { 
    $result = $(Invoke-Expression "cmd /c netsh dhcp server \\$Server") 
    if($result -is [array] -and $result[0].Contains("Lists all the commands available")) { $serverList = @($Server) } 
    else { Write-Host "ERROR: $Server is inaccessible or is not a DHCP server." -ForeGroundColor Red } 
    } 
  foreach($name in $serverList) { 
    $dhcpServer = New-Object DHCPServer 
    $dhcpServer.Name = $name 
    $text = $(Invoke-Expression "cmd /c netsh dhcp server \\$name show server") 
    if($text[2].Contains("Server may not function properly")) { Write-Host "ERROR: $Server is inaccessible or is not a DHCP server." -ForeGroundColor Red; continue } 
    else { $dhcpServer.IPAddress = $text[2].Split("=")[1].Trim() } 
    $dhcpServer.DNSConfiguration = Get-DHCPDNSConfiguration -Owner $dhcpServer 
    $text = $(Invoke-Expression "cmd /c netsh dhcp server \\$name show detectconflictretry") 
    if($text[2].Contains("Server may not function properly")) { Write-Host "ERROR: $Server is inaccessible or is not a DHCP server." -ForeGroundColor Red; continue } 
    else { $dhcpServer.ConflictDetectionAttempts = [int]($text[1].Split(":")[1].Trim()) } 
    $dhcpServer.Scopes = Get-DHCPScope -Server $name 
    $dhcpServer.Options = Get-DHCPOption -Owner $name 
    $dhcpServers += $dhcpServer 
    } 
  return $dhcpServers 
  } 
 
function Get-DHCPStatistics { 
  <# 
    .Synopsis 
     Retieves the DHCP statistics of a specific server. 
    .Example 
     Get-DHCPStatistics -Server dhcp01.contoso.com 
     This example retrieves the DHCP statistics for dhcp01.contoso.com. 
    .Example 
     $server | Get-DHCPStatistics 
     Given that $server is the DHCPServer object for dhcp01.contoso.com, this example accomplishes the same as the one in Example 1. 
    .Description 
     The Get-DHCPStatistics cmdlet is used to retieve the DHCP statistics of a specific server and its scopes. The return value for success is a DHCPStatistics object. 
    .Parameter Server 
     The value for this parameter can be a DHCPServer object or the name or FQDN of the DHCP server. The designated server must by a valid DHCP server. 
    .Outputs 
     DHCPStatistics 
    .Notes 
     Name:   Get-DHCPStatistics 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   12.16.2010 
  #> 
  Param([Parameter(Mandatory=$true,ValueFromPipeline=$true)][PSObject]$Server) 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server \\$Server show mibinfo") 
  if($text[2].Contains("Server may not function properly")) { Write-Host "ERROR: $Server is inaccessible or is not a DHCP server." -ForeGroundColor Red; return } 
  $serverStats = New-Object DHCPServerStatistics 
  $serverStats.Server = "$Server" 
  for($i=2;$i-lt$text.Count;$i++) { 
    if(!$text[$i]) { break } 
    $parts = $text[$i].Split("=") | %{ $_.Trim().Trim(".") } 
    switch($parts[0]) { 
      "Discovers"       { $serverStats.Discovers = [int]$parts[1] } 
      "Offers"          { $serverStats.Offers = [int]$parts[1] } 
      "Requests"        { $serverStats.Requests = [int]$parts[1] } 
      "Acks"            { $serverStats.Acks = [int]$parts[1] } 
      "Naks"            { $serverStats.Naks = [int]$parts[1] } 
      "Declines"        { $serverStats.Declines = [int]$parts[1] } 
      "Releases"        { $serverStats.Releases = [int]$parts[1] } 
      "ServerStartTime" { $serverStats.StartTime = [DateTime]$parts[1] } 
      "Scopes"          { $serverStats.Scopes = [int]$parts[1] } 
      "Subnet"          { 
        $scopeStats = New-Object DHCPScopeStatistics 
        $scopeStats.Scope = $parts[1] 
        $scopeStats.Server = "$Server" 
        $parts = $text[++$i].Split("=") | %{ $_.Trim().Trim(".") } 
        $used = [int]$parts[1] 
        $parts = $text[++$i].Split("=") | %{ $_.Trim().Trim(".") } 
        $scopeStats.TotalAddresses = $used+[int]$parts[1] 
        $scopeStats.UsedAddresses = $used 
        $parts = $text[++$i].Split("=") | %{ $_.Trim().Trim(".") } 
        $scopeStats.PendingOffers = [int]$parts[1] 
        $serverStats.ScopeStatistics += $scopeStats 
        } 
      } 
    } 
  return $serverStats 
  } 
 
function New-DHCPOptionDefinition { 
  <# 
    .Synopsis 
     Creates a new option on a given server. 
    .Example 
     New-DHCPOptionDefinition -Server dhcp01.contoso.com -OptionID 200 -Name TestOption -DataType IPADDRESS -IsArray 
     This example creates option 200 on server dhcp01.contoso.com with the name, TestOption, and an accepted value as an array of IP addresses. 
    .Example 
     $server | New-DHCPOptionDefinition -OptionID 200 -Name TestOption -DataType IPADDRESS -IsArray -Description "A test option." 
     Given that $server is the DHCPServer object for dhcp01.contoso.com, this example accomplishes the same as the one in Example 1 with a description too. 
    .Description 
     The New-DHCPOptionDefinition cmdlet is used to create a new option on a given server. 
    .Parameter Server 
     The value for this parameter can be a DHCPServer object or the name or FQDN of the DHCP server. The designated server must by a valid DHCP server. 
    .Parameter OptionID 
     An integer between 1 and 254 that is not currently used by another option. 
    .Parameter Name 
     A self-explanatory string value. 
    .Parameter DataType 
     A string value for the data type of the value(s). 
     The available options are: 
       BYTE 
       WORD 
       DWORD 
       STRING 
       IPADDRESS 
    .Parameter IsArray 
     A boolean value for whether the accepted value is unary or an array. 
    .Parameter VendorClass 
     A string value for the name of the vendor class of DHCP options. If none is given, the Standard DHCP Options class is used. 
    .Parameter UserClass 
     A string value for the name of the user class of the DHCP option. If none is given, the Default User Class is used. 
    .Parameter DefaultValue 
     A string value for the initial value of the option, if not explicitly defined by an admin. 
    .Outputs 
     Success = String message 
     Failure = NULL 
    .Notes 
     Name:   New-DHCPOptionDefinition 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   12.16.2010 
  #> 
  Param([Parameter(Mandatory=$true,ValueFromPipeline=$true)][PSObject]$Server, 
        [Parameter(Mandatory=$true)][ValidateRange(1,254)][int]$OptionID, 
        [Parameter(Mandatory=$true)][string]$Name, 
        [Parameter(Mandatory=$true)][ValidateSet("BYTE","WORD","DWORD","STRING","IPADDRESS")][string]$DataType, 
        [Parameter(Mandatory=$false)][switch]$IsArray, 
        [Parameter(Mandatory=$false)][string]$VendorClass, 
        [Parameter(Mandatory=$false)][string]$Description, 
        [Parameter(Mandatory=$false)][string]$DefaultValue 
        ) 
  $arrayInt = if($IsArray){1}else{0} 
  if(!!$VendorClass) { $VendorClass = "vendor=`"$VendorClass`"" } 
  if(!!$Description) { $Description = "comment=`"$Description`"" } 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server \\$Server add optiondef $OptionID `"$Name`" $DataType $arrayInt $VendorClass $Description `"$DefaultValue`"") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("completed successfully")) { return $result } 
  elseif($result.Contains("Server may not function properly")) { Write-Host "ERROR: $Server is inaccessible or is not a DHCP server." -ForeGroundColor Red } 
  else { Write-Host "ERROR: $result" -ForeGroundColor Red } 
  } 
 
function New-DHCPReservation { 
  <# 
    .Synopsis 
     Creates a new reservation within a given scope. 
    .Example 
     New-DHCPReservation -Server dhcp01.contoso.com -Scope 192.168.1.0 -IPAddress 192.168.1.237 -MACAddress 00:00:00:00:00:00 
     This example adds a reservation to the 192.168.1.0 scope on dhcp01.contoso.com for the IP address of 192.168.1.237. 
    .Example 
     $scope | New-DHCPReservation -IPAddress 192.168.1.237 -MACAddress 00-00-00-00-00-00 
     Given that $scope is the DHCPScope object for subnet 192.168.1.0 on dhcp01.contoso.com, this example accomplishes the same as the one in Example 1. 
    .Description 
     The New-DHCPReservation cmdlet is used to create a new reservation within a given scope. The return value for success is the parent DHCPReservation object. 
    .Parameter Server 
     The value for this parameter can be a DHCPServer object or the name or FQDN of the DHCP server. The designated server must by a valid DHCP server. 
    .Parameter Scope 
     The value for this parameter can be a DHCPScope object or the subnet address of the scope. If entering the subnet address, the Server parameter must be defined and be the host of this scope. 
    .Parameter IPAddress 
     The value for this parameter must be in an IP address string format (ie: 0.0.0.0). 
    .Parameter MACAddress 
     The value for this parameter must be in one of three standard hardware address string formats: 
       00:00:00:00:00:00 
       00-00-00-00-00-00 
       000000000000 
    .Parameter Name 
     A string value temporarily assigned to the unused reservation. Once the reservation is active however, its name will change to the client's. 
    .Parameter Description 
     A self-explanatory string value. 
    .Outputs 
     DHCPReservation 
    .Notes 
     Name:   New-DHCPReservation 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   12.16.2010 
  #> 
  Param([Parameter(Mandatory=$false)][PSObject]$Server, 
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][PSObject]$Scope, 
        [Parameter(Mandatory=$true)][ValidatePattern("\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b")][string]$IPAddress, 
        [Parameter(Mandatory=$true)][ValidatePattern("([0-9a-fA-F]{2}[:-]{0,1}){5}[0-9a-fA-F]{2}")][string]$MACAddress, 
        [Parameter(Mandatory=$false)][string]$Name, 
        [Parameter(Mandatory=$false)][string]$Description 
        ) 
  if($Scope.GetType() -eq [DHCPScope] -and !$Server) { $Server = $Scope.Server } 
  $MACAddress = $MACAddress.Replace("-","").Replace(":","") 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server \\$Server scope $Scope add reservedip $IPAddress $MACAddress `"$Name`" `"$Description`"") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("completed successfully")) { return Get-DHCPReservation -Server $Server -Scope $Scope -IPAddress $IPAddress } 
  elseif($result.Contains("Server may not function properly")) { Write-Host "ERROR: $Server is inaccessible or is not a DHCP server." -ForeGroundColor Red } 
  elseif($result.Contains("The command needs a valid Scope IP Address")) { Write-Host "ERROR: $Scope is not a valid scope on $Server." -ForeGroundColor Red } 
  else { Write-Host "ERROR: $result" -ForeGroundColor Red } 
  } 
 
function New-DHCPScope { 
  <# 
    .Synopsis 
     Creates a new scope on a given server. 
    .Example 
     New-DHCPScope -Server dhcp01.contoso.com -Address 192.168.1.0 -SubnetMask 255.255.255.0 -Name TestScope 
     This example adds a scope for the subnet 192.168.1.0/24 on dhcp01.contoso.com. 
    .Example 
     $server | New-DHCPScope -Address 192.168.1.0 -SubnetMask 255.255.255.0 -Name TestScope 
     Given that $scope is the DHCPScope object for subnet 192.168.1.0 on dhcp01.contoso.com, this example accomplishes the same as the one in Example 1. 
    .Description 
     The New-DHCPScope cmdlet is used to create a new scope on a given server. The return value for success is the parent DHCPScope object. 
    .Parameter Server 
     The value for this parameter can be a DHCPServer object or the name or FQDN of the DHCP server. The designated server must by a valid DHCP server. 
    .Parameter Address 
     The value for this parameter must be in an IP address string format (ie: 0.0.0.0). 
    .Parameter SubnetMask 
     The value for this parameter must be in an IP address string format (ie: 0.0.0.0). 
    .Parameter Name 
     A self-explanatory string value. 
    .Parameter Description 
     A self-explanatory string value. 
    .Outputs 
     DHCPScope 
    .Notes 
     Name:   New-DHCPScope 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   12.16.2010 
  #> 
  Param([Parameter(Mandatory=$true,ValueFromPipeline=$true)][PSObject]$Server, 
        [Parameter(Mandatory=$true)][ValidatePattern("\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b")][string]$Address, 
        [Parameter(Mandatory=$true)][ValidatePattern("\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b")][string]$SubnetMask, 
        [Parameter(Mandatory=$true)][string]$Name, 
        [Parameter(Mandatory=$false)][string]$Description 
        ) 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server \\$Server add scope $Address $SubnetMask `"$Name`" `"$Description`"") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("completed successfully")) { return Get-DHCPScope -Server $Server -Scope $Address } 
  elseif($result.Contains("Server may not function properly")) { Write-Host "ERROR: $Server is inaccessible or is not a DHCP server." -ForeGroundColor Red } 
  else { Write-Host "ERROR: $result" -ForeGroundColor Red } 
  } 
 
function Register-DHCPServer { 
  <# 
    .Synopsis 
     Registers a given DHCP server with Active Directory. 
    .Example 
     Register-DHCPServer -Server dhcp01.contoso.com -IPAddress 192.168.1.33 
     This example registers dhcp01.constoso.com, and the IP address of 192.168.1.33, as an authorized DHCP server in Active Directory. 
    .Description 
     The Register-DHCPServer cmdlet is used to register a DHCP server with Active Directory. 
    .Parameter Server 
     The value for this parameter should be the FQDN of the DHCP server. 
    .Parameter IPAddress 
     The value for this parameter must be in an IP address string format (ie: 0.0.0.0). 
    .Notes 
     Name:   Register-DHCPServer 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   03.15.2011 
  #> 
  Param([Parameter(Mandatory=$true)][string]$Server, 
        [Parameter(Mandatory=$false)][ValidatePattern("\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b")][string]$IPAddress 
        ) 
  $list = Show-DHCPServers 
  foreach($item in $list) { 
    if($item.Server -eq $Server -or $item.IPAddress -eq $IPAddress) { 
      Write-Host "ERROR: The specified server is already present: $($item.Server) [$($item.IPAddress)]." -ForeGroundColor Red 
      return 
      } 
    } 
  $text = $(Invoke-Expression "cmd /c netsh dhcp add server $Server $(if($IPAddress){"$IPAddress"})") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("completed successfully")) { Write-Host "SUCCESS: $Server was successfully registered in Active Directory." -ForeGroundColor Green } 
  elseif($result.Contains("already present")) { Write-Host "ERROR: The specified server is already present." -ForeGroundColor Red } 
  else { Write-Host "ERROR: $result" -ForeGroundColor Red } 
  } 
 
function Remove-DHCPExclusionRange { 
  <# 
    .Synopsis 
     Removes an exclusion range from a DHCP scope. 
    .Example 
     Remove-DHCPExclusionRange -Server dhcp01.contoso.com -Scope 192.168.1.0 -StartAddress 192.168.1.200 -EndAddress 192.168.1.254 
     This example removes the exclusion range from the 192.168.1.0 scope on dhcp01.contoso.com that is between 192.168.1.200 and 192.168.1.254. 
    .Example 
     $scope | Remove-DHCPExclusionRange -StartAddress 192.168.1.200 -EndAddress 192.168.1.254 
     Given that $scope is the DHCPScope object for subnet 192.168.1.0 on dhcp01.contoso.com, this example accomplishes the same as the one in Example 1. 
    .Description 
     The Remove-DHCPExclusionRange cmdlet is used to remove an exclusion range from a given DHCP scope. The return value for success is the parent DHCPScope object. 
    .Parameter Server 
     The value for this parameter can be a DHCPServer object or the name or FQDN of the DHCP server. The designated server must by a valid DHCP server. 
    .Parameter Scope 
     The value for this parameter can be a DHCPScope object or the subnet address of the scope. If entering the subnet address, the Server parameter must be defined and be the host of this scope. 
     Note: This cmdlet will process significantly faster if the Scope variable supplied is a DHCPScope object. 
    .Parameter StartAddress 
     This parameter signifies the beginning IP address of the excluded range. The value for this parameter must be in an IP address string format (ie: 0.0.0.0). 
    .Parameter EndAddress 
     This parameter signifies the ending IP address of the excluded range. The value for this parameter must be in an IP address string format (ie: 0.0.0.0). 
    .Outputs 
     DHCPScope 
    .Notes 
     Name:   Remove-DHCPExclusionRange 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   12.16.2010 
  #> 
  Param([Parameter(Mandatory=$false)][PSObject]$Server, 
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][PSObject]$Scope, 
        [Parameter(Mandatory=$true)][ValidatePattern("\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b")][string]$StartAddress, 
        [Parameter(Mandatory=$true)][ValidatePattern("\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b")][string]$EndAddress 
        ) 
  if($Scope.GetType() -eq [DHCPScope] -and !$Server) { $Server = $Scope.Server } 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server \\$Server scope $Scope delete excluderange $StartAddress $EndAddress") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("completed successfully")) { 
    if($Scope.GetType() -eq [DHCPScope]) { 
      $Scope.ExclusionRanges = @($Scope.ExclusionRanges | Where-Object { $_.StartAddress -ne $StartAddress -and $_.EndAddress -ne $EndAddress }) 
      return $Scope 
      } 
    else { return Get-DHCPScope -Server $Server -Scope $Scope } 
    } 
  elseif($result.Contains("Server may not function properly")) { Write-Host "ERROR: $Server is inaccessible or is not a DHCP server." -ForeGroundColor Red } 
  elseif($result.Contains("The command needs a valid Scope IP Address")) { Write-Host "ERROR: $Scope is not a valid scope on $Server." -ForeGroundColor Red } 
  else { Write-Host "ERROR: $result" -ForeGroundColor Red } 
  if($Scope.GetType() -eq [DHCPScope]) { return $Scope } 
  } 
 
function Remove-DHCPFilter { 
  <# 
    .Synopsis 
     Removes a MAC address filter from the DHCP server. 
    .Example 
     Remove-DHCPFilter -Server dhcp01.contoso.com -MACAddress 00-00-00-00-00 
     Removes the filter for the given MAC address on dhcp01.contoso.com. 
    .Description 
     The Remove-DHCPFilter cmdlet is used to remove MAC address filters from a given server. 
    .Parameter Server 
     The value for this parameter can be a DHCPServer object or the name or FQDN of the DHCP server. The designated server must by a valid DHCP server. 
     Note: This cmdlet will process significantly faster if the Server variable supplied is a DHCPServer object. 
    .Parameter MACAddress 
     This parameter defines the MAC address for the filter. The value for this parameter must be in one of three standard hardware address string formats: 
       00:00:00:00:00:00 
       00-00-00-00-00-00 
       000000000000 
    .Parameter FilterObject 
     This parameter is a DHCPFilter object, and is used to pass the MAC address information to the CmdLet. 
    .Outputs 
     DHCPFilterConfiguration 
    .Notes 
     Name:   Remove-DHCPFilter 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   06.16.2011 
  #> 
  [CmdletBinding(DefaultParameterSetName="ByMAC")] 
  Param([Parameter(Mandatory=$true,ParameterSetName="ByMAC")][PSObject]$Server, 
        [Parameter(Mandatory=$true,ParameterSetName="ByMAC")][ValidatePattern("([0-9a-fA-F]{2}[:-]{0,1}){5}[0-9a-fA-F]{2}")][string]$MACAddress, 
        [Parameter(Mandatory=$true,ParameterSetName="ByObject")][DHCPFilter]$FilterObject 
        ) 
  $Server = if($FilterObject){$FilterObject.Server}else{$Server} 
  $MACAddress = if($FilterObject){$FilterObject.MACAddress}else{$MACAddress.Replace("-","").Replace(":","")} 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server \\$Server v4 delete filter $MACAddress") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("completed successfully")) { 
    if($text.Count -ge 4 -and $text[3].Contains("not a valid DNS Server")) { Write-Host "ERROR: $($text[3])" -ForeGroundColor Red; return } 
    } 
  elseif($result.Contains("Server may not function properly")) { Write-Host "ERROR: $server is inaccessible or is not a DHCP server." -ForeGroundColor Red; return } 
  else { Write-Host "ERROR: $result" -ForeGroundColor Red; return } 
  return Get-DHCPFilterConfiguration -Server $Server 
  } 
 
 
function Remove-DHCPIPRange { 
  <# 
    .Synopsis 
     Removes an ip range from a DHCP scope. 
    .Example 
     Remove-DHCPIPRange -Server dhcp01.contoso.com -Scope 192.168.1.0 -StartAddress 192.168.1.30 -EndAddress 192.168.1.254 
     This example removes the IP range from the 192.168.1.0 scope on dhcp01.contoso.com that is between 192.168.1.30 and 192.168.1.254. 
    .Example 
     $scope | Remove-DHCPIPRange -StartAddress 192.168.1.30 -EndAddress 192.168.1.254 
     Given that $scope is the DHCPScope object for subnet 192.168.1.0 on dhcp01.contoso.com, this example accomplishes the same as the one in Example 1. 
    .Description 
     The Remove-DHCPIPRange cmdlet is used to remove an IP range from a given DHCP scope. The return value for success is the parent DHCPScope object. 
    .Parameter Server 
     The value for this parameter can be a DHCPServer object or the name or FQDN of the DHCP server. The designated server must by a valid DHCP server. 
    .Parameter Scope 
     The value for this parameter can be a DHCPScope object or the subnet address of the scope. If entering the subnet address, the Server parameter must be defined and be the host of this scope. 
     Note: This cmdlet will process significantly faster if the Scope variable supplied is a DHCPScope object. 
    .Parameter StartAddress 
     This parameter signifies the beginning IP address of the IP range. The value for this parameter must be in an IP address string format (ie: 0.0.0.0). 
    .Parameter EndAddress 
     This parameter signifies the ending IP address of the IP range. The value for this parameter must be in an IP address string format (ie: 0.0.0.0). 
    .Outputs 
     DHCPScope 
    .Notes 
     Name:   Remove-DHCPIPRange 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   12.16.2010 
  #> 
  Param([Parameter(Mandatory=$false)][PSObject]$Server, 
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][PSObject]$Scope, 
        [Parameter(Mandatory=$true)][ValidatePattern("\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b")][string]$StartAddress, 
        [Parameter(Mandatory=$true)][ValidatePattern("\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b")][string]$EndAddress 
        ) 
  if($Scope.GetType() -eq [DHCPScope] -and !$Server) { $Server = $Scope.Server } 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server \\$Server scope $Scope delete iprange $StartAddress $EndAddress") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("completed successfully")) { 
    if($Scope.GetType() -eq [DHCPScope]) { 
      $Scope.IPRanges = @($Scope.IPRanges | Where-Object { $_.StartAddress -ne $StartAddress -and $_.EndAddress -ne $EndAddress }) 
      return $Scope 
      } 
    else { return Get-DHCPScope -Server $Server -Scope $Scope } 
    } 
  elseif($result.Contains("Server may not function properly")) { Write-Host "ERROR: $Server is inaccessible or is not a DHCP server." -ForeGroundColor Red } 
  elseif($result.Contains("The command needs a valid Scope IP Address")) { Write-Host "ERROR: $Scope is not a valid scope on $Server." -ForeGroundColor Red } 
  else { Write-Host "ERROR: $result" -ForeGroundColor Red } 
  if($Scope.GetType() -eq [DHCPScope]) { return $Scope } 
  } 
 
function Remove-DHCPOption { 
  <# 
    .Synopsis 
     Removes the value of an option from a given server, scope, or reservation. 
    .Example 
     Remove-DHCPOption -Owner dhcp01.contoso.com/192.168.1.0 -OptionID 200 
     This example removes the value set for option 200 from the scope of 192.168.1.0 on server dhcp01.contoso.com. 
    .Example 
     $reservation | Remove-DHCPOption -OptionID 15 
     This example removes the value set for option 25 from the reservation as defined by the DHCPReservation object, $reservation. 
    .Description 
     The Remove-DHCPOption cmdlet is used to remove the value set for an option from a given server, scope, or reservation. 
    .Parameter Owner 
     The value for this parameter can be a DHCPServer, DHCPScope, or DHCPReservation object. It can also be a string representation of these objects, defined thus: 
       ServerNameOrFQDN 
       ServerNameOrFQDN/ScopeAddress 
       ServerNameOrFQDN/ScopeAddress/ReservationAddress 
    .Parameter OptionID 
     The integer value of the option whose value you wish to remove. 
    .Parameter VendorClass 
     A string value for the name of the vendor class of DHCP options. If none is given, the Standard DHCP Options class is used. 
    .Parameter UserClass 
     A string value for the name of the user class of the DHCP option. If none is given, the Default User Class is used. 
    .Outputs 
     DHCPServer, DHCPScope, or DHCPReservation depending. 
    .Notes 
     Name:   Remove-DHCPOption 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   12.16.2010 
  #> 
  Param([Parameter(Mandatory=$true,ValueFromPipeline=$true)][PSObject]$Owner, 
        [Parameter(Mandatory=$true)][ValidateRange(1,254)][int]$OptionID, 
        [Parameter(Mandatory=$false)][string]$VendorClass, 
        [Parameter(Mandatory=$false)][string]$UserClass, 
        [Parameter(Mandatory=$false)][switch]$Silent 
        ) 
  $server = $null 
  $scope = $null 
  $reservation = $null 
  if($Owner.GetType() -eq [DHCPServer]) { $server = $Owner.Name } 
  elseif($Owner.GetType() -eq [DHCPScope]) { 
    $server = $Owner.Server 
    $scope = $Owner.Address 
    } 
  elseif($Owner.GetType() -eq [DHCPReservation]) { 
    $server = $Owner.Server 
    $scope = $Owner.Scope 
    $reservation = $Owner.IPAddress 
    } 
  else { 
    $parts = $Owner.ToString().Split("/") 
    $server = $parts[0] 
    if($parts.Count -gt 1) { $scope = $parts[1] } 
    if($parts.Count -gt 2) { $reservation = $parts[2] } 
    } 
  if($reservation) { $command = "\\$server scope $scope delete reservedoptionvalue $reservation" } 
  else { $command = if($scope){"\\$server scope $scope delete optionvalue"}else{"\\$server delete optionvalue"} } 
  if(!!$VendorClass) { $VendorClass = "vendor=`"$VendorClass`"" } 
  if(!!$UserClass) { $UserClass = "user=`"$UserClass`"" } 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server $command $OptionID $VendorClass $UserClass") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("completed successfully")) { 
    if(@([DHCPServer],[DHCPScope],[DHCPReservation]) -contains $Owner.GetType()) { 
      $Owner.Options = @($Owner.Options | Where-Object { $_.OptionID -ne $OptionID }) 
      return $Owner 
      } 
    else { return $result } 
    } 
  elseif(!$Silent) { 
    if($result.Contains("Server may not function properly")) { Write-Host "ERROR: $server is inaccessible or is not a DHCP server." -ForeGroundColor Red } 
    elseif($result.Contains("The command needs a valid Scope IP Address")) { Write-Host "ERROR: $scope is not a valid scope on $server." -ForeGroundColor Red } 
    elseif($result.Contains("client is not a reserved")) { Write-Host "ERROR: $reservation is not a valid reservation in $scope on $server." -ForeGroundColor Red } 
    else { Write-Host "ERROR: $result" -ForeGroundColor Red } 
    } 
  } 
 
function Remove-DHCPOptionDefinition { 
  <# 
    .Synopsis 
     Removes an option from a given server. 
    .Example 
     Remove-DHCPOptionDefinition -Server dhcp01.contoso.com -OptionID 200 
     This example removes option 200 from server dhcp01.contoso.com 
    .Example 
     $server | Remove-DHCPOptionDefinition -OptionID 200 
     Given that $server is the DHCPServer object for dhcp01.contoso.com, this example accomplishes the same as the one in Example 1 with a description too. 
    .Description 
     The Remove-DHCPOptionDefinition cmdlet is used to remove an option from a given server. Once removed, the option can no longer be set on that server until it is recreated. 
    .Parameter Server 
     The value for this parameter can be a DHCPServer object or the name or FQDN of the DHCP server. The designated server must by a valid DHCP server. 
    .Parameter OptionID 
     An integer between 1 and 254 that is not currently used by another option. 
    .Parameter Name 
     A self-explanatory string value. 
    .Parameter DataType 
     A string value for the data type of the value(s). 
     The available options are: 
       BYTE 
       WORD 
       DWORD 
       STRING 
       IPADDRESS 
    .Parameter IsArray 
     A boolean value for whether the accepted value is unary or an array. 
    .Parameter VendorClass 
     A string value for the name of the vendor class of DHCP options. If none is given, the Standard DHCP Options class is used. 
    .Outputs 
     Success = String message 
     Failure = NULL 
    .Notes 
     Name:   Remove-DHCPOptionDefinition 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   12.16.2010 
  #> 
  Param([Parameter(Mandatory=$true,ValueFromPipeline=$true)][PSObject]$Server, 
        [Parameter(Mandatory=$true)][ValidateRange(1,254)][int]$OptionID, 
        [Parameter(Mandatory=$false)][string]$VendorClass 
        ) 
  if(!!$VendorClass) { $VendorClass = "vendor=`"$VendorClass`"" } 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server \\$Server delete optiondef $OptionID $VendorClass") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("completed successfully")) { return $result } 
  elseif($result.Contains("Server may not function properly")) { Write-Host "ERROR: $Server is inaccessible or is not a DHCP server." -ForeGroundColor Red } 
  else { Write-Host "ERROR: $result" -ForeGroundColor Red } 
  } 
 
function Remove-DHCPReservation { 
  <# 
    .Synopsis 
     Removes a reservation from a scope. 
    .Example 
     Remove-DHCPReservation -Server dhcp01.contoso.com -Scope 192.168.1.0 -IPAddress 192.168.1.237 -MACAddress 00:00:00:00:00:00 
     This example removes the reservation for 192.168.1.237 from the 192.168.1.0 scope on dhcp01.contoso.com. 
    .Example 
     Remove-DHCPReservation -Reservation $reservation 
     Given that $reservation is the DHCPReservation object for the IP 192.168.1.237 in 192.168.1.0 on dhcp01.contoso.com, this example accomplishes the same as the one in Example 1. 
    .Description 
     The Remove-DHCPReservation cmdlet is used to remove a reservation from a scope. The return value for success is the parent DHCPScope object. 
    .Parameter Reservation 
     The value for this paramater must be the DHCPReservation object of the reservation you wish to remove. 
    .Parameter Server 
     The value for this parameter can be a DHCPServer object or the name or FQDN of the DHCP server. The designated server must by a valid DHCP server. 
    .Parameter Scope 
     The value for this parameter can be a DHCPScope object or the subnet address of the scope. If entering the subnet address, the Server parameter must be defined and be the host of this scope. 
     Note: This cmdlet will process significantly faster if the Scope variable supplied is a DHCPScope object. 
    .Parameter IPAddress 
     The value for this parameter must be in an IP address string format (ie: 0.0.0.0). 
    .Parameter MACAddress 
     The value for this parameter must be in one of three standard hardware address string formats: 
       00:00:00:00:00:00 
       00-00-00-00-00-00 
       000000000000 
    .Outputs 
     DHCPScope 
    .Notes 
     Name:   Remove-DHCPReservation 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   12.16.2010 
  #> 
  [CmdletBinding(DefaultParameterSetName="ByMAC")] 
  Param([Parameter(Mandatory=$false,ValueFromPipeline=$true,ParameterSetName="ByObject")][DHCPReservation]$Reservation, 
        [Parameter(Mandatory=$false,ParameterSetName="ByMAC")][PSObject]$Server, 
        [Parameter(Mandatory=$true,ParameterSetName="ByMAC")][PSObject]$Scope, 
        [Parameter(Mandatory=$true,ParameterSetName="ByMAC")][ValidatePattern("\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b")][string]$IPAddress, 
        [Parameter(Mandatory=$true,ParameterSetName="ByMAC")][ValidatePattern("([0-9a-fA-F]{2}[:-]{0,1}){5}[0-9a-fA-F]{2}")][string]$MACAddress 
        ) 
  if($Reservation -and $Reservation.GetType() -eq [DHCPReservation]) { 
    $Server = $Reservation.Server 
    $Scope = $Reservation.Scope 
    $IPAddress = $Reservation.IPAddress 
    $MACAddress = $Reservation.MACAddress.Replace("-","").Replace(":","") 
    } 
  else { 
    if(!$Scope) { Write-Host "ERROR: Invalid null entry for scope." -ForeGroundColor Red; return } 
    elseif($Scope.GetType() -eq [DHCPScope] -and !$Server) { $Server = $Scope.Server } 
    if(!$IPAddress) { Write-Host "Error: Invalid null entry for IPAddress." -ForeGroundColor Red; return } 
    if(!$MACAddress) { Write-Host "Error: Invalid null entry for MACAddress." -ForeGroundColor Red; return } 
    else { $MACAddress = $MACAddress.Replace("-","").Replace(".","") } 
    } 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server \\$Server scope $Scope delete reservedip $IPAddress $MACAddress") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("completed successfully")) { 
    if($Scope.GetType() -eq [DHCPScope]) { 
      $Scope.Reservations = @($Scope.Reservations | Where-Object { $_.IPAddress -ne $IPAddress }) 
      return $Scope 
      } 
    else { return $result } 
    } 
  elseif($result.Contains("Server may not function properly")) { Write-Host "ERROR: $Server is inaccessible or is not a DHCP server." -ForeGroundColor Red } 
  elseif($result.Contains("The command needs a valid Scope IP Address")) { Write-Host "ERROR: $Scope is not a valid scope on $Server." -ForeGroundColor Red } 
  else { Write-Host "ERROR: $result" -ForeGroundColor Red } 
  } 
 
function Remove-DHCPScope { 
  <# 
    .Synopsis 
     Removes a scope from a server. 
    .Example 
     Remove-DHCPScope -Server dhcp01.contoso.com -Scope 192.168.1.0 
     This example removes the 192.168.1.0 scope on dhcp01.contoso.com. 
    .Example 
     $scope | Get-DHCPScope 
     Given that $scope is the DHCPScope object for subnet 192.168.1.0 on dhcp01.contoso.com, this example accomplishes the same as the one in Example 1. 
    .Description 
     The Remove-DHCPScope cmdlet is used to remove a specific DHCP scopes from a given server. The return value for success is a DHCPServer object. 
    .Parameter Server 
     The value for this parameter can be a DHCPServer object or the name or FQDN of the DHCP server. The designated server must by a valid DHCP server. 
     Note: This cmdlet will process significantly faster if the Server variable supplied is a DHCPServer object. 
    .Parameter Scope 
     The value for this parameter can be a DHCPScope object or the subnet address of the scope. If entering the subnet address, the Server parameter must be defined and be the host of this scope. 
    .Outputs 
     DHCPServer 
    .Notes 
     Name:   Remove-DHCPScope 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   12.16.2010 
  #> 
  Param([Parameter(Mandatory=$false)][PSObject]$Server, 
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][PSObject]$Scope, 
        [Parameter(Mandatory=$false)][switch]$Force 
        ) 
  if($Scope.GetType() -eq [DHCPScope] -and !$Server) { $Server = $Scope.Server } 
  $forceFlag = if($Force){"DHCPFULLFORCE"}else{"DHCPNOFORCE"} 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server \\$Server delete scope $Scope $forceFlag") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("completed successfully")) { 
    if($Server.GetType() -eq [DHCPServer]) { 
      $Server.Scopes = @($Server.Scopes | Where-Object { $_.Address -ne "$Scope" }) 
      return $Server 
      } 
    else { return Get-DHCPServer -Server $Server } 
    } 
  elseif($result.Contains("cannot be removed")) { Write-Host "ERROR: The scope [$Scope] has active leases and cannot be removed without the -Force parameter." -ForeGroundColor Red } 
  elseif($result.Contains("Server may not function properly")) { Write-Host "ERROR: $Server is inaccessible or is not a DHCP server." -ForeGroundColor Red } 
  elseif($result.Contains("The command needs a valid Scope IP Address")) { Write-Host "ERROR: $Scope is not a valid scope on $Server." -ForeGroundColor Red } 
  else { Write-Host "ERROR: $result" -ForeGroundColor Red } 
  } 
 
function Set-DHCPConflictDetectionAttempts { 
  <# 
    .Synopsis 
     Sets the number of confliction detection attempts made by the DHCP server. 
    .Example 
     Set-DHCPConflictDetectionAttempts -Server dhcp01.contoso.com -Number 2 
     This example sets the conflict detection attempts on dhcp01.contoso.com to 2. 
    .Example 
     $server | Set-DHCPConflictDetectionAttempts -Number 2 
     Given that $server is the DHCPServer object for dhcp01.contoso.com, this example accomplishes the same as the one in Example 1. 
    .Description 
     The Set-DHCPConflictDetectionAttempts cmdlet is used to set the number of confliction detection attempts made by the DHCP server. The return value for success is a DHCPServer object. 
    .Parameter Server 
     The value for this parameter can be a DHCPServer object or the name or FQDN of the DHCP server. The designated server must by a valid DHCP server. 
     Note: This cmdlet will process significantly faster if the Server variable supplied is a DHCPServer object. 
    .Parameter Number 
     The number of conflict detection attempts to make. 
    .Outputs 
     DHCPServer 
    .Notes 
     Name:   Set-DHCPConflictDetectionAttempts 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   12.16.2010 
  #> 
  Param([Parameter(Mandatory=$true,ValueFromPipeline=$true)][PSObject]$Server, 
        [Parameter(Mandatory=$true)][int]$Number 
        ) 
  if($Number -gt 5) { Write-Host "WARNING The maximum number of conflict retries is 5. Setting value to 5." -ForeGroundColor Yellow; $Number = 5 } 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server \\$Server set detectconflictretry $Number") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("completed successfully")) { 
    if($Server.GetType() -eq [DHCPServer]) { 
      $Server.ConflictDetectionAttempts = $Number 
      return $Server 
      } 
    else { return Get-DHCPServer -Server $Server } 
    } 
  elseif($result.Contains("Server may not function properly")) { Write-Host "ERROR: $Server is inaccessible or is not a DHCP server." -ForeGroundColor Red } 
  else { Write-Host "ERROR: $result" -ForeGroundColor Red } 
  if($Server.GetType() -eq [DHCPServer]) { return $Server } 
  } 
 
function Set-DHCPDNSConfiguration { 
  <# 
    .Synopsis 
     Defines the DNS update configuration for a given DHCP object. 
    .Example 
     Set-DHCPDNSConfiguration -Owner dhcp01.contoso.com/192.168.1.0/192.168.1.237 -Value 7 
     This example defines the DNS update configuration for the reservation 192.168.1.237 in the scope of 192.168.1.0 on server dhcp01.contoso.com. 
      
     The resulting configuration would be: 
       Dynamic Updates:              Enabled 
       Update Trigger:               Client Request 
       Discard Stale DNS Records:    Enabled 
       Legacy Client Updates:        Enabled 
    .Example 
     $scope | Set-DHCPDNSConfiguration -RestoreDefaults 
     Given that $scope is the DHCPScope object for some scope, this example restores the default DNS update configuration for that scope. The resulting effect is that the scope will henceforth inherit its DNS update configuration from its parent server. 
 
     The resulting configuration would be: 
       Dynamic Updates:              Enabled 
       Update Trigger:               Client Request 
       Discard Stale DNS Records:    Enabled 
       Legacy Client Updates:        Disabled 
    .Example 
     Set-DHCPDNSConfiguration -Owner $reservation -AllowDynamicUpdate -UpdateTrigger Always -DiscardStaleRecords -Allow LegacyClientUpdate 
     Given that $reservation is either a string representation or the DHCPReservation object for some reservation, this example would define the DNS update configuration thus: 
       Dynamic Updates:              Enabled 
       Update Trigger:               Always 
       Discard Stale DNS Records:    Enabled 
       Legacy Client Updates:        Enabled 
    .Description 
     The Set-DHCPDNSConfiguration cmdlet is used to define the DNS update configuration for a given DHCP server, scope, or reservation. 
    .Parameter Owner 
     The value for this parameter can be a DHCPServer, DHCPScope, or DHCPReservation object. It can also be a string representation of these objects, defined thus: 
       ServerNameOrFQDN 
       ServerNameOrFQDN/ScopeAddress 
       ServerNameOrFQDN/ScopeAddress/ReservationAddress 
    .Parameter DNSConfiguration 
     The value for this parameter is a DHCPDNSConfiguration object. It is used if you have a defined DNS update configuration that you want to apply to a new object. 
    .Parameter Value 
     The value for this parameter is an integer. This is used if you want to input the raw option value for DNS update configuration. You can create a valid value using the following logic: 
       Start at 0. A value of 0 means DNS update configuration is completely disabled. 
       If you want the Update Trigger to be "Always", add 16. 
       If you want to discard old DNS records, add 4. 
       If you want to allow legacy (< Windows 2000) client updates, add 2. 
       If you want to allow dynamic updates, add 1. 
        
       Note: A value of -1 is only applicable within the context of this module and is used to denote no defined configuration, which means that the given object inherits its DNS update configuration from its parent. If the given object is the DHCP server, then it uses the default configuration, which is equal to a value of 5. 
    .Parameter AllowDynamicUpdate 
     The value for this parameter is true or false. If declared, the value is true and enables dynamic updates, otherwise dynamic updates is disabled. 
    .Parameter UpdateTrigger 
     The value for this parameter is a string value of 'Always' or 'ClientRequest'. If not declared the value defaults to 'ClientRequest'. 
    .Parameter DiscardStaleDNSRecords 
     The value for this parameter is true or false. If declared, the value is true and enables the discarding of stale DNS records (A and PTR) when a lease is no longer active, otherwise it is disabled. 
    .Parameter AllowLegacyClientUpdate 
     The value for this parameter is true or false. If declared, the value is true and enables the updating of DNS records belonging to legacy (pre Windows 2000) clients, otherwise it is disabled. 
    .Parameter RestoreDefaults 
     The value for this parameter is true of false. If declared, the DNS update configuration for the given object inherits its DNS update configuration from its parent. If the given object is the DHCP server, then it uses the default configuration, which is equal to a value of 5. 
 
     This parameter supercedes all other configuration parameters. 
    .Outputs 
     DHCPDNSConfiguration 
    .Notes 
     Name:   Get-DHCPDNSConfiguration 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   04.22.2011 
  #> 
  Param([Parameter(Mandatory=$true,ValueFromPipeline=$true)][PSObject]$Owner, 
        [Parameter(Mandatory=$false)][DHCPDNSConfiguration]$DNSConfiguration, 
        [Parameter(Mandatory=$false)][ValidateRange(-1,23)][int]$Value, 
        [Parameter(Mandatory=$false)][switch]$AllowDynamicUpdate, 
        [Parameter(Mandatory=$false)][ValidateSet("Always","ClientRequest")][string]$UpdateTrigger, 
        [Parameter(Mandatory=$false)][switch]$DiscardStaleRecords,         
        [Parameter(Mandatory=$false)][switch]$AllowLegacyClientUpdate, 
        [Parameter(Mandatory=$false)][switch]$RestoreDefaults 
        ) 
  if($RestoreDefaults -or $Value -eq -1) { $null = Remove-DHCPOption -Owner $Owner -OptionID 81 -Silent } 
  else { 
    if($DNSConfiguration) { $Value = $DNSConfiguration.Value } 
    if(!$Value) { 
      if($AllowDynamicUpdate){ $Value += 1 } 
      if($UpdateTrigger -eq "Always") { $Value += 16 } 
      if($DiscardStaleRecords) { $Value += 4 } 
      if($AllowLegacyClientUpdate) { $Value += 2 } 
      } 
    if($Value -gt 7 -and $Value -lt 16) { Write-Host "ERROR: Invalid DNS update configuration value defined." -ForeGroundColor Red; return } 
    else { 
      $dnsOptions = @(0,0,0,0) 
      if($Value -ge 16) { $dnsOptions[1] = 1; $Value -= 16 } 
      if($Value -ge 4) { $dnsOptions[2] = 1; $Value -= 4 } 
      if($Value -ge 2) { $dnsOptions[3] = 1; $Value -= 2 } 
      if($Value -eq 1) { $dnsOptions[0] = 1 } 
      } 
    $server = $null 
    $scope = $null 
    $reservation = $null 
    if($Owner.GetType() -eq [DHCPServer]) { $server = $Owner.Name } 
    elseif($Owner.GetType() -eq [DHCPScope]) { 
      $server = $Owner.Server 
      $scope = $Owner.Address 
      } 
    elseif($Owner.GetType() -eq [DHCPReservation]) { 
      $server = $Owner.Server 
      $scope = $Owner.Scope 
      $reservation = $Owner.IPAddress 
      } 
    else { 
      $parts = $Owner.ToString().Split("/") 
      $server = $parts[0] 
      if($parts.Count -gt 1) { $scope = $parts[1] } 
      if($parts.Count -gt 2) { $reservation = $parts[2] } 
      } 
    $command = if($scope -or $reservation){"\\$server scope $scope set dnsconfig"}else{"\\$server set dnsconfig"} 
    if($reservation) { $command += " $reservation" } 
    $text = $(Invoke-Expression "cmd /c netsh dhcp server $command $($dnsOptions -Join " ")") 
    $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
    if($result.Contains("completed successfully")) { 
      if($text[3].Contains("not a valid DNS Server")) { Write-Host "ERROR: $($text[3])" -ForeGroundColor Red; return } 
      } 
    elseif($result.Contains("Server may not function properly")) { Write-Host "ERROR: $server is inaccessible or is not a DHCP server." -ForeGroundColor Red; return } 
    elseif($result.Contains("The command needs a valid Scope IP Address")) { Write-Host "ERROR: $scope is not a valid scope on $server." -ForeGroundColor Red; return } 
    elseif($result.Contains("client is not a reserved")) { Write-Host "ERROR: $reservation is not a valid reservation in $scope on $server." -ForeGroundColor Red; return } 
    else { Write-Host "ERROR: $result" -ForeGroundColor Red; return } 
    } 
  $DNSConfiguration = Get-DHCPDNSConfiguration -Owner $Owner 
  if(@([DHCPServer],[DHCPScope],[DHCPReservation]) -contains $Owner.GetType()) { 
    $Owner.DNSConfiguration = $DNSConfiguration 
    return $Owner 
    } 
  else { return $DNSConfiguration } 
  } 
 
function Set-DHCPFilterConfiguration { 
  <# 
    .Synopsis 
     Sets the MAC Filter configuration for a given DHCP server. 
    .Example 
     Set-DHCPFilterConfiguration -Server dhcp01.contoso.com -DenyList Enabled 
     This example enables the Deny filter and any MAC addresses defined therein, but does nothing to the Allow filter. 
    .Example 
     Set-DHCPFilterConfiguration -Server dhcp01.contoso.com -AllowList Disabled -DenyList Disabled 
     This example disables both the Allow and Deny filters. 
    .Description 
     The Set-DHCPFilterConfiguration cmdlet is used to enable or disable the Allow and Deny MAC address filters. 
    .Parameter Server 
     The value for this parameter can be a DHCPServer object or the name or FQDN of the DHCP server. The designated server must by a valid DHCP server. 
     Note: This cmdlet will process significantly faster if the Server variable supplied is a DHCPServer object. 
    .Parameter AllowList 
     This parameter defines the state of the Allow filter. 
       Enabled  - Provides DHCP services only to clients whose addresses are in the Allow List 
       Disabled - Does not filter MAC addresses to see if they are allowed 
    .Parameter DenyList 
     This parameter defines the state of the Deny filter. 
       Enabled  - Denies DHCP services only to clients whose addresses are in the Deny List 
       Disabled - Does not filter MAC addresses to see if they are denied 
    .Outputs 
     DHCPFilterConfiguration 
    .Notes 
     Name:   Set-DHCPFilterConfiguration 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   06.16.2011 
  #> 
  Param([Parameter(Mandatory=$true)][PSObject]$Server, 
        [Parameter(Mandatory=$false)][ValidateSet("Enabled","Disabled")][string]$AllowList, 
        [Parameter(Mandatory=$false)][ValidateSet("Enabled","Disabled")][string]$DenyList 
        ) 
  $command = "\\$Server v4 set filter" 
  switch($AllowList) { 
    "Enabled"  { $command += " EnforceAllowList=1" } 
    "Disabled" { $command += " EnforceAllowList=0" } 
    } 
  switch($DenyList) { 
    "Enabled"  { $command += " EnforceDenyList=1" } 
    "Disabled" { $command += " EnforceDenyList=0" } 
    } 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server $command") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("completed successfully")) { 
    if($text[3].Contains("not a valid DNS Server")) { Write-Host "ERROR: $($text[3])" -ForeGroundColor Red; return } 
    } 
  elseif($result.Contains("Server may not function properly")) { Write-Host "ERROR: $server is inaccessible or is not a DHCP server." -ForeGroundColor Red; return } 
  else { Write-Host "ERROR: $result" -ForeGroundColor Red; return } 
  return Get-DHCPFilterConfiguration -Server $Server 
  } 
 
function Set-DHCPOption { 
  <# 
    .Synopsis 
     Set the value of an option from a given server, scope, or reservation. 
    .Example 
     Set-DHCPOption -Owner dhcp01.contoso.com/192.168.1.0 -OptionID 200 -DataType IPADDRESS -Value "192.168.1.230 192.168.1.231" 
     This example sets the value for option 200 on the 192.168.1.0 scope on server dhcp01.contoso.com with two values: 192.168.1.230 and 192.168.1.231. 
    .Example 
     $scope | Set-DHCPOption -OptionID 200 -DataType IPADDRESS -Value 192.168.1.230 
     Given that $scope is the DHCPScope object for subnet 192.168.1.0 on dhcp01.contoso.com, this example sets the value for option 200 on the 192.168.1.0 scope on server dhcp01.contoso.com to 192.168.1.230. 
    .Example 
     Set-DHCPOption -Owner dhcp01.contoso.com/192.168.1.0 -OptionID 231 -DataType String -Value "This is a multi-word string value" 
     This example sets the value for option 231 on the 192.168.1.0 scope on server dhcp01.contoso.com to 'This is a multi-word string value'. 
    .Description 
     The Set-DHCPOption cmdlet is used to set the value for an option on a given server, scope, or reservation. The return value for success is a DHCPServer, DHCPScope, DHCPReservation, or DHCPOption object depending. 
    .Parameter Owner 
     The value for this parameter can be a DHCPServer, DHCPScope, or DHCPReservation object. It can also be a string representation of these objects, defined thus: 
       ServerNameOrFQDN 
       ServerNameOrFQDN/ScopeAddress 
       ServerNameOrFQDN/ScopeAddress/ReservationAddress 
     If this value is defined as an object, that updated object will be returned upon success. 
    .Parameter OptionID 
     The integer value of the option whose value you wish to set. 
    .Parameter DataType 
     A string value for the data type of the value(s). 
     The available options are: 
       BYTE 
       WORD 
       DWORD 
       STRING 
       IPADDRESS 
    .Parameter VendorClass 
     A string value for the name of the vendor class of DHCP options. If none is given, the Standard DHCP Options class is used. 
    .Parameter UserClass 
     A string value for the name of the user class of the DHCP option. If none is given, the Default User Class is used. 
    .Parameter Force 
     This switch parameter is only needed if you want to add IPs to OptionID 6 that are not currently online. This parameter is only valid for Windows 2008 servers and higher. 
    .Outputs 
     DHCPServer, DHCPScope, or DHCPReservation, DHCPOption depending. 
    .Notes 
     Name:   Remove-DHCPOption 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   12.16.2010 
  #> 
  Param([Parameter(Mandatory=$true,ValueFromPipeline=$true)][PSObject]$Owner, 
        [Parameter(Mandatory=$true)][ValidateRange(1,254)][int]$OptionID, 
        [Parameter(Mandatory=$true)][ValidateSet("BYTE","WORD","DWORD","STRING","IPADDRESS")][string]$DataType, 
        [Parameter(Mandatory=$true)][string]$Value, 
        [Parameter(Mandatory=$false)][string]$VendorClass, 
        [Parameter(Mandatory=$false)][string]$UserClass, 
        [Parameter(Mandatory=$false)][switch]$Force 
        ) 
  if($OptionID -eq 51) { Write-Host "The scope lease must be set using the Set-DHCPScopeLease cmdlet."; return } 
  if($OptionID -eq 81) { Write-Host "THe DNS Configuration settings must be set using the Set-DHCPDNSConfiguration cmdlet."; return } 
  $server = $null 
  $scope = $null 
  $reservation = $null 
  if($Owner.GetType() -eq [DHCPServer]) { $server = $Owner.Name } 
  elseif($Owner.GetType() -eq [DHCPScope]) { 
    $server = $Owner.Server 
    $scope = $Owner.Address 
    } 
  elseif($Owner.GetType() -eq [DHCPReservation]) { 
    $server = $Owner.Server 
    $scope = $Owner.Scope 
    $reservation = $Owner.IPAddress 
    } 
  else { 
    $parts = $Owner.ToString().Split("/") 
    $server = $parts[0] 
    if($parts.Count -gt 1) { $scope = $parts[1] } 
    if($parts.Count -gt 2) { $reservation = $parts[2] } 
    } 
  $command = if($scope){"\\$server scope $scope set optionvalue"}else{"\\$server set optionvalue"} 
  if($reservation) { $command = "\\$server scope $scope set reservedoptionvalue $reservation" } 
  if(!!$VendorClass) { $VendorClass = "vendor=`"$VendorClass`"" } 
  if(!!$UserClass) { $UserClass = "user=`"$UserClass`"" } 
  $os = (Get-WmiObject Win32_OperatingSystem).Caption 
  $forceFlag = if($os.Contains("2008") -or $os.Contains("7")){if($Force){"DHCPFULLFORCE"}else{"DHCPNOFORCE"}}else{""} 
  if($DataType -eq "STRING") { $Value = "`"$Value`"" } 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server $command $OptionID $DataType $VendorClass $UserClass $forceFlag $Value") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("completed successfully")) { 
    if($text[3].Contains("not a valid DNS Server")) { Write-Host "ERROR: $($text[3])" -ForeGroundColor Red } 
    else { 
      $option = Get-DHCPOption -Owner $Owner -OptionID $OptionID -Force:$Force 
      if(@([DHCPServer],[DHCPScope],[DHCPReservation]) -contains $Owner.GetType()) { 
        if(!!$Owner.Options) { $Owner.Options = @($Owner.Options | Where-Object { $_.OptionID -ne $OptionID }) } 
        $Owner.Options += $option 
        return $Owner 
        } 
      else { return $option } 
      } 
    } 
  elseif($result.Contains("Server may not function properly")) { Write-Host "ERROR: $server is inaccessible or is not a DHCP server." -ForeGroundColor Red } 
  elseif($result.Contains("The command needs a valid Scope IP Address")) { Write-Host "ERROR: $scope is not a valid scope on $server." -ForeGroundColor Red } 
  elseif($result.Contains("client is not a reserved")) { Write-Host "ERROR: $reservation is not a valid reservation in $scope on $server." -ForeGroundColor Red } 
  else { Write-Host "ERROR: $result" -ForeGroundColor Red } 
  } 
 
function Set-DHCPScopeDescription { 
  <# 
    .Synopsis 
     Sets the description of a DHCP scope. 
    .Example 
     Set-DHCPScopeDescription -Server dhcp01.contoso.com -Scope 192.168.1.0 -Description "This is a test scope." 
     This example sets the description for the 192.168.1.0 scope on dhcp01.contoso.com. 
    .Example 
     $scope | Remove-DHCPIPRange -Description "This is a test scope." 
     Given that $scope is the DHCPScope object for subnet 192.168.1.0 on dhcp01.contoso.com, this example accomplishes the same as the one in Example 1. 
    .Description 
     The Set-DHCPScopeDescription cmdlet is used to set the description of a DHCP scope. The return value for success is the DHCPScope object. 
    .Parameter Server 
     The value for this parameter can be a DHCPServer object or the name or FQDN of the DHCP server. The designated server must by a valid DHCP server. 
    .Parameter Scope 
     The value for this parameter can be a DHCPScope object or the subnet address of the scope. If entering the subnet address, the Server parameter must be defined and be the host of this scope. 
     Note: This cmdlet will process significantly faster if the Scope variable supplied is a DHCPScope object. 
    .Parameter Description 
     A self-explanatory string value. 
    .Outputs 
     DHCPScope 
    .Notes 
     Name:   Set-DHCPScopeDescription 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   12.16.2010 
  #> 
  Param([Parameter(Mandatory=$false)][PSObject]$Server, 
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][PSObject]$Scope, 
        [Parameter(Mandatory=$true)][string]$Description 
        ) 
  if($Scope.GetType() -eq [DHCPScope] -and !$Server) { $Server = $Scope.Server } 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server \\$Server scope $Scope set comment `"$Description`"") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("completed successfully")) { 
    if($Scope.GetType() -eq [DHCPScope]) { 
      $Scope.Description = $Description 
      return $Scope 
      } 
    else { return Get-DHCPScope -Server $Server -Scope $Scope } 
    } 
  elseif($result.Contains("Server may not function properly")) { Write-Host "ERROR: $Server is inaccessible or is not a DHCP server." -ForeGroundColor Red } 
  elseif($result.Contains("The command needs a valid Scope IP Address")) { Write-Host "ERROR: $Scope is not a valid scope on $Server." -ForeGroundColor Red } 
  else { Write-Host "ERROR: $result" -ForeGroundColor Red } 
  if($Scope.GetType() -eq [DHCPScope]) { return $Scope } 
  } 
 
function Set-DHCPScopeLease { 
  <# 
    .Synopsis 
     Sets the lease time for clients on a DHCP scope. 
    .Example 
     Set-DHCPScopeLease -Server dhcp01.contoso.com -Scope 192.168.1.0 -Seconds 691200 
     This example sets the lease time for the 192.168.1.0 scope on dhcp01.contoso.com to 8 days. 
    .Example 
     $scope | Remove-DHCPIPRange -Seconds 691200 
     Given that $scope is the DHCPScope object for subnet 192.168.1.0 on dhcp01.contoso.com, this example accomplishes the same as the one in Example 1. 
    .Description 
     The Set-DHCPScopeLease cmdlet is used to set the lease time for clients on a DHCP scope. The return value for success is the DHCPScope object. 
    .Parameter Server 
     The value for this parameter can be a DHCPServer object or the name or FQDN of the DHCP server. The designated server must by a valid DHCP server. 
    .Parameter Scope 
     The value for this parameter can be a DHCPScope object or the subnet address of the scope. If entering the subnet address, the Server parameter must be defined and be the host of this scope. 
     Note: This cmdlet will process significantly faster if the Scope variable supplied is a DHCPScope object. 
    .Parameter Seconds 
     Time in seconds for the duration fo the lease. 
    .Outputs 
     DHCPScope 
    .Notes 
     Name:   Set-DHCPScopeLease 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   12.16.2010 
  #> 
  Param([Parameter(Mandatory=$false)][PSObject]$Server, 
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][PSObject]$Scope, 
        [Parameter(Mandatory=$true)][int]$Seconds 
        ) 
  if($Scope.GetType() -eq [DHCPScope] -and !$Server) { $Server = $Scope.Server } 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server \\$Server scope $Scope set optionvalue 51 dword $Seconds") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("completed successfully")) { 
    if($Scope.GetType() -eq [DHCPScope]) { 
      $Scope.Lease = $Seconds 
      return $Scope 
      } 
    else { return Get-DHCPScope -Server $Server -Scope $Scope } 
    } 
  elseif($result.Contains("Server may not function properly")) { Write-Host "ERROR: $Server is inaccessible or is not a DHCP server." -ForeGroundColor Red } 
  elseif($result.Contains("The command needs a valid Scope IP Address")) { Write-Host "ERROR: $Scope is not a valid scope on $Server." -ForeGroundColor Red } 
  else { Write-Host "ERROR: $result" -ForeGroundColor Red } 
  if($Scope.GetType() -eq [DHCPScope]) { return $Scope } 
  } 
 
function Set-DHCPScopeName { 
  <# 
    .Synopsis 
     Sets the name of a DHCP scope. 
    .Example 
     Set-DHCPScopeName -Server dhcp01.contoso.com -Scope 192.168.1.0 -Name TestScope 
     This example sets the name for the 192.168.1.0 scope on dhcp01.contoso.com. 
    .Example 
     $scope | Remove-DHCPIPRange -Name TestScope 
     Given that $scope is the DHCPScope object for subnet 192.168.1.0 on dhcp01.contoso.com, this example accomplishes the same as the one in Example 1. 
    .Description 
     The Set-DHCPScopeName cmdlet is used to set the name of a DHCP scope. The return value for success is the DHCPScope object. 
    .Parameter Server 
     The value for this parameter can be a DHCPServer object or the name or FQDN of the DHCP server. The designated server must by a valid DHCP server. 
    .Parameter Scope 
     The value for this parameter can be a DHCPScope object or the subnet address of the scope. If entering the subnet address, the Server parameter must be defined and be the host of this scope. 
     Note: This cmdlet will process significantly faster if the Scope variable supplied is a DHCPScope object. 
    .Parameter Name 
     A self-explanatory string value. 
    .Outputs 
     DHCPScope 
    .Notes 
     Name:   Set-DHCPScopeName 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   12.16.2010 
  #> 
  Param([Parameter(Mandatory=$false)][PSObject]$Server, 
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][PSObject]$Scope, 
        [Parameter(Mandatory=$true)][string]$Name 
        ) 
  if($Scope.GetType() -eq [DHCPScope] -and !$Server) { $Server = $Scope.Server } 
  $text = $(Invoke-Expression "cmd /c netsh dhcp server \\$Server scope $Scope set name `"$Name`"") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("completed successfully")) { 
    if($Scope.GetType() -eq [DHCPScope]) { 
      $Scope.Name = $Name 
      return $Scope 
      } 
    else { return Get-DHCPScope -Server $Server -Scope $Scope } 
    } 
  elseif($result.Contains("Server may not function properly")) { Write-Host "ERROR: $Server is inaccessible or is not a DHCP server." -ForeGroundColor Red } 
  elseif($result.Contains("The command needs a valid Scope IP Address")) { Write-Host "ERROR: $Scope is not a valid scope on $Server." -ForeGroundColor Red } 
  else { Write-Host "ERROR: $result" -ForeGroundColor Red } 
  if($Scope.GetType() -eq [DHCPScope]) { return $Scope } 
  } 
 
function Show-DHCPServers { 
  <# 
    .Synopsis 
     Displays a list of all DHCP servers in Active Directory. 
    .Description 
     The Show-DHCPServers cmdlet is used to display all DHCP servers registered in Active Directory. 
    .Outputs 
     PSObject 
    .Notes 
     Name:   Show-DHCPServers 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   03.15.2011 
  #> 
  $servers = @() 
  $text = $(Invoke-Expression "cmd /c netsh dhcp show server") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("completed successfully")) { 
    foreach($line in $text) { 
      if($line.Contains("Server [")) { 
        $parts = $line.Split("[") 
        $name = $parts[1].Split("]")[0] 
        $ip = $parts[2].Split("]")[0] 
        $server = New-Object PSObject 
        $server | Add-Member NoteProperty Server($name)   
        $server | Add-Member NoteProperty IPAddress($ip) 
        $servers += $server 
        } 
      } 
    return $servers 
    } 
  else { Write-Host "ERROR: $result" -ForeGroundColor Red } 
  } 
 
function Unregister-DHCPServer { 
  <# 
    .Synopsis 
     Unregisters a given DHCP server with Active Directory. 
    .Example 
     Unregister-DHCPServer -Server dhcp01.contoso.com -IPAddress 192.168.1.33 
     This example unregisters dhcp01.constoso.com, and the IP address of 192.168.1.33, as an authorized DHCP server in Active Directory. 
    .Description 
     The Unregister-DHCPServer cmdlet is used to unregister a DHCP server with Active Directory. 
    .Parameter Server 
     The value for this parameter should be the FQDN of the DHCP server. 
    .Parameter IPAddress 
     The value for this parameter must be in an IP address string format (ie: 0.0.0.0). 
    .Notes 
     Name:   Unregister-DHCPServer 
     Module: Microsoft.DHCP.PowerShell.Admin.psm1 
     Author: Jeremy Engel 
     Date:   03.15.2011 
  #> 
  Param([Parameter(Mandatory=$true)][string]$Server, 
        [Parameter(Mandatory=$true)][ValidatePattern("\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b")][string]$IPAddress 
        ) 
  $text = $(Invoke-Expression "cmd /c netsh dhcp delete server $Server $IPAddress") 
  $result = if($text.GetType() -eq [string]){$text}else{$text[($text.Count-1)]} 
  if($result.Contains("completed successfully")) { Write-Host "SUCCESS: $Server was successfully unregistered in Active Directory." -ForeGroundColor Green } 
  elseif($result.Contains("not present")) { Write-Host "ERROR: The specified server is not listed in Active Directory." -ForeGroundColor Red } 
  else { Write-Host "ERROR: $result" -ForeGroundColor Red } 
  } 
 
function Get-DHCPCommand { 
  Param([string]$Command) 
  $commands = @{ 
"Add-DHCPExclusionRange"="Add-DHCPExclusionRange [[-Server] <DHCPServer|String>] [-Scope] <DHCPScope|String> [-StartAddress] <String> [-EndAddress] <String>"; 
"Add-DHCPFilter"="Add-DHCPFilter -Server <DHCPServer|String> -Allow|Deny -MACAddress <String> -Description <String>"; 
"Add-DHCPIPRange"="Add-DHCPIPRange [[-Server] <DHCPServer|String>] [-Scope] <DHCPScope|String> [-StartAddress] <String> [-EndAddress] <String>"; 
"Disable-DHCPScope"="Disable-DHCPScope [[-Server] <DHCPServer|String>] [-Scope] <DHCPScope|String>"; 
"Enable-DHCPScope"="Enable-DHCPScope [[-Server] <DHCPServer|String>] [-Scope] <DHCPScope|String>"; 
"Get-DHCPDNSConfiguration"="Get-DHCPDNSConfiguration [-Owner] <DHCPServer|DHCPScope|DHCPReservation|String>"; 
"Get-DHCPFilterConfiguration"="Get-DHCPFilterConfiguration -Server <DHCPServer|String>"; 
"Get-DHCPOption"="Get-DHCPOption [-Owner] <DHCPServer|DHCPScope|DHCPReservation|String> [[-OptionID] <Int>] [-Force]"; 
"Get-DHCPOptionDefinitions"="Get-DHCPOptionDefinitions [-Server] <DHCPServer|String>"; 
"Get-DHCPReservation"="Get-DHCPReservation [[-Server] <DHCPServer|String>] [-Scope] <DHCPScope|String> [[-IPAddress] <String>]"; 
"Get-DHCPScope"="Get-DHCPScope [-Server] <DHCPServer|String> [[-Scope] <String>]"; 
"Get-DHCPServer"="Get-DHCPServer [-Server] <DHCPServer|String>"; 
"Get-DHCPStatistics"="Get-DHCPStatistics [-Server] <DHCPServer|String>"; 
"New-DHCPOptionDefinition"="New-DHCPOptionDefinition [-Server] <DHCPServer|String> [-OptionID] <Int> [-Name] <String> [-DataType] <String> [-IsArray] [[-VendorClass] <string>] [[-Description] <String>] [[-DefaultValue] <String>]"; 
"New-DHCPReservation"="New-DHCPReservation [[-Server] <DHCPServer|String>] [-Scope] <DHCPScope|String> [-IPAddress] <string> [-MACAddress] <String> [[-Name] <String>] [[-Description] <String>]"; 
"New-DHCPScope"="New-DHCPScope [-Server] <DHCPServer|String> [[-Scope] <string>]"; 
"Register-DHCPServer"="Register-DHCPServer [-Server] <String> [[-IPAddress] <String>]"; 
"Remove-DHCPExclusionRange"="Remove-DHCPExclusionRange [[-Server] <DHCPServer|String>] [-Scope] <DHCPScope|String> [-StartAddress] <String> [-EndAddress] <String>"; 
"Remove-DHCPFilter"="Remove-DHCPFilter -Server <DHCPServer|String> -MACAddress <String>`r`n`r`nRemove-DHCPFilter -FilterObject <DHCPFilter>"; 
"Remove-DHCPIPRange"="Remove-DHCPIPRange [[-Server] <DHCPServer|String>] [-Scope] <DHCPScope|String> [-StartAddress] <String> [-EndAddress] <String>"; 
"Remove-DHCPOption"="Remove-DHCPOption [-Owner] <DHCPServer|DHCPScope|DHCPReservation|String> [-OptionID] <Int> [[-VendorClass] <String>] [[-UserClass] <String>]"; 
"Remove-DHCPOptionDefinition"="Remove-DHCPOptionDefinition [-Server] <DHCPServer|String> [-OptionID] <Int> [[-VendorClass] <String>]"; 
"Remove-DHCPReservation"="Remove-DHCPReservation [-Reservation] <DHCPReservation> | [-Server] <DHCPServer|String> [-Scope] <DHCPScope|String> [-IPAddress] <String> [-MACAddress] <String>"; 
"Remove-DHCPScope"="Remove-DHCPScope [[-Server] <DHCPServer|String>] [-Scope] <DHCPScope|String>"; 
"Set-DHCPConflictDetectionAttempts"="Set-DHCPConflictDetectionAttempts [-Server] <DHCPServer|String> [-Number] <Int>"; 
"Set-DHCPDNSConfiguration"="Set-DHCPDNSConfiguration [-Owner] <DHCPServer|DHCPScope|DHCPReservation|String> [[-DNSConfiguration] <DHCPDNSConfiguration>] [[-Value] <Int32>] [[-AllowDynamicUpdate] [[-UpdateTrigger] <String>] [-DiscardStaleRecords] [-AllowLegacyClientUpdate]] [-RestoreDefaults]"; 
"Set-DHCPFilterConfiguration"="Set-DHCPFilterConfiguration [-Server] <DHCPServer|String> [[-AllowList] <String>] [[-DenyList] <String>]"; 
"Set-DHCPOption"="Set-DHCPOption [-Owner] <DHCPServer|DHCPScope|DHCPReservation|String> [-OptionID] <Int> [-DataType] <String> [-Value] <String> [[-VendorClass] <String>] [[-UserClass] <String>] [-Force]"; 
"Set-DHCPScopeDescription"="Set-DHCPScopeDescription [[-Server] <DHCPServer|String>] [-Scope] <DHCPScope|String> [-Description] <String>"; 
"Set-DHCPScopeLease"="Set-DHCPScopeLease [[-Server] <DHCPServer|String>] [-Scope] <DHCPScope|String> [-Seconds] <Int>"; 
"Set-DHCPScopeName"="Set-DHCPScopeName [[-Server] <DHCPServer|String>] [-Scope] <DHCPScope|String> [-Name] <String>"; 
"Show-DHCPServers"="Show-DHCPServers"; 
"Unregister-DHCPServer"="Unregister-DHCPServer [-Server] <String> [-IPAddress] <String>" 
    } 
  if($Command) { 
    if($commands.Keys -contains $Command) { return $commands[$Command] } 
    else { return "$Command is not a valid DHCP Module cmdlet." } 
    } 
  else { 
    $list = @() 
    foreach($cmd in $commands.Keys) { 
      $entry = New-Object PSOBject 
      $entry | Add-Member NoteProperty Name($cmd) 
      $entry | Add-Member NoteProperty Definition($commands[$cmd]) 
      $list += $entry 
      } 
    return $list | Sort-Object { $_.Name } 
    } 
  } 
 
Export-ModuleMember Add-DHCPExclusionRange,Add-DHCPFilter,Add-DHCPIPRange,Disable-DHCPScope,Enable-DHCPScope, 
                    Get-DHCPDNSConfiguration,Get-DHCPFilterConfiguration,Get-DHCPOption,Get-DHCPOptionDefinitions, 
                    Get-DHCPReservation,Get-DHCPScope,Get-DHCPServer,Get-DHCPStatistics,New-DHCPOptionDefinition, 
                    New-DHCPReservation,New-DHCPScope,Remove-DHCPExclusionRange,Remove-DHCPFilter,Remove-DHCPIPRange, 
                    Remove-DHCPOption,Remove-DHCPOptionDefinition,Remove-DHCPReservation,Remove-DHCPScope, 
                    Set-DHCPConflictDetectionAttempts,Set-DHCPDNSConfiguration,Set-DHCPFilterConfiguration,Set-DHCPOption, 
                    Set-DHCPScopeDescription,Set-DHCPScopeLease,Set-DHCPScopeName,Show-DHCPServers,Register-DHCPServer, 
                    Unregister-DHCPServer,Get-DHCPCommand