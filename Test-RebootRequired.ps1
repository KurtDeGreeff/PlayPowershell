#Based on <http://gallery.technet.microsoft.com/scriptcenter/Get-PendingReboot-Query-bdb79542>
function Test-RebootRequired 
{
    $result = @{
        CBSRebootPending =$false
        WindowsUpdateRebootRequired = $false
        FileRenamePending = $false
        SCCMRebootPending = $false
    }

    #Check CBS Registry
    $key = Get-ChildItem "HKLM:Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -ErrorAction Ignore
    if ($key -ne $null) 
    {
        $result.CBSRebootPending = $true
    }
   
    #Check Windows Update
    $key = Get-Item "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -ErrorAction Ignore
    if($key -ne $null) 
    {
        $result.WindowsUpdateRebootRequired = $true
    }

    #Check PendingFileRenameOperations
    $prop = Get-ItemProperty "HKLM:SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -ErrorAction Ignore
    if($prop -ne $null) 
    {
        #PendingFileRenameOperations is not *must* to reboot?
        #$result.FileRenamePending = $true
    }
    
    #Check SCCM Client <http://gallery.technet.microsoft.com/scriptcenter/Get-PendingReboot-Query-bdb79542/view/Discussions#content>
    try 
    { 
        $util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
        $status = $util.DetermineIfRebootPending()
        if(($status -ne $null) -and $status.RebootPending){
            $result.SCCMRebootPending = $true
        }
    }catch{}

    #Return Reboot required
    return $result.ContainsValue($true)
}