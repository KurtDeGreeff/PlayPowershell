 Function Invoke-AsSystem {
    #
    # Invoke-AsSystem is a quick hack to run a PS ScriptBlock as the System account
    # It is possible to pass and retrieve object through the pipeline, though objects
    # are passed as serialized objects using export/clixml.
    # 

    param(
        #[Parameter(Mandatory=$true)]
        [scriptblock] $Process={ ls},
        [scriptblock] $Begin={} ,
        [scriptblock] $End={} ,
        [int] $Depth = 4
    )
    begin {
        Function Test-Elevated {
            $wid=[System.Security.Principal.WindowsIdentity ]::GetCurrent()
            $prp=new-object System.Security.Principal.WindowsPrincipal($wid )
            $adm=[System.Security.Principal.WindowsBuiltInRole ]::Administrator
            $prp.IsInRole( $adm)
        }
    $code = @"
using System;
using System.ServiceProcess;
namespace CosmosKey.Powershell.InvokeAsSystemSvc
{
    class TempPowershellService : ServiceBase
    {
        static void Main()
        {
            ServiceBase.Run(new ServiceBase[] { new TempPowershellService() });
        }
        protected override void OnStart(string[] args)
        {
            string[] clArgs = Environment.GetCommandLineArgs();
            try
            {
                string argString = String.Format(
                    "-command .{{import-clixml '{0}' | .'{1}' | export-clixml -Path '{2}' -Depth {3}}}",
                    clArgs[1],
                    clArgs[2],
                    clArgs[3],
                    clArgs[5]);
                System.Diagnostics.Process.Start("powershell", argString).WaitForExit();
                System.IO.File.AppendAllText(clArgs[4], "success");
            }
            catch (Exception e)
            {
                System.IO.File.AppendAllText(clArgs[4], "fail\r\n" + e.Message);
            }
        }
        protected override void OnStop()
        {
        }
    }
}
"@
        if( -not (Test-Elevated)) {
            throw "Process is not running as an eleveated process. Please run as elevated."
        }
        [void][ System.Reflection.Assembly]::LoadWithPartialName( "System.ServiceProcess")  
        $serviceNamePrefix = "MyTempPowershellSvc"
        $timeStamp = get-date -Format yyyyMMdd-HHmmss
        $serviceName = "{0}-{1}" -f $serviceNamePrefix ,$timeStamp
        $tempPSexe   = "{0}.exe" -f $serviceName ,$timeStamp
        $tempPSout   = "{0}.out" -f $serviceName ,$timeStamp
        $tempPSin    = "{0}.in"  -f $serviceName ,$timeStamp
        $tempPSscr   = "{0}.ps1" -f $serviceName ,$timeStamp
        $tempPScomplete   = "{0}.end" -f $serviceName ,$timeStamp
        $servicePath = Join-Path $env:temp $tempPSexe
        $outPath     = Join-Path $env:temp $tempPSout
        $inPath      = Join-Path $env:temp $tempPSin
        $scrPath     = Join-Path $env:temp $tempPSscr
        $completePath     = Join-Path $env:temp $tempPScomplete
        $serviceImagePath = "`"{0}`" `"{1}`" `"{2}`" `"{3}`" `"{4}`" {5}" -f $servicePath,$inPath ,$scrPath, $outPath,$completePath ,$depth
        Add-Type $code -ReferencedAssemblies "System.ServiceProcess" -OutputAssembly $servicePath -OutputType WindowsApplication | Out-Null
        $objectsFromPipeline = new-object Collections.ArrayList
        $script = "BEGIN {{{0}}}`nPROCESS {{{1}}}`nEND {{{2}}}" -f $Begin.ToString() ,$Process. ToString(),$End.ToString()
        $script.ToString() | Out-File -FilePath $scrPath -Force    
    }
 
    process {
        [void] $objectsFromPipeline.Add( $_)
    }
 
    end
    {
        $objectsFromPipeline | Export-Clixml -Path $inPath -Depth $Depth
        New-Service -Name $serviceName -BinaryPathName $serviceImagePath -DisplayName $serviceName -Description $serviceName -StartupType Manual | out-null
        $service = Get-Service $serviceName
        $service.Start() | out-null
        while ( -not (test-path $completePath)) {
            start-sleep -Milliseconds 100
        }
        $service.Stop() | Out-Null
        do {
            $service = Get-Service $serviceName
        } while($service.Status -ne "Stopped")
        ( Get-WmiObject win32_service -Filter "name='$serviceName'" ).delete() | out-null
        Import-Clixml -Path $outPath
        Remove-Item $servicePath -Force | out-null
        Remove-Item $inPath       -Force | out-null
        Remove-Item $outPath      -Force | out-null
        Remove-Item $scrPath      -Force | out-null
        Remove-Item $completePath      -Force | out-null
    }
}
