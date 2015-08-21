##########################################################################################################################                       
# Description:   MMS2013 MMS2013_Downloader.ps1 downloads all sessions from MMS 2013 which are defined in the sessions.txt
#                file.
# Author:        Stefan Roth / http://blog.scomfaq.ch      
# Example usage: Run MMS2013_Downloader.ps1
# Date:          10.04.2013                       
# Name:          MMS2013_Downloader.ps1          
# Version:       v1.0
###########################################################################################################################

Param([parameter(mandatory=$true)][String]$path)


#-----------Don't change----------------------------
$scriptdir = split-path -Parent $MyInvocation.MyCommand.Path

#Target path where the files will be saved
$target="\MMS2013Sessions\"
$targetpath=$path+$target
if (!(test-path -path $targetpath)) { new-item $targetpath -type directory};

#File which contains the sessions for download
$sessionsfile = $scriptdir + "\sessions.txt"
if ((test-path -path $sessionsfile)){$sessions =get-content $sessionsfile}
else {write-host -ForegroundColor Red ("Cannot find session.txt file. Please copy the file into the same directory as the script! Path $scriptdir")}

#Downloading the files from here. Don't change!
$url="http://video.ch9.ms/sessions/mms/2013/"

#Creating WebClient object and downloading sessions...
$wclient = new-object System.Net.WebClient
#$wclient.Credentials = new-object System.Net.NetworkCredential($username, $password, '')
Foreach($session in $sessions){

$i = $i+1

try {

            write-host -ForegroundColor Yellow ("Downloading Session..." + $session + " Number: " + $i + " out of " + $sessions.count)
            $file=$url+$session
            $download=$targetpath+$session
            $wclient.DownloadFile($file,$download)
        
     } 
     
catch {
            
            $errorfile = $scriptdir + "\sessions_notavailable.txt";
            write-host -foregroundColor Red ("Session not available please check $errorfile")
            if(!(test-path -path $errorfile)) { new-item $errorfile -type file};
            $session | out-file $errorfile -Append

        }



}

write-host -ForegroundColor Green "Finished!"

