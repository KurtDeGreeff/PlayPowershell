#######################################################################################################################                        
# Description:   MMS2013 Create-MMS2013SessionFile.ps1 creates a file with all sessions found on the session catalog 
#                on http://www.2013mms.com/Topic/List. This script is based on Stefan Strangers script see 
#                http://blogs.technet.com/b/stefan_stranger/  
# Author:        Stefan Roth / http://blog.scomfaq.ch      
# Example usage: Run Create-MMS2013SessionFile.ps1
# Date:          10.04.2013                       
# Name:          Create-MMS2013SessionFile.ps1            
# Version:       v1.0
########################################################################################################################

#Connect to the MMS website
Write-Host -ForegroundColor Yellow "Connecting to MMS website..."
$mms = Invoke-WebRequest -Uri "http://www.2013mms.com/Topic/List?format=html&Keyword=&Categories=&Timeslot=&Speaker=&Day=&Start=&Finish=&oc=&take=-1&skip=0&_=1364899913083"

#Parse the MMS website's HTML
Write-Host -ForegroundColor Yellow "Parsing HTML..."
$sessions = $mms.ParsedHtml.getElementsByTagName("div") | Where "classname" -match "^topic" | Select -ExpandProperty InnerText

#Declare the path where the script lies
$scriptdir = split-path -Parent $MyInvocation.MyCommand.Path

#Deleting existing sessions.txt file
Write-Host -ForegroundColor Yellow "Deleting existing sessions.txt file..."
Remove-Item ($scriptdir + "\sessions.txt")

#Getting each session and parsing for the session name
Write-Host -ForegroundColor Yellow "Iterating through the sessions..."
foreach ($session in $sessions) {
    
    $session = $session.split("`n",6);

    $sessionsubstring1 = $session.Substring(0,7)[0].trim()
    
    If ( $sessionsubstring1 -like "*-*" -eq "True" -or  $sessionsubstring1 -like "MMS*")

        {

            Write-Host -ForegroundColor Green "Dumping $sessionsubstring1 into sessions.txt file in directory " $scriptdir
        
            $sessionsubstring1 + ".wmv" | Out-File ($scriptdir + "\sessions.txt") -Append
        }

    
    $sessionsubstring2 = $session.Substring(0,5)[0].trim()

    If ( $sessionsubstring2 -like "EXM*" -or $sessionsubstring2 -like "BO*" -or $sessionsubstring2 -like "KEY*" )

        {

            Write-Host -ForegroundColor Green "Dumping $sessionsubstring2 into sessions.txt file in directory " $scriptdir
        
            $sessionsubstring2 + ".wmv" | Out-File ($scriptdir + "\sessions.txt") -Append
    
    
        }


    }
