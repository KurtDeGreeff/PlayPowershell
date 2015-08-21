function Test-Connection {
    [CmdletBinding(DefaultParameterSetName='Default', HelpUri='http://go.microsoft.com/fwlink/?LinkID=135266', RemotingCapability='OwnedByCommand')]
    param(
        [Parameter(ParameterSetName='Default')]
        [Parameter(ParameterSetName='Source')]
        [switch]
        ${AsJob},

        [System.Management.AuthenticationLevel]
        ${Authentication},

        [Alias('Size','Bytes','BS')]
        [ValidateRange(0, 65500)]
        [int]
        ${BufferSize},

        [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
        [Alias('CN','IPAddress','__SERVER','Server','Destination')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${ComputerName},

        [ValidateRange(1, 4294967295)]
        [int]
        ${Count},

        [Parameter(ParameterSetName='Source')]
        [ValidateNotNullOrEmpty()]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${Credential},

        [Parameter(ParameterSetName='Source', Mandatory=$true, Position=1)]
        [Alias('FCN','SRC')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Source},

        [System.Management.ImpersonationLevel]
        ${Impersonation},

        [Parameter(ParameterSetName='Source')]
        [Parameter(ParameterSetName='Default')]
        [ValidateRange(-2147483648, 1000)]
        [int]
        ${ThrottleLimit},

        [Alias('TTL')]
        [ValidateRange(1, 255)]
        [int]
        ${TimeToLive},

        [ValidateRange(1, 60)]
        [int]
        ${Delay},

        [Parameter(ParameterSetName='Quiet')]
        [switch]
        ${Quiet},

        [Parameter()]
        [switch]
        ${Resolve})

    begin
    {
        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }

            if ($PSBoundParameters['Resolve']) {
                $null = $PSBoundParameters.Remove('Resolve')
                foreach ($item in $ComputerName) {
                    try {
                        $item -match [IPAddress]$item
                        [string[]]$ComputerNameEx += ([System.Net.Dns]::GetHostEntry($item)).HostName
                    }
                    catch {
                        [string[]]$ComputerNameEx += $item
                    }
                }
                $PSBoundParameters['ComputerName'] = $ComputerNameEx
            }          

            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Management\Test-Connection', [System.Management.Automation.CommandTypes]::Cmdlet)
            $scriptCmd = {& $wrappedCmd @PSBoundParameters }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        } catch {
            throw
        }
    }

    process
    {
        try {
            $steppablePipeline.Process($_)
        } catch {
            throw
        }
    }

    end
    {
        try {
            $steppablePipeline.End()
        } catch {
            throw
        }
    }
    <#

    .ForwardHelpTargetName Test-Connection
    .ForwardHelpCategory Cmdlet

    #>
}