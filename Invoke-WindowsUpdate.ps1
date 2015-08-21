###########################################################################"
#
# NAME: Invoke-WindowsUpdate.ps1
#
# AUTHOR: Jan Egil Ring
# EMAIL: jan.egil.ring@powershell.no
#
# COMMENT: Script to download and install updates from Windows Update/WSUS. Reporting and rebooting may be customized.
#          For more details, see the following blog-post: 
#          http://blog.powershell.no/2010/06/25/manage-windows-update-installations-using-windows-powershell
#
# You have a royalty-free right to use, modify, reproduce, and
# distribute this script file in any way you find useful, provided that
# you agree that the creator, owner above has no warranty, obligations,
# or liability for such use.
#
# VERSION HISTORY:
# 1.0 25.06.2010 - Initial release
#
###########################################################################"

#Requires -Version 2.0

#Variables to customize
$EmailReport = $true
$FileReport = $true
$To = "it-reports@domain.com"
$From = "powershell@domain.com"
$SMTPServer = "smtp.domain.local"
$FileReportPath = "\\domain.local\IT\Windows Update Reports\"
$AutoRestart = $true
$AutoRestartIfPending = $true

$Path = $FileReportPath + "$env:ComputerName" + "_" + (Get-Date -Format dd-MM-yyyy_HH-mm).ToString() + ".html"

#Testing if there are any pending reboots from earlier Windows Update sessions
if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"){

#Report to e-mail if enabled
if ($EmailReport -eq $true) {
$pendingboot = @{$false="was pending for a restart from an earlier Windows Update session. Due to the reboot preferences in the script, a reboot was not initiated."; $true="was restarted due to a pending restart from an earlier Windows Update session."}
$status = $pendingboot[$AutoRestartIfPending]
 $messageParameters = @{                        
                Subject = "Windows Update report for $env:ComputerName.$env:USERDNSDOMAIN - $((Get-Date).ToShortDateString())"                        
                Body = "Invoke-WindowsUpdate was run on $env:ComputerName, and the server $status `nPlease run Invoke-WindowsUpdate again when the server is rebooted."               
                from = $From                        
                To = $To                      
                SmtpServer = $SMTPServer                         
            }                        
            Send-MailMessage @messageParameters -BodyAsHtml

#Report to file if enabled
if ($FileReport -eq $true) {
"Invoke-WindowsUpdate was run on $env:ComputerName, and the server $status `nPlease run Invoke-WindowsUpdate again when the server is rebooted." | Out-File -FilePath $path
}

#Reboot if autorestart for pending updates is enabled
if ($AutoRestartIfPending) {shutdown.exe /t 0 /r }  }
exit
			
}

#Checking for available updates
$updateSession = new-object -com "Microsoft.Update.Session"
write-progress -Activity "Updating" -Status "Checking available updates"   
$updates=$updateSession.CreateupdateSearcher().Search($criteria).Updates
$downloader = $updateSession.CreateUpdateDownloader()          
$downloader.Updates = $Updates

#If no updates available, do nothing
if ($downloader.Updates.Count -eq "0") {

#Report to e-mail if enabled
if ($EmailReport -eq $true) {
 $messageParameters = @{                        
                Subject = "Windows Update report for $env:ComputerName.$env:USERDNSDOMAIN - $((Get-Date).ToShortDateString())"                        
                Body = "Invoke-WindowsUpdate was run on $env:ComputerName, but no new updates were found. Please try again later."               
                from = $From                        
                To = $To                      
                SmtpServer = $SMTPServer                         
            }                        
            Send-MailMessage @messageParameters -BodyAsHtml
			}
			
#Report to file if enabled
if ($FileReport -eq $true) {
"Invoke-WindowsUpdate was run on $env:ComputerName, but no new updates were found. Please try again later." | Out-File -FilePath $Path
}

}
else
{
#If updates are available, download and install
write-progress -Activity 'Updating' -Status "Downloading $($downloader.Updates.count) updates"  

$Criteria="IsInstalled=0 and Type='Software'" 
$resultcode= @{0="Not Started"; 1="In Progress"; 2="Succeeded"; 3="Succeeded With Errors"; 4="Failed" ; 5="Aborted" }
$Result= $downloader.Download()

if (($Result.Hresult -eq 0) –and (($result.resultCode –eq 2) -or ($result.resultCode –eq 3)) ) {
       $updatesToInstall = New-object -com "Microsoft.Update.UpdateColl"
       $Updates | where {$_.isdownloaded} | foreach-Object {$updatesToInstall.Add($_) | out-null 
}

$installer = $updateSession.CreateUpdateInstaller()       
$installer.Updates = $updatesToInstall

write-progress -Activity 'Updating' -Status "Installing $($Installer.Updates.count) updates"        

$installationResult = $installer.Install()        
$Global:counter=-1       

$Report = $installer.updates | 
				Select-Object -property Title,EulaAccepted,@{Name='Result';expression={$ResultCode[$installationResult.GetUpdateResult($Global:Counter++).resultCode ] }},@{Name='Reboot required';expression={$installationResult.GetUpdateResult($Global:Counter++).RebootRequired }} |
				ConvertTo-Html

#Report to e-mail if enabled
if ($EmailReport -eq $true) {
 $messageParameters = @{                        
                Subject = "Windows Update report for $env:ComputerName.$env:USERDNSDOMAIN - $((Get-Date).ToShortDateString())"                        
                Body =  $Report | Out-String                 
                from = $From                        
                To = $To                      
                SmtpServer = $SMTPServer                         
            }                        
            Send-MailMessage @messageParameters -BodyAsHtml
			}

#Report to file if enabled
if ($FileReport -eq $true) {
$Report | Out-File -FilePath $path
}

#Reboot if autorestart is enabled and one or more updates are requiring a reboot
if ($autoRestart -and $installationResult.rebootRequired) { shutdown.exe /t 0 /r }       
}
}