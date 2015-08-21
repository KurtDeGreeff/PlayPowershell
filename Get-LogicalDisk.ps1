#requires -Version 3

function Get-LogicalDisk {
<#
.SYNOPSIS
   The function Get-LogicalDisk reports the disk capacity and freespace and output the result in an HTML.

.DESCRIPTION
   The function Get-LogicalDisk reports the disk capacity and freespace and output the result in an HTML.
   It can be run against one or more computers.
   It requires PowerShell version 3 (for CIM Cmdlets and ordered hashtable)

.PARAMETER ComputerName
   Specify a ComputerName or IP Address.
   Default is Localhost.

.PARAMETER ErrorLog
   Specify the full path of the Error log file.
   Default is .\Errors.log.

.PARAMETER Credential
   Specify the credential if different from the current user

.PARAMETER Directory
   Specify the full path of the directory where the HTML reports should be dropped.
   Default is C:\Scripts

.EXAMPLE
   Get-LogicalDisk

   This example report information about the logical localhost. By Default, if you don't specify
   a ComputerName, the function will run against the localhost.
   No Output will show on the screen, Output is sent to HTML file (default is C:\scripts)

.EXAMPLE
   Get-LogicalDisk -ComputerName SERVER01,SERVER02,SERVER03 -Credential (Get-Credential) -Directory C:\Scripts

   This example will report disk usage on SERVER01, SERVER02 and SERVER03.
   You will be prompted for Credential (see Get-Help Get-Credential)
   No Output will show on the screen, Output is sent to HTML file (default is C:\scripts)

.INPUTS
   System.String

.OUTPUTS
   HTML File

.NOTES
   Scripting Games 2013 - Advanced Event #3
#>

    [CmdletBinding()]

    PARAM(
        [Parameter(ValueFromPipeline)]
        [ValidateNotNullorEmpty()]
        [String[]]$ComputerName = $env:ComputerName,
        
        [String]$ErrorLog = ".\Errors.log",
        
        [Alias("RunAs")]
        [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty,

        [Alias("Path")]        
        [ValidateScript({Test-Path -path $_})]
        [String]$Directory = "C:\scripts\"
        
    )#end Param

    BEGIN {}

    PROCESS{
        FOREACH ($Computer in $ComputerName) {

            # Building Splatting for CIM Sessions
            $CIMSessionParams = @{
                ComputerName  = $Computer
                ErrorAction   = 'Stop'
                ErrorVariable = 'ProcessError'}

            TRY {
                $Everything_is_OK = $true

                # Credential
                IF ($PSBoundParameters['Credential']) {$CIMSessionParams.credential = $Credential}
                
                # Connectivity Test
                Write-Verbose -Message "$Computer - Testing Connection..."
                Test-Connection -ComputerName $Computer -count 1 -Quiet -ErrorAction Stop | Out-Null

                # WSMan Connection
                IF ((Test-WSMan -ComputerName $Computer -ErrorAction SilentlyContinue).productversion -match 'Stack: 3.0'){
                    Write-Verbose -Message "$Computer - WSMAN is responsive"
                    $CimSession = New-CimSession @CIMSessionParams
                    $CimProtocol = $CimSession.protocol
                    Write-Verbose -message "$Computer - [$CimProtocol] CIM SESSION - Opened"
                    $LogicalDiskInfo = Get-CimInstance -CimSession $CimSession -ClassName win32_LogicalDisk -Filter "DriveType='3'" -Property DeviceID,Size,Freespace,systemname
                }ELSE {

                    # Trying with DCOM protocol
                    Write-Verbose -Message "$Computer - Trying to connect via DCOM protocol"
                    $CIMSessionParams.SessionOption = New-CimSessionOption -Protocol Dcom
                    $CimSession = New-CimSession @CIMSessionParams
                    $CimProtocol = $CimSession.protocol
                    Write-Verbose -message "$Computer - [$CimProtocol] CIM SESSION - Opened"
                    $LogicalDiskInfo = Get-CimInstance -CimSession $CimSession -ClassName win32_LogicalDisk -Filter "DriveType='3'" -Property DeviceID,Size,Freespace,systemname
                }
            }

            CATCH{

                $Everything_is_OK = $false
                Write-Warning -Message "Error on $Computer"
                $Computer | Out-file -FilePath $ErrorLog -Append -ErrorAction Continue
                $ProcessError | Out-file -FilePath $ErrorLog -Append -ErrorAction Continue
                Write-Warning -Message "Logged in $ErrorLog"
            }

            IF ($Everything_is_OK){

                Write-Verbose -Message "$Computer - Generating HTML Report"
                $Report = $LogicalDiskInfo | Select-Object @{Label="Drive";Expression={$_.DeviceID}},
                    @{Label="Size(GB)";Expression={"{0:N2}" -f ($_.Size/1GB)}},
                    @{Label="FreeSpace(MB)";Expression={"{0:N2}" -f ($_.FreeSpace/1MB)}}| 
                    ConvertTo-Html -Fragment
                
                # Building Splatting for the HTML Report Sessions
                $HTMLParams = @{
                    Head  = "<title>Disk Free Space Report</title><h2>$Computer - Local Fixed Disk Report</h2>"
                    As    = "Table"
                    PostContent = "$Report<br><hr><br>$(Get-Date)"
                }

               ConvertTo-Html @htmlparams | Out-File -FilePath $Directory\$COMPUTER.html
            }
        } # FOREACH
    }#PROCESS
}#Function