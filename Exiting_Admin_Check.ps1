##############################################################################
# Script Name: Exiting_Admin_Check.ps1
# Version: 1.0
# Author: Dean Bunn
# Last Edited: 11/22/2012
# Description: Check Remote Systems for Any Processes, Scheduled Tasks,
#               Servics Running with Credentials of an Exiting Admin
##############################################################################

#Error Handling Setting 
$ErrorActionPreference = "SilentlyContinue";

#Array of Domain\UserIDs to Check Against
[array]$userIDs = @("ad\adminAccount1","ad\adminAccount2","ad\adminAccount3");

#Vars for Email Notice
[string]$smtpServer = "smtpServer.mycollege.edu";
[string]$fromAddress = "scriptAccount@mycollege.edu";
[string]$toAddress = "adAdmins@mycollege.edu";

#Array of Server Names
$servers = @(   
                "SERVER1.MYCOLLEGE.EDU",
                "SERVER2.MYCOLLEGE.EDU",
                "SERVER3.MYCOLLEGE.EDU",
                "SERVER4.MYCOLLEGE.EDU",
                "SERVER5.MYCOLLEGE.EDU",
                "SERVER6.MYCOLLEGE.EDU"
            );

#Function for Checking Domain\UserIDs
function Check_Domain_Account([string]$dmnID,[array]$userIDs)
{
    
    foreach($userID in $userIDs)
    {
        #Check to See If Domain User IDs Match
        if([string]::Equals($userID.ToString().ToLower(),$dmnID.ToString().ToLower()))
        {
            return $true;
        }
    }

    return $false;
    
}#End of Check_Domain_Account Function

#Array to Hold Custom Reporting Objects
$summary = @();

foreach($server in $servers)
{
    #Vars for Reporting
    [string]$pingStatus = "";
    [string]$serviceStatus = "";
    [string]$processStatus = "";
    [string]$taskStatus = "";
    
    #Display Current Server Working Against
    Write-Output ("Working on " + $server.ToString().ToLower());
    
    #Ping Computer Before Attempting Remote WMI 
    if(test-connection -computername $server -quiet) 
    {
        $pingStatus = "passed";
        
        #Pull Services on Remote System
        $uServices = Get-WMIObject win32_service -Computer $server;
        
        #Null Check on Returned Services Collection
        if($uServices)
        {
            foreach($service in $uServices)
            {
                #Check the Account the Service is Running Under
                if(Check_Domain_Account $service.StartName.ToString() $userIDs)
                {
                    $serviceStatus = "found";
                    break;
                }
            }
        }
        else
        {
            $serviceStatus = "RPC failed";
        }#End of $uServices Null Check
        
        
        #Pull Processes from Remote System
        $uProcesses = Get-WmiObject win32_Process -ComputerName $server
        
        #Null Check on Return Processes Collection
        if($uProcesses)
        {
            foreach($process in $uProcesses)
            {
                #Pull Domain and User Info from Process
                $prcOwnerDomain = $process.GetOwner().Domain;
                $prcOwnerUserID = $process.GetOwner().User;
                #Verify that Both Domain and User ID Information Exists
                if($prcOwnerDomain -ne $null -and $prcOwnerUserID -ne $null)
                {
                    #Var for Domain\UserID Format
                    [string]$tmpDmnUserID = $prcOwnerDomain.ToString() + "\" + $prcOwnerUserID.ToString();
                    
                    #Check the Account the Process is Running As
                    if(Check_Domain_Account $tmpDmnUserID $userIDs)
                    {
                        $processStatus = "found";
                        break;
                    }
                }#End of Null Check on Domain and UserID
                
            }#End of Foreach Process
        }
        else
        {
            $processStatus = "RPC failed";
        }#End of $uProcesses Null Check
        
        #Scheduled Tasks
        try
        {
            #Connect to Schedule Service on Remote System and Pull Tasks
            $schedService = New-Object -ComObject Schedule.Service;
            $schedService.Connect($server);
            $rootTasks = $schedService.GetFolder("").GetTasks("");
            
            foreach ($task in $rootTasks) 
            { 
                #Create XML Object From Task XML Settings
                [XML]$taskXML = $task.Xml;
                    
                #Check to Account the Task will Run As
                if(Check_Domain_Account $taskXML.Task.Principals.Principal.UserId.ToString() $userIDs)
                {
                    $taskStatus = "found";
                    break;
                }
                    
            }#End of Foreach Task
            
        }
        catch
        {
            $taskStatus = "COM failed";
        }#End of Tasks Try\Catch

    }
    else
    {
        $pingStatus = "failed";
    }#End of Test Connection
    
    #Create Custom Reporting Object and Assign Values
    $uEntry = New-Object PSObject
    $uEntry | Add-Member -MemberType NoteProperty -Name "Server" -Value $server.ToString().ToLower();
    $uEntry | Add-Member -MemberType NoteProperty -Name "Ping_Status" -Value $pingStatus;
    $uEntry | Add-Member -MemberType NoteProperty -Name "Service_Status" -Value $serviceStatus;
    $uEntry | Add-Member -MemberType NoteProperty -Name "Process_Status" -Value $processStatus;
    $uEntry | Add-Member -MemberType NoteProperty -Name "Task_Status" -Value $taskStatus;
    #Add Reporting Object to Reporting Array
    $summary += $uEntry;
    
}#End of Foreach Computer

#Sort Report by Server Name
$summary = $summary | Sort-Object Server;

######## Configure HTML Report ########

#Var for HTML Message Body
$msgBody = "<html>
            <body>
            <h4>Exiting Admin Account(s) Report</h4>
            <span style=""font-size:8pt;font-family:Arial,sans-serif"">
            <strong>Accounts Checked:</strong>
            <br />";
            
#Add Each Account Checked to Report
foreach($usrID in $userIDs)
{
    $msgBody += $usrID.ToString().ToLower() + "<br />";
}

#Format the Report HTML Table
$msgBody += "</span><br />
             <table border=""1"" cellpadding=""4"" cellspacing=""0""
             style=""font-size:8pt;font-family:Arial,sans-serif"">
             <tr bgcolor=""#000099"">
             <td><strong><font color=""#FFFFFF"">Server</font></strong></td>
             <td align=""center""><strong><font color=""#FFFFFF"">Ping</font></strong></td>
             <td align=""center""><strong><font color=""#FFFFFF"">Services</font></strong></td>
             <td align=""center""><strong><font color=""#FFFFFF"">Processes</font></strong></td>
             <td align=""center""><strong><font color=""#FFFFFF"">Scheduled Tasks</font></strong></td>
             </tr>
             ";

#Var for Table Row Count
[int]$x = 1;

#Loop Through Custom Object Collection
foreach($srv in $summary)
{
    #Determine Even\Odd Row 
    if($x%2)
    {
        $msgBody += "<tr bgcolor=""#FFFFFF"">";
    }
    else
    {
        $msgBody += "<tr bgcolor=""#E8E8E8"">";
    }
    
    $x++;
    
    $msgBody += "<td>" `
                + $srv.Server `
                + "</td><td align=""center"">" `
                + $srv.Ping_Status `
                + "</td><td align=""center"">" `
                + $srv.service_Status `
                + "</td><td align=""center"">" `
                + $srv.process_Status `
                + "</td><td align=""center"">" `
                + $srv.task_Status `
                + "</td></tr>
                
                ";
}

#Close HTML Table and Message
$msgBody += "</table>
            </body>
            </html>";

#Settings for Email Message
$messageParameters = @{                        
                          Subject = "Exiting Admin Account(s) Report"
                           Body = $msgBody                       
                           From = $fromAddress                        
                           To = $toAddress                        
                           SmtpServer = $smtpServer                       
                       };                      
#Send Report Email Message 
Send-MailMessage @messageParameters –BodyAsHtml;

################################################################
#Export to CSV Section (Leaving In Case Needed Later)
#Get Current Short Date
#$rptDate = Get-Date -Format d;
#Configure Report Name
#$reportName = "Exiting_Admin_Check_" `
#              + $rptDate.ToString().Replace("/","-") + ".csv";
#Export Report to CSV
#$summary | Export-CSV $reportName -NoTypeInformation;
################################################################
