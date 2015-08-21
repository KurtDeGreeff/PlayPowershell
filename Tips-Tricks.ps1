
<!-- saved from url=(0076)https://raw2.github.com/fabiendibot/TD/master/%5BTD%5D%20-%20Tips&Tricks.ps1 -->
<html><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"><style type="text/css"></style></head><body><pre style="word-wrap: break-word; white-space: pre-wrap;">## PowerShell - 45 Tips &amp; Tricks (minimum) pour votre utilisation quotidienne

#################
## Généralités ##
#################

# Pour commencer
# Présentation ISE
# - Tab
# - Editer &gt; DÃ©marrer les extraits
# - Remote Tabs
# - F1 et Get-Command

# Empecher le chargement automatique des modules
$PSModuleAutoLoadingPreference="none"

# Débloquer une DLL
 Unblock-File D:\demo-techdays-2014\Renci.SshNet.dll

# Tester si le compte qui exécute le script est "Administrateur"
[bool]((whoami /all) -match "S-1-16-12288")

# Utilisation du pipeline (ou pas)
Get-Process | Where-Object { $_.Name -like "*a*" }
Get-Process | Where-Object Name -like "*a*"
(Get-Process).where({$_.name -like "*a*"})

Get-Process | Where-Object -Property PM -GT -Value 100MB
Get-Process | Where -Value 100MB -Property PM -GT
Get-Process | Where -GT PM 100MB
Get-Process | Where PM 100MB -GT
gps | Where PM 100MB -GT
gps|? PM 100MB -GT

1..12 | Foreach { $_ }
65..90 | % { [char]$_ }
(1..27).foreach({$_})

# Suppression des doublons
Get-Process | Where-Object Name -like "*a*" | Select-Object -Unique
Measure-Command {Get-Process | Where-Object Name -like "*a*" | Select-Object -Unique}
Get-Process | Where-Object Name -like "*a*" | Get-Unique
Measure-Command {Get-Process | Where-Object Name -like "*a*" | Get-Unique}

# Générer un log d'exécution de votre commande/script
Start-Transcript -Path D:\demo-techdays-2014\Powershell.log
Get-Process | Where-Object Name -like "*a*" | Select-Object -Unique
Measure-Command {Get-Process | Where-Object Name -like "*a*" | Select-Object -Unique}
Get-Process | Where-Object Name -like "*a*" | Get-Unique
Measure-Command {Get-Process | Where-Object Name -like "*a*" | Get-Unique}
Stop-Transcript

# Sortir le résutlat d'une commande dans un fenêtre
gps | ? Name -li "*a*" | Out-GridView

# Ou dans le clipboard
gps | ? Name -li "*a*" | Clip

# Lister les classes WMI de votre ordinateur
Get-WMIObject -List
Get-WMIObject -List | Where Name -like "*Computer*"

# Get-WMIObject = Get-CIMInstance ?
Get-WmiObject -ComputerName . -Class Win32_ComputerSystem 
Get-CimInstance -ComputerName . -ClassName Win32_ComputerSystem 

Measure-Command {Get-WmiObject -ComputerName . -Class Win32_ComputerSystem}
Measure-Command {Get-CimInstance -ComputerName . -ClassName Win32_ComputerSystem}

# L'operateur format
$OperatingSystem = Get-WmiObject -ComputerName . Win32_OperatingSystem
    "{0} {1} ({2})" -f $OperatingSystem.Caption, $OperatingSystem.CSDVersion, $OperatingSystem.Version

[string]$nom = 'Carlo'
[string]$affirmation = 'PowerShell rocks'
	"Monsieur {0} dit que {1}!" -f $nom, $affirmation

"{0:c}" -f  12.34

"{0:hh:mm:ss tt}" -f (get-date) # affiche l'heure au format 12h

"{0:HH:mm:ss}" -f (get-date) # affiche l'heure au format 24h
    
"{0:p4}" -f (1/3) # affiche un pourcentage avec 4 chiffres decimales
	
0..5 | % {"|{0,33}|" -f "Number $_"} # numero aligné à droite
	
0..5 | % {"|{0,-33}|" -f "Number $_"} # numero aligné à gauche

$system = Get-WmiObject -class  Win32_ComputerSystem
$memory = $system.TotalPhysicalMemory
"Ce système a {0:N2} MB de RAM" -f ($memory/1MB)

# Générer un GUID 
[GUID]::NewGuid()

# Façons d'ouvrir un ficher
Invoke-Item C:\Windows\WindowsUpdate.log
ii C:\Windows\WindowsUpdate.log
. C:\Windows\WindowsUpdate.log
'C:\Windows\WindowsUpdate.log' | ii

# Lire un fichier de log en une seule fois, plus performant
Measure-Command -Expression { Get-Content D:\demo-techdays-2014\grosfichier.txt }
Measure-Command -Expression { Get-Content D:\demo-techdays-2014\grosfichier.txt -ReadCount 0 }


# Programmer une tâche planifiée
$Trigger = New-JobTrigger -Daily -At 3am
Register-ScheduledJob -Name DailyBackup -Trigger $trigger -ScriptBlock {Copy-Item c:\ImportantFiles d:\Backup$((Get-Date).ToFileTime()) -Recurse -Force -PassThru}

# Verifier si un fichier/Chemin existe
Test-Path C:\Windows

# Compter des objets
(gcm).count
(gci d:\folder).count
(Get-ADUser).count

# Lister les evenement du jour
Get-EventLog -LogName application -After ((date)+-1d) | Out-GridView

# Trouver les logs d'evenement les plus actifs
Get-WinEvent -ListLog * | sort recordcount -Descending | Select-Object -First 10

# Tuer un processus s'il existe (ici, prenons l'exemple du processus notepad)
Start-Process notepad
Get-Process | ForEach-Object {If ($_.ProcessName -eq "notepad") {$_.Kill()}}

#Comment afficher les chemins des répertoires spéciaux comme "Mes Documents" ?
# Il suffit d\'utiliser conjointement la méthode GetFolderPath de la classe System.Environment et l'énumeration SpecialFolder de la classe System.Environment.
[enum]::getvalues([system.environment+specialfolder]) | foreach {"$_ est mappé sur " + [system.Environment]::GetFolderPath($_)}

#Surveiller un fichier de log, et un apreÃ§u des expressions regulieres (regex)
gci C:\Windows *update*.log -rec | gc -Wai | Select-String "warning|error" 

#Changer la langue de son clavier
Set-WinUserLanguageList -LanguageList en-US

# COmpresser / décompresser un fichier
$file = Get-WmiObject -Query "SELECT * FROM CIM_DataFile WHERE Name='D:\\demo-techdays-2014\\Renci.SshNet.dll'"
$file.Compress()

$file = Get-WmiObject -Query "SELECT * FROM CIM_DataFile WHERE Name='D:\\demo-techdays-2014\\Renci.SshNet.dll'"
$file.Uncompress()

###################
## Les Variables ##
###################
 
# Forcer un type de variable
[Int]$a = "test"
[Int]$a = 1
[String]$a = "test"
$a = "test"

# Retrouver facilement les méthodes, propriétés et events d'une variable
# Peut-être le meilleur cmdlet !
"Ceci n'est pas un test" | Get-Member

#################
## Les réseaux ##
#################

# Valider une adresse IP (méthode moche)
$ip = '192.168.1.1'
$FalseIP = '277.159.648.1'
$Pattern = @"
^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$
"@
$ip -match $Pattern
$FalseIP -match $Pattern

# Valider une adresse IP (méthode .NET)
if ($ip -as [IPAddress]) {"Ceci est une adresse IP"}
if ([ipaddress]"192.168.1.1"){'true'}

#Bye bye route print, vive Get-NetRoute
get-netroute
Remove-NetRoute
Set-NetRoute

# Remplacement du Ping
Test-Connection win-2012R2-2
Test-Connection win-2012R2-3,win-2012R2-2,win-2008R2-2
Test-Connection win-2012R2-2 -count 1 | fl *
Test-Connection -Source win-2012R2-3 -Destination win-2012R2-2,win-2008R2-2
$panier = @("win-2012R2-2","win-2012R2-3","win-2008R2-1")
Test-Connection -Source $panier -Destination $panier -Count 1

# Et son évolution
Test-NetConnection | fl *
Test-NetConnection -InformationLevel Quiet
Test-NetConnection -InformationLevel Detailed
Test-NetConnection -CommonTCPPort SMB -ComputerName win-2012R2-2 | select TcpTestSucceeded
Test-NetConnection -CommonTCPPort RDP -ComputerName win-2012R2-2 | select TcpTestSucceeded
Test-NetConnection -CommonTCPPort WINRM -ComputerName win-2012R2-2 | select TcpTestSucceeded
Test-NetConnection -CommonTCPPort HTTP -ComputerName win-2012R2-2 -InformationLevel Quiet
Test-NetConnection -CommonTCPPort HTTP -ComputerName win-2012R2-2 | select TcpTestSucceeded
Test-Netconnection www.bing.fr -TraceRoute

# Comment partage un dossier avec ACL en une ligne
New-SmbShare -Name "Partage" -Path D:\temp -Description "Test Shared Folder" -FullAccess carlo -ChangeAccess jack -ReadAccess Everyone
Remove-SmbShare -Name "Partage" -Force

# Lister les cartes reseau
$Adapters = Get-WmiObject -ComputerName . Win32_NetworkAdapter | 
                Where-Object{$_.MACAddress} |
                Where-Object{$_.NetConnectionID} |
                Where-Object{$_.NetConnectionID -notlike "*1394*"} |
                Where-Object{$_.NetConnectionID -notlike "*Bluetooth*"} |
                Where-Object{$_.Description -notlike "*VPN*"}
$Adapters | select netconnectionid, MACaddress,Name,Speed

$Adapters | select netconnectionid, MACaddress,Name,@{Label="Speed"; Expression={$_.speed/1GB}}

$Adapters | select netconnectionid, MACaddress,Name,@{L="Speed"; ; E={[math]::round(($_.Speed / 1GB),0)}}


##################
## Les tableaux ##
##################

# Créer un tableau et y ajouter des valeurs
$Array = New-Object System.Collections.ArrayList
$Array.add("1")
$Array.add("2")
$Array.add("3")
$Array.add("Hourray!")
$Array

# Trier le tableau
$Array.Sort()
$Array | Sort

# Suppression d'une valeur
$Array.Remove("Hourray!")
$Array.Sort()

#Inverser l'ordre
$Array.Reverse()

# Tester la présence d'une valeur
1 -In $Array
20 -NotIn $Array

# vider le tableau
$Array.Clear()
$Array


###################
## Les Fonctions ##
###################

Function Get-Report {
    Get-Service | ConvertTo-Html | Out-File F:\output.html
    ii D:\demo-techdays-2014\Output.html
}

Get-Report

Function Get-RSS {
    # Invoke-RestMethod 
    $Output = @()
    $url = "http://channel9.msdn.com/Feeds/RSS"
    Invoke-RestMethod -Uri  $url | Foreach {
        $props = [ordered]@{"Date"=$_.PubDate -as [datetime];
                            "Titre"=$_.title;
                            "Description"=$_.Summary
                            }
        $Output += New-Object -TypeName PSCUstomObject -Property $props
    }
    $Output
}

Get-RSS
Get-RSS | Sort-Object Date -Descending

Function Test-MSTechdays {
&lt;#
    .SYNOPSIS
        Ceci n'est pas une fonction
#&gt;
    param (
        # Ceci est une déclaration de computerName
        $Path,
        # Ceci est le nom de votre réseau
        [String]$Network,
        [ValidateRange(1,5)]
        [int]$Test
    )
    Try {
        Test-Path $Path -ea stop
        #throw [invalidoperationexception]
    }
    Catch [exception] {
        Throw "This is a test. Error: $($_.Exception.Message)"
    }
    Finally {
        "Hello World"
    }
}


Test-MSTechdays -IPAddress "WIN-2008R2-1" -Network "Techdays" -Test 1
Test-MSTechdays -IPAddress "toto" -Network "MSTechdays" -Test 1
Get-Help Test-MSTechdays -Parameter *

# Un petit inventaire de ma connectivité reseau
Function Get-Networkinfo {
&lt;#
    .SYNOPSIS
        Je me fais un check-up reseau
#&gt;
    param (
            [string]$computername = 'localhost'
          )
    
    "Mon IP est : $((Get-NetIPAddress -InterfaceAlias "ethernet*" -AddressFamily IPv4).IPAddress)"
    $remotehosts = @("win-2012R2-2","win-2012R2-3","win-2008R2-2")
    if(Test-Connection -Destination $computername -Source (Get-Random $remotehosts) -Count 1)
        {"I am open for pings!"}
    else
        {"No ICMP, please!"}
    "SMB","HTTP","WINRM","RDP" | % {
            if(Test-NetConnection -ComputerName $computername -CommonTCPPort $_ -InformationLevel Quiet){
                "Mon port $_ est ouvert"
                }
            else
                {
                "Pas dispo pour du $_"
                }
            }
}

Get-Networkinfo -computername  win-2012R2-2

# Inventorier les fichiers qui ont été modifiés ajourd'hui
function Get-UpdatedFiles{

Param(
    [DateTime]$date = [DateTime]::Today,
    [Switch]$before=$False
     )

Process
    {
    if(($_.LastWriteTime -ge $date) -xor $before)
        {
        Write-Output $PSItem
        }
    }

}

Set-Item -Value Get-UpdatedFiles -Path alias:guf

#Donc je peux effectuer:
Set-Location c:\
1..5 | % { New-Item "$_.txt" -ItemType file }
Get-ChildItem | Get-UpdatedFiles

#ou bien:
ls | Get-UpdatedFiles "1/1/2014"

#Pour voir les fichiers et les dossier modifie avant aujourd'hui:
dir | Get-UpdatedFiles -before


######################
## Active Directory ##
######################

# Remplir de manière simple votre AD
Get-Content C:\divers\users.csv 
Import-Csv C:\divers\users.csv -Delimiter ";" -Header "samaccountname","name","givenname","fax" | ForEach {
    New-ADUser -Name $_.samaccountname -SamAccountName $_.samAccountName -givenname $_.givenname -UserPrincipalName $($_.samaccountname + "@contoso.com") -fax $_.fax -Surname $_.name -DisplayName $($_.name + " " + $_.givenname).ToLower() -Description "Compte utilisateur pour dÃ©mo Techdays"
}

##### Petite digression: ameliorer la lisibilite de son code avec un coup de splatting
Get-Content C:\divers\users.csv 
Import-Csv C:\divers\users.csv -Delimiter ";" -Header "samaccountname","name","givenname","fax" | ForEach {
    $splatting = @{
        Name = $_.samaccountname
        SamAccountName = $_.samAccountName
        GivenName = $_.givenname
        UserPrincipalName = $_.samaccountname + "@contoso.com"
        Fax = $_.fax
        Surname = $_.name
        DisplayName = $($_.name + " " + $_.givenname).ToLower()
        Description = "Compte utilisateur pour dÃ©mo Techdays"
    }
    New-ADUser @splatting
}

### Simpa le splatting, n'est-ce pas? Continuons Ã&nbsp; manipuler l'AD maintenant:
Get-ADUser eferrari | Format-List *
Get-ADGroup 'domain admins' | Format-List *
Get-Content C:\divers\groups.txt | forEach { New-ADGroup -GroupScope 1 -Name $_ -Description "Groupe Global pour demo Techdays" }
Import-Csv C:\divers\user_group.csv -Delimiter ";" -Header "user","groupname" | foreach {
    Add-ADGroupMember -Identity $_.groupname -members $_.user
}

Get-ADGroup -Filter * -Properties Members  | where { -not $_.Members} | select Name 
Get-ADGroup -filter 'description -eq "Groupe Global pour dÃ©mo Techdays"' | select name
Get-ADGroup -filter 'name -eq "IT"' | % { Get-ADUser -Filter 'memberof -eq $_.distinguishedname' }
Get-ADGroup -filter 'name -eq "IT"' | % { Get-ADUser -Filter 'memberof -eq $_.distinguishedname' | select Givenname,Surname}
</pre></body></html>