#Define update criteria.

$Criteria = "IsInstalled=0 and Type='Software'"


#Search for relevant updates.

$Searcher = New-Object -ComObject Microsoft.Update.Searcher

$SearchResult = $Searcher.Search($Criteria).Updates


#Download updates.

$Session = New-Object -ComObject Microsoft.Update.Session

$Downloader = $Session.CreateUpdateDownloader()

$Downloader.Updates = $SearchResult

$Downloader.Download()


#Install updates.

$Installer = New-Object -ComObject Microsoft.Update.Installer

$Installer.Updates = $SearchResult

$Result = $Installer.Install()


#Reboot if required by updates.

If ($Result.rebootRequired) {} #{ shutdown.exe /t 0 /r }