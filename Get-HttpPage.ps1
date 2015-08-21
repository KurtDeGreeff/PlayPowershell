##############################################################################
#  Script: Get-HttpPage.ps1
#    Date: 23.Jun.2007
# Version: 1.0
#  Author: Jason Fossen (www.WindowsPowerShellTraining.com)
# Purpose: Obtains the response text of an HTTP request (not including headers).
#   Notes: You can use HTTPS if desired, but defaults to plaintext.  Uses
#          HTTP version 1.1 and the Host: request header is sent.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################

param ( $URL = $(throw "Enter a URL!") )


function Get-HttpPage ( $URL = $(throw "Enter a URL!") )
{
    if ( $URL -notmatch '^http' ) { $URL = "http://" + $URL }
    $WebClient = new-object System.Net.WebClient
    $WebClient.DownloadString( $URL )
}


Get-HttpPage -url $URL 



