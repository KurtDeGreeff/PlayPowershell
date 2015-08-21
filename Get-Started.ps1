<# 
PowerShell = Interactive Object-based .NET Shell
3 CMDLETS to Remember: 
GET-HELP GET-COMMAND GET-MEMBER

#>

#region Simple Powershell
"Hello World".Length
"Hello world" -split " "
"Hello","world" -join ";"
[char]92
#endregion

#region Help,Help,Get-help. 
#Since v3.0 help must be downloaded first! Only command-help is available
# CMDLET = <VERB>-<NOUN>
Get-Help
Save-Help -DestinationPath C:\temp
Update-Help -SourcePath c:\temp
Get-help -Name get-process -ShowWindow
pause
#endregion

#region Get-Command Gets all commands
Get-Command
Show-Command
Get-help get-command
Get-help get-command -Full
Get-help get-command -Examples
Get-help Get-Process
Get-help Get-Process -Examples
Get-help Get-Process -showWindow
Get-help Get-Process -Online
#endregion

#region Get-Member displays all members (properties,methods,..): Define what can you do with objects
Get-Process | Get-Member
$proc= Get-Process
$proc.processname # $ObjectName.PropertyName
$proc= Get-Process -Name notepad
#TAB is your best friend to discover members
$proc.kill() # $ObjectName.MethodName()
Stop-Process -Name notepad
Get-Process | Format-List
Get-Process | Format-List * #format-list * : shows all properties & methods filled in
#endregion

#region Select-Object, Where-Object, ForEach-Object, Sort-Object (New-Object)
Get-process | Select-Object -Property Name,WS
Get-process | Sort-Object
Get-process | Where-object vm -GT 200MB
1..10 | ForEach-Object {$_*2}
#endregion

#region Run from DOS,Batch, Scheduled Task,..
Powershell -file "C:\Users\Kurt\Documents\Microsoft Script Explorer\Get-SystemInfo_TEST.ps1" 
powershell -command "& {get-service;}" # Retrieve all services
#endregion

#region Usefull Cmdlets
Get-ExecutionPolicy # per user basis, block unsigned scripts
Set-ExecutionPolicy # per user basis
Get-Verb
Test-Connection  -ComputerName localhost # -Source
get-help -Name Restart-computer
#Use -WhatIf & -Confirm for system tasks
Restart-Computer -force -WhatIf 
Restart-Computer -force -Confirm
# $_ = $PSItem = Current Object in the pipeline
Get-Service -computername localhost | where-object {$_.status -eq "Running"}
Gsv | ? status -eq "running"  # use of aliases & PS 3.0 syntax
$event = get-eventlog -newest 100 -logname "system"
$event | where-object {$_.EntryType -match "warn"}
Get-EventLog -LogName System | Out-GridView
#endregion

#region PSProviders are used to access dataStores via drives: Filesystem,Registry,Environment,MDT,..
Get-PSProvider
Get-PSDrive
cd c:
Get-ChildItem -Path $home

#Read text files, use -Force for hidden,system files
Get-Content C:\Users\Kurt\tempfile.txt

#Create/remove file/Directory
New-item -type Dir -path c:\dir
Remove-item -Path c:\dir

#Create network drive (use -persist parameter to see in explorer)
New-psdrive -Name Net -PSProvider FileSystem -Root \\127.0.0.1\C$
Remove-PSDrive -Name net

#Get shares
Get-Wmiobject -Class Win32_Share -computername .

#Create share (new cmdlets in win8/2012)
$share = [wmiclass]"Win32_Share"
$results = $share.create("c:\data", "data", 0, 0, "Data share")
write-host $results.returnvalue
New-item -type Dir -path c:\data

#Navigating Registry
cd HKLM:\SOFTWARE
Get-ChildItem
$reg = "HKLM:\SOFTWARE\XMind"
get-itemproperty -path $reg -Name path
#Create/delete Key
New-item -type registrykey -path hkcu:\software\test
Remove-Item -Path hkcu:\software\test
#Create registry value: Example of 2 values needed for Win7/Samba Environment
$LM= 'HKLM:\SYSTEM\CurrentControlSet\services\LanmanWorkstation\Parameters'
New-ItemProperty -Path $LM  -Name DomainCompatibilityMode -PropertyType DWord -Value 1 -ErrorAction:SilentlyContinue | Out-Null
New-ItemProperty -Path $LM  -Name DNSNameResolutionRequired -PropertyType DWord -Value 0 -ErrorAction:SilentlyContinue | Out-Null

#endregion

#region Modules = self-contained units of cmdlets,drives,functions,..
#Used by PS (Core,..) itself and by 3th party to extend functionality
Get-module -listavailable
#Auto-module loading since PS3.0
Import-module name

#DISM (copy from ADK in image)
Mount-WindowsImage
Get-Command -Module DISM
Get-WindowsDriver
Get-WindowsPackage

#ScheduledJob Ex
Register-ScheduledJob –Name Archive-Scripts -ScriptBlock { dir $home\*.ps1 -Recurse | Copy-Item -Destination \\Server\Share\PSScriptArchive }
help Register-ScheduledJob -Examples

#ShowUI (in Win7 image)
#ISLP NetConfig
Get-Command -Module ShowUI
Get-UICommand
. "C:\Users\Kurt\Documents\Microsoft Script Explorer\ShowUI-ISLP.ps1"

#endregion

#region Use with XML, .NET, COM, WMI
# COM CLSID: Scripting.FileSystemObject, Shell.Application, Wscript.shell,WScript.Network,..
$firewall = New-Object -com HNetCfg.FwMgr
$firewall.LocalPolicy.CurrentProfile

# .NET
# List every .NET type :-D
[System.AppDomain]::CurrentDomain.GetAssemblies() | Foreach-Object  {$_.GetTypes() }

#Create new .NET Object
$netweb = new-object -TypeName System.Net.WebClient
$netweb | Get-Member
$netweb.DownloadString("<file>")

# Static members in .NET: System.Math System.Environment io.directory System.IO.File System.Net.Dns
[System.Environment] | gm -Static # Example
[System.Net.Dns] | gm -Static #Example

# WMI
Get-WmiObject -list | where {$_.name -like "*Win32_*"}
Get-CimInstance -ClassName Win32_Computersystem
Get-CimInstance -ClassName Win32_BIOS
Get-CimInstance -ClassName Win32_Operatingsystem

#endregion

#region Use normal commands with PS
ipconfig /all | sls ipv4
 (ipconfig)[11]
 gpresult /R | Out-GridView
 #endregion

#region Advanced Examples

# Read RSS feeds in Parallel using a Workflow
$feeds =
    @{Name="DevelopmentInABlink";Url ="http://feeds.feedburner.com/DevelopmentInABlink"},
    @{Name="PowershellMagazine";Url ="http://feeds.feedburner.com/PowershellMagazine"},
    @{Name="Microsoft";Url ="http://blogs.msdn.com/b/mainfeed.aspx?Type=BlogsOnly"},
    @{Name ="Daily SHow";Url ="http://www.indecisionforever.com/feed/"}

Workflow Get-Feeds ([Hashtable[]]$feeds ) {   
    ForEach -Parallel ($feed in $feeds ) {
        Invoke-RestMethod -Uri $feed.url |
        Select -Property Title, pubdate  |
        Add-Member -PassThru -MemberType NoteProperty -Name Source -Value $feed.Name
    }
}
Get-Feeds $feeds | Select-Object * | Out-GridView 

#Check if administrator
(New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::`
GetCurrent())).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

#Out-Gridview -passtru
Get-Service | Where Status -eq Stopped | Out-GridView -PassThru | Start-Service

#Listing windows updates
$Session = New-Object -ComObject Microsoft.Update.Session
$Searcher = $Session.CreateUpdateSearcher()
$HistoryCount = $Searcher.GetTotalHistoryCount()
$Searcher.QueryHistory(1,$HistoryCount) |
Select-Object Date, Title, Description

#create profile if don't exist
if (!(test-path $profile)) { new-item -path $profile -itemtype file -force }

#Get SId of local user
$objUser = New-Object System.Security.Principal.NTAccount("administrator" )
$strSID = $objUser. Translate([System.Security.Principal.SecurityIdentifier ])
$strSID.Value 

#Read local group policy in PS via xml
gpresult /x gpo.xml
[xml]$gpo = get-content gpo.xml
$gpo.Rsop.ComputerResults.Extensiondata.extension.policy | select Name,State




#endregion

 help about_Windows_PowerShell_3.0