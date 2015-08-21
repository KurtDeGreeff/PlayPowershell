<#
.Synopsis
Here is the PowerShell CmdLet that would enable AutoLogon next time when the server reboots.We could trigger a specific Script to execute after the server is back online after Auto Logon.
The CmdLet has the follwing parameter(s) and function(s).
-DefaultUsername : Provide the username that the system would use to login.
-DefaultPassword : Provide the Password for the DefaultUser provided.
-AutoLogonCount : Sets the number of times the system would reboot without asking for credentials.Default is 1.
-Script : Provide Full path of the script for execution after server reboot. Example : c:\test\run.bat

Mandatory Parameters 
-DefaultUsername 
-DefaultPassword 


.Description
Here is the PowerShell CmdLet that would enable AutoLogon next time when the server reboots.We could trigger a specific Script to execute after the server is back online after Auto Logon.

.Example
Set-AutoLogon -DefaultUsername "win\admin" -DefaultPassword "password123"

.Example
Set-AutoLogon -DefaultUsername "win\admin" -DefaultPassword "password123" -AutoLogonCount "3"


.EXAMPLE
Set-AutoLogon -DefaultUsername "win\admin" -DefaultPassword "password123" -Script "c:\test.bat"

#>

Function Set-AutoLogon{

    [CmdletBinding()]
    Param(
        
        [Parameter(Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String[]]$DefaultUsername,

        [Parameter(Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String[]]$DefaultPassword,

        [Parameter(Mandatory=$False,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [AllowEmptyString()]
        [String[]]$AutoLogonCount,

        [Parameter(Mandatory=$False,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [AllowEmptyString()]
        [String[]]$Script
                
    )

    Begin
    {
        #Registry path declaration
        $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
        $RegROPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    
    }
    
    Process
    {

        try
        {
            #setting registry values
            Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String  
            Set-ItemProperty $RegPath "DefaultUsername" -Value "$DefaultUsername" -type String  
            Set-ItemProperty $RegPath "DefaultPassword" -Value "$DefaultPassword" -type String
            if($AutoLogonCount)
            {
                
                Set-ItemProperty $RegPath "AutoLogonCount" -Value "$AutoLogonCount" -type DWord
            
            }
            else
            {

                Set-ItemProperty $RegPath "AutoLogonCount" -Value "1" -type DWord

            }
            if($Script)
            {
                
                Set-ItemProperty $RegROPath "(Default)" -Value "$Script" -type String
            
            }
            else
            {
            
                Set-ItemProperty $RegROPath "(Default)" -Value "" -type String
            
            }        
        }

        catch
        {

            Write-Output "An error had occured $Error"
            
        }
    }
    
    End
    {
        
        #End

    }

}