# NAME  : Get-ComputerInventory
# AUTHOR: Francois-Xavier Cat
# EMAIL : fxcat@LazyWinAdmin.com
# DATE  : 2013/02/10 

Function Get-ComputerInventory {
        <#
        .SYNOPSIS 
        The Get-ComputerInventory function gets information about a local or 
        Remote machine(s) specified by the parameter ComputerName.
    
        .DESCRIPTION
        The Get-ComputerInventory function gets information about a local or 
        Remote machine(s) specified by the parameter ComputerName.
    
        .PARAMETER ComputerName
         Specifies the target computer for the management operation. The value can 
        be a fully qualified domain name, a NetBIOS name, or an IP address. To 
        specify the local computer, use the local computer name, use localhost, or 
        use a dot (.)
    
        .INPUTS
        System.String
    
        .OUTPUTS
        System.Management.Automation.PSObject

        .EXAMPLE
         Get-ComputerInventory -ComputerName PC01
        
        This command gets inventory information about the Computer PC01.
    
        .EXAMPLE
         "SERVER01","SERVER02" | Get-ComputerInventory
        
        This command gets inventory information about SERVER01 and SERVER02.
        Get-ComputerInventory accepts Input from the pipeline.
    
        .NOTES
        NAME  : Get-ComputerInventory
        AUTHOR: Francois-Xavier Cat
        EMAIL : fxcat@LazyWinAdmin.com
        DATE  : 2013/02/10
    
        .LINK
        http://lazywinadmin.com
        #>

    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True,Mandatory=$true)]
        [string[]]$ComputerName
    )
    BEGIN {# Setup
        }
    PROCESS {
        Foreach ($Computer in $ComputerName) {
            Write-Verbose -Message "ComputerName"

            try {
                
                # Gather Win32_ComputerSystem information for the current $Computer
                $WMIComputerSystem = Get-WmiObject -Class Win32_Computersystem -ComputerName $Computer -ErrorAction 'Stop'
                
                # Gather Win32_BIOS information for the current $Computer
                $WMIBios = Get-WmiObject -Class win32_bios -ComputerName $Computer -ErrorAction 'Stop'

                $TryIsOK = $True
                
            }#Try
            
            Catch {
                # Send the Errors in the Errors.txt file.
                "$Computer" | Out-File -Append -FilePath Errors.txt
                $TryIsOK = $False
                
            }#Catch
            
            if ($TryIsOK) {

                $output =    @{'ComputerName'=$Computer;
                            'Model'=$WMIComputerSystem.model;
                            'Manufacturer'=$WMIComputerSystem.Manufacturer;
                            'LogicalProcs'=$WMIComputerSystem.NumberOfLogicalProcessors;
                            'PhysicalRam'=("{0:N0}" -f($WMIComputerSystem.TotalPhysicalMemory/1GB));
                            'BIOSSerial'= $WMIBios.SerialNumber}
                    
                # Create a new PowerShell object for the output
                $object = New-Object -TypeName PSObject -Property $output
                $object.PSObject.TypeNames.Insert(0,'Report.ComputerInventory')

                # Show the Output
                Write-Output -InputObject $output

            }#if ($TryIsOK)

        }#Foreach ($Computer in $ComputerName)
        
    }#PROCESS

    END {# Cleanup
        }

}#Function Get-ComputerInventory