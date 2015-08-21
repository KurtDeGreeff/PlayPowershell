########################################################################
# Script Name: Display-InInternetExplorer.ps1
#     Version: 1.0
#      Author: Jason Fossen (www.WindowsPowerShellTraining.com)
#     Updated: 20.Jun.2007
#     Purpose: Demonstrates how to use Internet Explorer to display
#              HTML-tagged data to the script user (instead of
#              using plain text in message boxes).
#       Legal: Public Domain.  No rights reserved. Use at your own risk.
########################################################################

param ([String] $HtmlData = "<h1>$(get-date)</h1>")



function Display-InInternetExplorer( [String] $HtmlData = "<h1>$(get-date)</h1>" )
{
    $IE = new-object -com "InternetExplorer.Application" -strict
    $IE.Navigate("about:blank")
    $IE.ToolBar = 0
    $IE.StatusBar = 0
    $IE.Width = 600
    $IE.Height = 500
    $IE.Left = 150
    $IE.Top = 150
    $IE.Visible = $true
    
    Do { start-sleep -milli 100 } While ($IE.Busy) 
  
    $Document = $IE.Document
    $Document.Open() > $null
    $Document.IHTMLDocument2_Write( $HtmlData )
    $Document.Close() > $null
    
    $Document = $null
    $IE = $null 
}


Display-InInternetExplorer -htmldata $HtmlData



