#Install msi file on multiple pc's
$computername = Get-Content 'M:\Applications\Powershell\comp list\Test.txt'
$sourcefile = "\\server\Apps\LanSchool\Windows\Student.msi"
#This section will install the software
foreach ($computer in $computername) {
 $destinationFolder = "\\$computer\C$\download\LanSchool"
 #This section will copy the $sourcefile to the $destinationfolder. If the Folder does not exist it will create it.
 if (!(Test-Path -path $destinationFolder))  {New-Item $destinationFolder -Type Directory }
 Copy-Item -Path $sourcefile -Destination $destinationFolder
 Invoke-Command -ComputerName $computer -ScriptBlock { & cmd /c "msiexec.exe /i c:\download\LanSchool\Student.msi" /qn}
}