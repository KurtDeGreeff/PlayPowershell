##############################################################
# Script Name: PS_Remoting_Installed_Applications.ps1
# Version: 1.0
# Description: Using PowerShell Remoting Queries Remote
#               Systems for Installed Software
##############################################################

$allComputers = Invoke-Command -computername localhost `
-scriptblock {  
                #Arrays for Holding Installed App Data 
                $installedApps = @();
                $installedAppsKeys = @();
                
                #Pull 32bit Installed Apps
                Get-ChildItem hklm:\Software\Microsoft\Windows\CurrentVersion\Uninstall `
                    | ForEach-Object { $installedAppsKeys += Get-ItemProperty $_.pspath `
                    | Where-Object {$_.DisplayName -and !$_.ReleaseType -and `
                    !$_.ParentKeyName -and ($_.UninstallString -or $_.NoRemove)} };
                #Check for 64bit Installed Apps and Pull Information
                if(Test-Path hklm:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall)
                {
                  Get-ChildItem hklm:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall `
                  | ForEach-Object { $installedAppsKeys += Get-ItemProperty $_.pspath `
                  | Where-Object {$_.DisplayName -and !$_.ReleaseType -and !$_.ParentKeyName `
                  -and ($_.UninstallString -or $_.NoRemove)} };
                }
                #Loop Through Installed Application Registry Keys and Pull Info
                foreach($instlApp in $installedAppsKeys)
                {
                    #Local Variables Used in Reporting
                    [string]$displayName = "";
                    [string]$displayVersion = "";
                    
                    #Check for DisplayName is Null or Emtpy
                    if(![string]::IsNullOrEmpty($instlApp.DisplayName))
                    {
                        $displayName = $instlApp.DisplayName.ToString();
                        #Check to See If Display Version is Null or Empty
                        if(![string]::IsNullOrEmpty($instlApp.DisplayVersion))
                        {
                           $displayVersion = $instlApp.DisplayVersion.ToString();
                        }
                        #Create Custom PSObject and Add to Reporting Array
                        $app = New-Object PSObject;
                        $app | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $displayName;
                        $app | Add-Member -MemberType NoteProperty -Name "DisplayVersion" -Value $displayVersion;
                        $installedApps += $app;
                    }
                 }
                #Send Back Reporting Array Sorted by Display Name
                $installedApps | Sort-Object DisplayName;                                                  
            }

$allComputers | Format-Table PSComputerName,DisplayName,DisplayVersion -AutoSize