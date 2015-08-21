Function Get-DiskSizeInfo {
        <#
        .DESCRIPTION
        Check the Disk(s) Size and remaining freespace.

        .PARAMETER ComputerName
        Specify the computername(s)

        .INPUTS
        System.String

        .OUTPUTS
        System.Management.Automation.PSObject

        .EXAMPLE
        Get-DiskSizeInfo
        
        Get the drive(s), Disk(s) space, and the FreeSpace (GB and Percentage)

        .EXAMPLE
        Get-DiskSizeInfo -ComputerName SERVER01,SERVER02

        Get the drive(s), Disk(s) space, and the FreeSpace (GB and Percentage)
        on the Computers SERVER01 and SERVER02

        .EXAMPLE
        Get-Content Computers.txt | Get-DiskSizeInfo

        Get the drive(s), Disk(s) space, and the FreeSpace (GB and Percentage)
        for each computers listed in Computers.txt

        .NOTES
        NAME  : Get-DiskSizeInfo
        AUTHOR: Francois-Xavier Cat
        EMAIL : fxcat@LazyWinAdmin.com
        DATE  : 2013/02/05 
    
        .LINK
        http://lazywinadmin.com
        #>

    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )
    BEGIN {# Setup
        }
    PROCESS {
        Foreach ($Computer in $ComputerName) {
            
            Write-Verbose -Message "ComputerName: $Computer - Getting Disk(s) information..."
            try {
                # Set all the parameters required for our query
                $params = @{'ComputerName'=$Computer;
                            'Class'='Win32_LogicalDisk';
                            'Filter'="DriveType=3";
                            'ErrorAction'='SilentlyContinue'}
                $TryIsOK = $True
                
                # Run the query against the current $Computer    
                $Disks = Get-WmiObject @params
            }#Try
            
            Catch {
                "$Computer" | Out-File -Append -FilePath c:\Errors.txt
                $TryIsOK = $False
            }#Catch
            
            if ($TryIsOK) {
                Write-Verbose -Message "ComputerName: $Computer - Formating information for each disk(s)"
                foreach ($disk in $Disks) {
                    
                    # Prepare the Information output
                    Write-Verbose -Message "ComputerName: $Computer - $($Disk.deviceid)"
                    $output =         @{'ComputerName'=$computer;
                                    'Drive'=$disk.deviceid;
                                    'FreeSpace(GB)'=("{0:N2}" -f($disk.freespace/1GB));
                                    'Size(GB)'=("{0:N2}" -f($disk.size/1GB));
                                    'PercentFree'=("{0:P2}" -f(($disk.Freespace/1GB) / ($disk.Size/1GB)))}
                    
                    # Create a new PowerShell object for the output
                    $object = New-Object -TypeName PSObject -Property $output
                    $object.PSObject.TypeNames.Insert(0,'Report.DiskSizeInfo')
                    
                    # Output the disk information
                    Write-Output -InputObject $object
                    
                }#foreach ($disk in $disks)
                
            }#if ($TryIsOK)
            
        }#Foreach ($Computer in $ComputerName)
        
    }#PROCESS
    END {# Cleanup
        }
}#Function 
Get-DiskSizeInfo