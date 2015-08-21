Function Get-WMINamespace {
    <#
        .SYSNOPSIS
            Performs query for all WMI Namespaces

        .DESCRIPTION
            Performs query for all WMI Namespaces

        .PARAMETER Computername
            List of computernames to perform query

        .PARAMETER Namespace
            Namespace to use to query for additional namespaces

        .PARAMETER Credential
            Optional credentials for remote systems

        .PARAMETER Recurse
            List all Namespaces in the WMI Repository recursively

        .NOTES
            Name: Get-WMINamespace
            Author: Boe Prox
            Version History:
                Version 1.0 -- 30 Mar 2014
                    -Initial creation

        .OUTPUTS
            Wmi.Namespace.Name

        .EXAMPLE
            Get-WMINamespace

            Description
            -----------
            Lists all WMI namespaces on local computer

        .EXAMPLE
            Get-WMINamespace -Recurse

            Description
            -----------
            Lists all WMI namespaces recursively on local computer
    #>
    [OutputType('Wmi.Namespace.Name')]
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [Alias('__SERVER','IPAddress')]
        [string[]]$Computername = $env:COMPUTERNAME,
        [parameter()]
        [string]$Namespace='root',
        [parameter()]
        [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty,
        [parameter()]
        [switch]$Recurse
    )
    Begin {
        $WMIParams = @{
            Namespace = $Namespace
            Class = '__Namespace'
            ErrorAction = 'Stop'
        }
        If ($PSBoundParameters['Credential']) {
            Write-Verbose "Using alternate credentials"
            $WMIParams.Credential = $Credential
        }
        $PSBoundParameters.GetEnumerator() | ForEach {
            Write-Verbose $_
        }
    }
    Process {
        ForEach ($Computer in $Computername) {
            Try {
                $WMIParams.Computername = $Computer
                Get-WmiObject @WMIParams | ForEach-Object {
                        $WMIParams.namespace = "$($_.__Namespace)\$($_.Name)"
                        $Object = [pscustomobject] @{
                            Computername = $Computer
                            Namespace = $WMIParams.namespace
                        }
                        $Object.pstypenames.insert(0,'Wmi.Namespace.Name')
                        $Object
                        Try {
                            If ($Recurse) {
                                $PSBoundParameters.Namespace = $WMIParams.namespace
                                Get-WMINamespace @PSBoundParameters
                            }
                        } Catch {
                            Write-Warning "[$($Computer)] $($WMIParams.namespace): $($_)"
                        }
                }
            } Catch {
                Write-Warning "[$($Computer)] $($WMIParams.namespace): $($_)"
            }
        }
    }
}