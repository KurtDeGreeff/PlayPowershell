function Set-WindowsUpdates {
<# 
 .Synopsis
  Function to change Windows updates configuration on many computers

 .Description
  Function will change Windows Updates configuration on many computers to either 
  disable updates, check only, download only, or download and automatically install updates.

 .Parameter ComputerName
  Name(s) of computer(s) to change their Windows updates config

 .Parameter Options
  The following are the 4 valid options:
  NoCheck:      Never check for updates
  CheckOnly:    Check for updates but let me choose wether to download and install them
  DownloadOnly: Download updates but let me choose whether to install them
  Install:      Install updates automatically

 .Example
  Set-WindowsUpdates
  This example will set Windows Automatic Updates on the local computer to 
  'Install updates automatically'

 .Example
  Set-WindowsUpdates -ComputerName VMM01 -Options CheckOnly
  This example will set Windows Automatic Updates on computer 'VMM01' to 
  'Check for updates but let me choose wether to download and install them'
  
 .Example
  Set-WindowsUpdates -ComputerName (Get-Content ".\Computers.txt") -Options DownloadOnly -Verbose
  This example will set Windows Automatic Updates on computers listed in the file ".\Computers.txt" to 
  'Download updates but let me choose whether to install them'
  
 .Example
  Set-WindowsUpdates -ComputerName ((Get-ADComputer -Filter * ).Name) -Options Install 
  This example will set Windows Automatic Updates on all computers in AD to 
  'Install updates automatically'
  
 .Example
  $VMs = (Get-VM -ComputerName "HVHost01" | Where { $_.State -eq "Running" }).VMName
  Set-WindowsUpdates -ComputerName $VMs -Options CheckOnly 
  This example will set Windows Automatic Updates on all running VMs on the Hyper-V Host "HVHost01" to 
  'Check for updates but let me choose wether to download and install them'
  
 .Link
  https://superwidgets.wordpress.com/category/powershell/

 .Notes
  Function by Sam Boutros
  v1.0 - 09/21/2014
#>

    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')] 
    Param(
        [Parameter(Mandatory=$false,
                   ValueFromPipeLine=$true,
                   ValueFromPipeLineByPropertyName=$true,
                   Position=0)]
            [ValidateNotNullorEmpty()]
            [String[]]$ComputerName = "$env:COMPUTERNAME",
        [Parameter(Mandatory=$false,
                   Position=1)]
            [ValidateSet("NoCheck","CheckOnly","DownloadOnly","Install")]
            [String[]]$Options = "Install"
    )

    $k = 0 
    switch ($Options) { 
        "NoCheck"      { $AuOptions = 1; $Op = "Never check for updates" }
        "CheckOnly"    { $AuOptions = 2; $Op = "Check for updates but let me choose wether to download and install them" }
        "DownloadOnly" { $AuOptions = 3; $Op = "Download updates but let me choose whether to install them" }
        "Install"      { $AuOptions = 4; $Op = "Install updates automatically" }
    }
    $Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" 
     
    foreach ($Computer in $ComputerName) {
        try {
            $k++
            $Progress = "{0:N0}" -f ($k*100/$ComputerName.count)
            Write-Progress -Activity "Processing computer $Computer ... $k out of $($ComputerName.count) computers" `
                -PercentComplete $Progress -Status "Please wait" -CurrentOperation "$Progress% complete"
            Write-Verbose "Setting Windows Automatic Updates on computer '$Computer' to '$Op'"
            $Session = New-PSSession -ComputerName $Computer -ErrorAction Stop
            try {
                Set-ItemProperty -Path $Key -Name "AUOptions" -Value $AuOptions -ErrorAction Stop
                Set-ItemProperty -Path $Key -Name "CachedAUOptions" -Value $AuOptions
                Write-Output "Windows Automatic Updates on computer '$Computer' has been set to '$Op'"
            } catch {
                Write-Warning "Failed to set Windows Automatic Updates on computer '$Computer'"
            }
            Remove-PSSession -Session $Session
        } catch {
            Write-Warning "Computer $Computer is offline, does not exist, or cannot be contacted"
        }
    }
}