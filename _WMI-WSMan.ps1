#
# Windows PowerShell in Action Second Edition
#
# Chapter 19 WMI and WSMan


# PowerShell does not include a New-WmiObject cmdlet however it is
# possible to create instances using the .NET API as shown here:
#

# Creating a new environemnt variable instance
$envClass = [WmiClass] "Win32_Environment"
$newInstance = $envClass.CreateInstance()

# Set all of the properties on the object
$newInstance["Name"] = "testEnvironmentVariable"
$newInstance["VariableValue"] = "testValue"
$newInstance["UserName"] = "<SYSTEM>"

# write it to the repository
$newInstance.Put()

# Verify that the object was created
powershell { $ENV:testEnvironmentVariable }

###############################################################################################

#
# THe file contains examples showing how to use WMI from PowerShell
#

Get-WmiObject -Class Win32_BIOS `
     -Namespace "root\cimv2"

Get-WmiObject -ComputerName brucepayx61 `
   -Namespace "root\cimv2" -Class Win32_BIOS `
   -Credential redmond\brucepay

Get-WmiObject Win32_NetworkAdapterConfiguration |
  where { $_.DHCPEnabled } |
    Format-List Description, IPAddress, DHCPLeaseExpires

Get-WmiObject Win32_NetworkAdapterConfiguration |
  where { $_.DHCPEnabled } |
    Format-List Description, IPAddress,
     @{
       n = "DHCPLeaseExpires"
       e = {$_.ConvertToDateTime($_.DHCPLeaseExpires)}}

Get-WmiObject Win32_NetworkAdapterConfiguration `
  -Filter  'DHCPEnabled = TRUE' |
    Format-List Description, IPAddress

Get-WmiObject Win32_NetworkAdapterConfiguration `
  -Filter 'DHCPEnabled = TRUE AND Description LIKE "%wire%"' |
    Format-List Description, IPAddress

Get-WmiObject Win32_NetworkAdapterConfiguration `
  -Filter 'DHCPEnabled = TRUE AND NOT (Description LIKE "%wire%")' |
    Format-List Description, IPAddress
 
Get-WmiObject Win32_NetworkAdapterConfiguration |
 where {$_.DHCPEnabled -eq $true -and -not
   ($_.Description -like "*wire*")} |
     Format-List Description, IPAddress

Get-WmiObject Win32_NetworkAdapterConfiguration |
 where {$_.DHCPEnabled -and ($_.Description -notlike "*wire*")} |
     Format-List Description, IPAddress
     
Get-WmiObject -Namespace root\microsoft  __Namespace |
select name

Get-WmiObject -Query @'
  SELECT Description,IPAddress
  FROM Win32_NetworkAdapterConfiguration
  WHERE DHCPEnabled = TRUE AND NOT (Description LIKE "%wire%")
'@

Get-WmiObject -Query @'
  SELECT *
  FROM Win32_Service
  WHERE Name LIKE "%zune%"
'@ | Format-List Name, StartMode, Status, __PATH

############################################
# Set-WmiInstance examples

$class = Get-WmiObject -list Win32_Process
$p = $class.Properties | where { $_.Name -eq "Handle" }
$p
$p.Qualifiers.Keys
$p.Qualifiers["key"]
$class.Properties |
  where { $_.Qualifiers["key"]} |
    Format-Table -AutoSize name, type

(Get-WmiObject -List Win32_Environment).Properties |
  where { $_.Qualifiers["key"]} |
    Format-Table -AutoSize name, type
  
############################################
# Set-WmiInstance examples

$path = 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment'
Set-ItemProperty -Path $path `
  -Name 'TestProperty' -Value '3.14'
  
Get-ItemProperty -Path $path -Name TestProperty
Get-WmiObject -Class Win32_Environment `
  -Filter 'Name = "TestProperty"' |
    Format-List Name,VariableValue,__PATH
    
$vPath = 
'\\.\root\cimv2:Win32_Environment.Name="TestProperty",UserName="<SYSTEM>"'

Set-WmiInstance -Path $vPath `
  -Arguments @{VariableValue = "Hello"}
  
Get-WmiObject -Class Win32_Environment `
  -Filter 'Name = "TestProperty"' |
    Format-List Name,VariableValue,__PATH

Set-WmiInstance -Class win32_environment `
  -Arguments @{
    Name="TestProperty"
    VariableValue="Bye!"
    UserName="<SYSTEM>"
  }
  
Set-WmiInstance -Class win32_environment `
  -Arguments @{
    Name="TestProperty2"
    VariableValue="Bye!"
    UserName="<SYSTEM>"
  } | Format-List Name,VariableValue,__PATH


$v2Path = 
'\\.\root\cimv2:Win32_Environment.Name="tp2",UserName="<SYSTEM>"'

Set-WmiInstance -Path $v2Path `
  -Arguments @{VariableValue = "Hello"}

Get-WmiObject Win32_Environment `
  -Filter 'name = "tp2"'

Get-WmiObject Win32_Environment `
  -Filter 'VariableValue = "Bye!"'


###########################
# Invoke-WmiMethod

$result = Invoke-WmiMethod Win32_Process `
  -Name Create -ArgumentList calc

$result.GetType().FullName
$result | Format-Table ProcessId, ReturnValue

$proc = Get-WmiObject -Query @"
SELECT __PATH, Handle
FROM Win32_PROCESS
WHERE ProcessId = $($result.ProcessID)
"@ 

$proc | Get-Member -MemberType Method
$proc | Format-List __PATH

Invoke-WmiMethod -Path $proc.__PATH `
  -Name Terminate -Argument 0

Invoke-WmiMethod -Path $proc.__PATH `
  -Name Terminate -Argument (0) |
     select -First 1 -Property '[a-z]*'

#######################
#
# Remove-WmiObject

calc
$proc = Get-WmiObject -Query @"
SELECT __PATH, Handle
FROM Win32_PROCESS
WHERE Name='calc.exe'
"@ 

Remove-WmiObject -Path $proc.__PATH

Get-WmiObject -Class Win32_Environment `
  -Filter 'Name = "TestProperty"' |
    Format-List Name,VariableValue,__PATH

Get-WmiObject -Class Win32_Environment `
  -Filter 'Name = "TestProperty"' |
    Remove-WmiObject
 
Get-WmiObject -Class Win32_Environment `
 -Filter 'Name = "TestProperty"' |
   Format-List Name,VariableValue,__PATH
    
#######################
# Accelerators
calc
$s = [WmiSearcher] `
'Select * from Win32_Process where Name = "calc.exe"'

$so =  $s.Get() | Write-Output
$proc = [WMI] $so.__PATH
$proc.Name
$proc.HandleCount
$proc.Terminate()

$c = [WMICLASS]"Win32_Process"
$c | Get-Member -MemberType method | Format-List
$c.Create("notepad.exe") |
  Format-Table ReturnValue, ProcessId
  
Get-WmiObject Win32_Process `
  -Filter 'Name = "notepad.exe"' |
    Format-Table Name, Handle


Get-WmiObject -List -Class *datetime*

function Get-WmiCLassInfo ($class)
{
  filter Format-Property
  {
    $prop = $_
    [string] $fs = ""
    $fs = $prop.Type
    if ($prop.IsArray)
    {
      $fs += '[]'
    }
    $fs += " " + $prop.Name
    $fs += ' {'
    if ( $prop.Qualifiers["read"] -and $prop.Qualifiers["read"].Value)
    {
      $fs += ' get;'
    }
    if ( $prop.Qualifiers["write"].Value -and $prop.Qualifiers["write"].Value)
    {
      $fs += ' set;'
    }
    $fs += '}'
    $fs
    $prop.Qualifiers
  }
  $info = Get-WmiObject -Query "SELECT * FROM meta_class WHERE __this ISA '$class'"
  "Name: " + $info.Name | fl -force *
  "Methods:"
  $info.Methods | Format-Table -auto Name,InParameters,OutParameters
  "Properties:"
  $info.Properties | Format-Property
}

Get-WmiCLassInfo Win32_LogicalDisk

Get-WmiObject -Namespace root -Recurse -List `
 -Class *power* | Format-Table __PATH

# Filtering the objects returned

Get-WmiObject -Class Win32_Service `
 -Filter 'Name = "TermService"' |
   Format-Table __PATH
   
##########################################################################################