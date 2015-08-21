# Search-Registry.ps1
# Written by Bill Stewart (bstewart@iname.com)

#requires -version 2

<#
.SYNOPSIS
Searches the registry on one or more computers for a specified text pattern.

.DESCRIPTION
Searches the registry on one or more computers for a specified text pattern. Supports searching for any combination of key names, value names, and/or value data. The text pattern is a case-insensitive regular expression.

.PARAMETER StartKey
Starts searching at the specified key. The key name uses the following format:
subtree[:][\[keyname[\keyname...]]]
subtree can be any of the following:
  HKCR or HKEY_CLASSES_ROOT
  HKCU or HKEY_CURRENT_USER
  HKLM or HKEY_LOCAL_MACHINE
  HKU or HKEY_USERS
This parameter's format is compatible with PowerShell registry drive (e.g., HKLM:\SOFTWARE), reg.exe (e.g., HKLM\SOFTWARE), and regedit.exe (e.g., HKEY_LOCAL_MACHINE\SOFTWARE).

.PARAMETER Pattern
Searches for the specified regular expression pattern. The pattern is not case-sensitive. See help topic about_Regular_Expressions for more information.

.PARAMETER MatchKey
Matches registry key names. You must specify at least one of -MatchKey, -MatchValue, or -MatchData.

.PARAMETER MatchValue
Matches registry value names. You must specify at least one of -MatchKey, -MatchValue, or -MatchData.

.PARAMETER MatchData
Matches registry value data. You must specify at least one of -MatchKey, -MatchValue, or -MatchData.

.PARAMETER MaximumMatches
Specifies the maximum number of results per computer searched. 0 means "return the maximum number of possible matches." The default is 0. This parameter is useful when searching the registry on remote computers in order to minimize unnecessary network traffic.

.PARAMETER ComputerName
Searches the registry on the specified computer. This parameter supports piped input.

.OUTPUTS
PSObjects with the following properties:
  ComputerName  The computer name on which the match occurred
  Key           The key name (e.g., HKLM:\SOFTWARE)
  Value         The registry value (empty for the default value)
  Data          The registry value's data

.EXAMPLE
PS C:\> Search-Registry -StartKey HKLM -Pattern $ENV:USERNAME -MatchData
Searches HKEY_LOCAL_MACHINE (i.e., HKLM) on the current computer for registry values whose data contains the current user's name.

.EXAMPLE
PS C:\> Search-Registry -StartKey HKLM:\SOFTWARE\Classes\Installer -Pattern LastUsedSource -MatchValue | Select-Object Key,Value,Data | Format-List
Outputs the LastUsedSource registry entries on the current computer.

.EXAMPLE
PS C:\> Search-Registry -StartKey HKCR\.odt -Pattern .* -MatchKey -MaximumMatches 1
Outputs at least one match if the specified reistry key exists. This command returns a result if the current computer has a program registered to open files with the .odt extension. The pattern .* means 0 or more of any character (i.e., match everything).

.EXAMPLE
PS C:\> Get-Content Computers.txt | Search-Registry -StartKey "HKLM:\SOFTWARE\My Application\Installed" -Pattern "Installation Complete" -MatchValue -MaximumMatches 1 | Export-CSV C:\Reports\MyReport.csv -NoTypeInformation
Searches for the specified value name pattern in the registry on each computer listed in the file Computers.txt starting at the specified subkey. Output is sent to the specifed CSV file.
#>

[CmdletBinding()]
param(
  [parameter(Position=0,Mandatory=$TRUE)]
    [String] $StartKey,
  [parameter(Position=1,Mandatory=$TRUE)]
    [String] $Pattern,
    [Switch] $MatchKey,
    [Switch] $MatchValue,
    [Switch] $MatchData,
    [UInt32] $MaximumMatches=0,
  [parameter(ValueFromPipeline=$TRUE)]
    [String[]] $ComputerName=$ENV:COMPUTERNAME
)

begin {
  $PIPELINEINPUT = (-not $PSBOUNDPARAMETERS.ContainsKey("ComputerName")) -and
    (-not $ComputerName)

  # Throw an error if -Pattern is not valid
  try {
    "" -match $Pattern | out-null
  }
  catch [System.Management.Automation.RuntimeException] {
    throw "-Pattern parameter not valid - $($_.Exception.Message)"
  }

  # You must specify at least one matching criteria
  if (-not ($MatchKey -or $MatchValue -or $MatchData)) {
    throw "You must specify at least one of: -MatchKey -MatchValue -MatchData"
  }

  # Interpret zero as "maximum possible number of matches"
  if ($MaximumMatches -eq 0) { $MaximumMatches = [UInt32]::MaxValue }

  # These two hash tables speed up lookup of key names and hive types
  $HiveNameToHive = @{
    "HKCR"               = [Microsoft.Win32.RegistryHive] "ClassesRoot";
    "HKEY_CLASSES_ROOT"  = [Microsoft.Win32.RegistryHive] "ClassesRoot";
    "HKCU"               = [Microsoft.Win32.RegistryHive] "CurrentUser";
    "HKEY_CURRENT_USER"  = [Microsoft.Win32.RegistryHive] "CurrentUser";
    "HKLM"               = [Microsoft.Win32.RegistryHive] "LocalMachine";
    "HKEY_LOCAL_MACHINE" = [Microsoft.Win32.RegistryHive] "LocalMachine";
    "HKU"                = [Microsoft.Win32.RegistryHive] "Users";
    "HKEY_USERS"         = [Microsoft.Win32.RegistryHive] "Users";
  }
  $HiveToHiveName = @{
    [Microsoft.Win32.RegistryHive] "ClassesRoot"  = "HKCR";
    [Microsoft.Win32.RegistryHive] "CurrentUser"  = "HKCU";
    [Microsoft.Win32.RegistryHive] "LocalMachine" = "HKLM";
    [Microsoft.Win32.RegistryHive] "Users"        = "HKU";
  }

  # Search for 'hive:\startkey'; ':' and starting key optional
  $StartKey | select-string "([^:\\]+):?\\?(.+)?" | foreach-object {
    $HiveName = $_.Matches[0].Groups[1].Value
    $StartPath = $_.Matches[0].Groups[2].Value
  }

  if (-not $HiveNameToHive.ContainsKey($HiveName)) {
    throw "Invalid registry path"
  } else {
    $Hive = $HiveNameToHive[$HiveName]
    $HiveName = $HiveToHiveName[$Hive]
  }

  # Recursive function that searches the registry
  function search-registrykey($computerName, $rootKey, $keyPath, [Ref] $matchCount) {
    # Write error and return if unable to open the key path as read-only
    try {
      $subKey = $rootKey.OpenSubKey($keyPath, $FALSE)
    }
    catch [System.Management.Automation.MethodInvocationException] {
      $message = $_.Exception.Message
      write-error "$message - $HiveName\$keyPath"
      return
    }

    # Write error and return if the key doesn't exist
    if (-not $subKey) {
      write-error "Key does not exist: $HiveName\$keyPath" -category ObjectNotFound
      return
    }

    # Search for value and/or data; -MatchValue also returns the data
    if ($MatchValue -or $MatchData) {
      if ($matchCount.Value -lt $MaximumMatches) {
        foreach ($valueName in $subKey.GetValueNames()) {
          $valueData = $subKey.GetValue($valueName)
          if (($MatchValue -and ($valueName -match $Pattern)) -or ($MatchData -and ($valueData -match $Pattern))) {
            "" | select-object `
              @{N="ComputerName"; E={$computerName}},
              @{N="Key"; E={"$HiveName\$keyPath"}},
              @{N="Value"; E={$valueName}},
              @{N="Data"; E={$valueData}}
            $matchCount.Value++
          }
          if ($matchCount.Value -eq $MaximumMatches) { break }
        }
      }
    }

    # Iterate and recurse through subkeys; if -MatchKey requested, output
    # objects only report computer and key (keys do not have values or data)
    if ($matchCount.Value -lt $MaximumMatches) {
      foreach ($keyName in $subKey.GetSubKeyNames()) {
        if ($keyPath -eq "") {
          $subkeyPath = $keyName
        } else {
          $subkeyPath = $keyPath + "\" + $keyName
        }
        if ($MatchKey -and ($keyName -match $Pattern)) {
          "" | select-object `
            @{N="ComputerName"; E={$computerName}},
            @{N="Key"; E={"$HiveName\$subkeyPath"}},
            @{N="Value"; E={}},
            @{N="Data"; E={}}
          $matchCount.Value++
        }
        # $matchCount is a reference
        search-registrykey $computerName $rootKey $subkeyPath $matchCount
        if ($matchCount.Value -eq $MaximumMatches) { break }
      }
    }

    # Close opened subkey
    $subKey.Close()
  }

  # Core function opens the registry on a computer and initiates searching
  function search-registry2($computerName) {
  # Write error and return if unable to open the key on the computer
  try {
      $rootKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive,
        $computerName)
    }
    catch [System.Management.Automation.MethodInvocationException] {
      $message = $_.Exception.Message
      write-error "$message - $computerName"
      return
    }
    # $matchCount is per computer; pass to recursive function as reference
    $matchCount = 0
    search-registrykey $computerName $rootKey $StartPath ([Ref] $matchCount)
    $rootKey.Close()
  }
}

process {
  if ($PIPELINEINPUT) {
    search-registry2 $_
  }
  else {
    $ComputerName | foreach-object {
      search-registry2 $_
    }
  }
}
