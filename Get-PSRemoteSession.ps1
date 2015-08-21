#requires -version 3.0

Function Get-PSRemoteSession {

<#
.SYNOPSIS
Get remote PSSession processes.
.DESCRIPTION
This command uses CIM to retrieve the wsmprovhost process that might be running
on a remote computer. You can use this information to determine how long a 
session has been running and by what user. By default the command shows a 
summary. If you want to see the full detail, use the -Full parameter. The
process owner and runtime will be added to the object in either case.
.PARAMETER Computername
This parameter has aliases of CN, Name and PSComputername
.PARAMETER Full
Write the full process object to the pipeline instead of the summary.
.EXAMPLE
PS C:\> Get-PSRemoteSession lon-dc1

ProcessID      : 7016
CreationDate   : 4/3/2014 1:25:32 PM
Runtime        : 23:36:38.0799372
Owner          : MYDOMAIN\Jeff
PSComputername : lon-dc1

ProcessID      : 4676
CreationDate   : 4/4/2014 12:23:41 PM
Runtime        : 00:38:28.9568735
Owner          : MYDOMAIN\Administrator
PSComputername : lon-dc1

.EXAMPLE
PS C:\> Get-PSRemoteSession lon-dc1 -full | select Owner,ProcessID,VM,WS,runtime

Owner     : MYDOMAIN\Jeff
ProcessID : 7016
VM        : 163262464
WS        : 44392448
Runtime   : 23:47:39.0140240

Owner     : MYDOMAIN\Administrator
ProcessID : 4676
VM        : 180445184
WS        : 46551040
Runtime   : 00:49:29.8899602

Get full process information and select some key properties
.EXAMPLE
PS C:\> get-remotesession chi-dc04,chi-dc01 | Group Owner -NoElement

Count Name                     
----- ----                     
    1 GLOBOMANTICS\jeff        
    2 GLOBOMANTICS\Administr...


Display what user accounts are using remote sessions on the specified computers.

.EXAMPLE
PS C:\> Get-Content c:\work\computers.txt | Get-PSRemoteSession | where {$_.Runtime -gt "16:00:00"}

For a list of computers, get remote PSSessions that have been running longer 
than 16 hours.

.EXAMPLE
PS C:\> get-remotesession chi-dc04,chi-dc01,chi-app01 | sort PSComputername | format-table -GroupBy PSComputername -Property CreationDate,Runtime,Owner


   PSComputerName: chi-app01

CreationDate                 Runtime                     Owner                      
------------                 -------                     -----                      
4/11/2014 9:58:16 AM         00:04:29.8719959            GLOBOMANTICS\Administrator 


   PSComputerName: chi-dc01

CreationDate                 Runtime                     Owner                      
------------                 -------                     -----                      
4/11/2014 9:46:24 AM         00:16:21.2699348            GLOBOMANTICS\Administrator 


   PSComputerName: chi-dc04

CreationDate                 Runtime                     Owner                      
------------                 -------                     -----                      
4/11/2014 9:43:06 AM         00:19:36.8797428            GLOBOMANTICS\jeff          
4/11/2014 9:47:25 AM         00:15:18.0563043            GLOBOMANTICS\Administrator 

.NOTES
Version       : 1.0
Last Updated  : April 11, 2014

Learn more:
 PowerShell in Depth: An Administrator's Guide (http://www.manning.com/jones2/)
 PowerShell Deep Dives (http://manning.com/hicks/)
 Learn PowerShell 3 in a Month of Lunches (http://manning.com/jones3/)
 Learn PowerShell Toolmaking in a Month of Lunches (http://manning.com/jones4/)
 

  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************
.LINK
Get-CimInstance
about_PSSessions
#>

[cmdletbinding()]
Param(
[Parameter(Position=0,
ValueFromPipeline=$True,
ValueFromPipelineByPropertyName=$True)]
[ValidateNotNullorEmpty()]
[Alias("CN","Name","PSComputername")]
[string[]]$Computername,
[switch]$Full
)

Begin {
    Write-Verbose "Starting Get-PSRemoteSession"
} #begin

Process {
foreach ($computer in $computername) {
    #test connection
    Write-Verbose "Testing if computer $computer is pingable"

    #do a single ping to verify computer is up
    If (Test-Connection -ComputerName $computer -count 1 -Quiet) {

        Write-Verbose "Querying $computer"
        Try {
            #use CIM to remotely query the computer
            $data = Get-CimInstance win32_process -filter "name='wsmprovhost.exe'" `
            -ComputerName $computer -ErrorAction Stop -ErrorVariable MyErr

            if ($data) {
                Write-verbose "Found sessions on $computer"
                Write-verbose ($data[0] | out-string)

                #add some custom properties
                $data | Add-Member -membertype ScriptProperty -Name Runtime -value {
                (Get-Date) - $this.creationdate} 
                $data | Add-Member -MemberType ScriptProperty -Name Owner -Value {
                $owner = $this | Invoke-CimMethod -MethodName GetOwner
                #write the owner information
                "$($owner.domain)\$($owner.user)"
                } 
                
                if ($Full) {
                    #write the full process object with additions to the pipeline
                    $data
                }
                else {
                    #get process summary
                    $data | Select ProcessID,CreationDate,RunTime,Owner,PSComputername  
                  }    

            } #if $data

         } #try

         Catch {
           Write-Warning "Could not query $computer"
           Write-Warning $myErr.ErrorRecord.Exception.Message
           Write-Debug "Suspend script to debug `$myErr exception"
         } #catch

     } #if test-connection works
     else {
       Write-Warning "Failed to ping $computer"
     }

} #foreach computer
} #process

End {
 Write-verbose "Ending Get-PSRemoteSession"
} #end

} #end function