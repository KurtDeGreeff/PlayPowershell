$computerName = "localhost"
$strLine = @();
$regPath = @('Software\Microsoft\Windows\CurrentVersion\Uninstall');
$keyName = 'LocalMachine';
$registry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($keyName, $computer);
$regKey = $registry.OpenSubKey($regPath);
if ($regKey -ne $null)
{
$keys = $regKey.GetSubKeyNames();
　　　　　 foreach ($name in $keys)
　　　　　　{
　　　　　 　　 $properties = $regKey.OpenSubKey($name);
　　　　　　　　 $displayName = $properties.GetValue('DisplayName');
　　　　　 　　 if ($displayName -ne $null)
　　　　　 　　 {
　　　　　　　　 $displayVersion = $properties.GetValue('DisplayVersion');
　　　　　　　　 $publisher = $properties.GetValue('Publisher');
　　　　　　　　 $installLocation = $properties.GetValue('InstallLocation');
　　　　　　　　　　　　　　　　　　　　　　　 　
　　　　　 　　　# create an object that will be added to the array $Responses
　　　　 　　　$Response = New-Object PSObject
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
　　 　　 　　　# add the members to our newly created $Response object
　　 　　　　　　　　 Add-Member -InputObject $Response -MemberType NoteProperty -Name Name -Value $displayName
　　 　　　　　　　　 Add-Member -InputObject $Response -MemberType NoteProperty -Name Version -Value $displayVersion
　 　　　　　　　　　 Add-Member -InputObject $Response -MemberType NoteProperty -Name Publisher -Value $publisher
　　　　　　　　　　　 Add-Member -InputObject $Response -MemberType NoteProperty -Name InstallLocation -Value $installLocation
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
　　 　　　　　　　　 # add the object to the array
　　 　　　　　　　　 $strLine += $Response
　　　　　　　　　　　 $properties.close();
　　　　　　　　　　　 }
　　　　 }
　　　　　 $regKey.close();
　 }
　 $registry.close();
　 $strLine | Out-GridView  
#Export-Csv -path c:\newFile.csv -NoTypeInformation　　