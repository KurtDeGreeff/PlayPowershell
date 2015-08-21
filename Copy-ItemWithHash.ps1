#requires -version 4.0

Function Copy-ItemWithHash {

 <#
 .Synopsis
Copy file with hash
 .Description
This is a proxy function to Copy-Item that will include hashes for the original file and copy. New properties will be added to the copied file, OriginalHash and CopyHash. The default hashing algorithm is MD5.
 .Notes
 Last Updated:	1/8/2015
 
 .Example
 PS C:\> dir *.zip | copy-itemwithhash -Destination E:\BackupDemo -PassThru -ov o
 VERBOSE: Processing C:\Scripts\5000names.zip
VERBOSE: Performing the operation "Copy File" on target "Item: C:\Scripts\5000names.zip Destination: E:\BackupDemo\5000n
ames.zip".
Copy-ItemwithHash : File hash mismatch between C:\Scripts\5000names.zip and E:\BackupDemo\5000names.zip
At line:1 char:13
+ dir *.zip | Copy-ItemwithHash -Destination E:\BackupDemo -Verbose -PassThru -ov o
+             ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidResult: (C:\Scripts\5000names.zip:String) [Write-Error], Hash mismatch
    + FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException,Copy-ItemWithHash
VERBOSE: Processing C:\Scripts\add-note.zip
VERBOSE: Performing the operation "Copy File" on target "Item: C:\Scripts\add-note.zip Destination: E:\BackupDemo\add-no
te.zip".

    Directory: E:\BackupDemo


Mode                LastWriteTime     Length Name
----                -------------     ------ ----
-a---         2/24/2010  10:22 AM       2178 add-note.zip
VERBOSE: Processing C:\Scripts\ADSIServiceScripts.zip
VERBOSE: Performing the operation "Copy File" on target "Item: C:\Scripts\ADSIServiceScripts.zip Destination: E:\BackupD
emo\ADSIServiceScripts.zip".
Copy-ItemwithHash : File hash mismatch between C:\Scripts\ADSIServiceScripts.zip and E:\BackupDemo\ADSIServiceScripts.zip
At line:1 char:13
+ dir *.zip | Copy-ItemwithHash -Destination E:\BackupDemo -Verbose -PassThru -ov o
+             ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidResult: (C:\Scripts\ADSIServiceScripts.zip:String) [Write-Error], Hash mismatch
    + FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException,Copy-ItemWithHash
    ...

 PS C:\> $o | where {$_.originalhash -ne $_.copyhash} 

   Directory: E:\BackupDemo


Mode                LastWriteTime     Length Name
----                -------------     ------ ----
-a---          1/2/2012   4:22 PM       3492 ch33-new-report.zip
-a---          6/2/2010   9:55 AM       1211 CreateNames.zip
-a---          8/5/2008   1:08 PM     124883 Demo-Database.zip
-a---          5/7/2009  10:04 AM      11402 Display-LocalGroupMember.zip
-a---         1/20/2010   1:22 PM       2347 DomainControllerFunctions.zip
-a---          5/7/2010   4:27 PM       3398 Get-Certificate-v2.zip
...

The first command attempts to copy files but there are hash errors. The second command uses saved output to identify files that failed.
 .Link
 Copy-Item
 Get-Filehash
 #>

[CmdletBinding(DefaultParameterSetName='Path', SupportsShouldProcess=$true, ConfirmImpact='Medium', SupportsTransactions=$true)]
 param(
     [Parameter(ParameterSetName='Path', Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
     [string[]]$Path, 
     [Parameter(ParameterSetName='LiteralPath', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
     [Alias('PSPath')]
     [string[]]$LiteralPath, 
     [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
     [string]$Destination,
     [switch]$Container, 
     [switch]$Force, 
     [string]$Filter, 
     [string[]]$Include, 
     [string[]]$Exclude, 
     [switch]$Recurse, 
     [switch]$PassThru = $True, 
     [Parameter(ValueFromPipelineByPropertyName=$true)]
     [pscredential][System.Management.Automation.CredentialAttribute()]$Credential,
     [ValidateSet("SHA1","SHA256","SHA384","SHA512","MACTripleDES","MD5","RIPEMD160")]
     [string]$Algorithm = "MD5"
  ) 
 begin {
     try {
         $outBuffer = $null
         if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
         {
             $PSBoundParameters['OutBuffer'] = 1
         }         
         #remove added parameter
         $PSBoundParameters.Remove("Algorithm") | Out-Null

         #define a scope specific variable
         $script:hash = $Algorithm
         Write-Verbose "Hashing using $script:hash"

         $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Copy-Item', [System.Management.Automation.CommandTypes]::Cmdlet)
         $scriptCmd = {
         &$wrappedCmd @PSBoundParameters | foreach {
        
         $_ | Add-member -MemberType NoteProperty -Name "OriginalHash" -value $pv.originalhash
         $_ | Add-member -MemberType ScriptProperty -Name "CopyHash" -value {
         #this is the correct value
         ($this | get-filehash -algorithm $script:hash).hash

         <#introduce a random failure for demonstration purposes
            $h = ($this | Get-FileHash -Algorithm $script:hash).hash
            $r = Get-Random -Minimum 0 -Maximum 2
            $h.substring($r)
         #######################################################
         #>

         } #CopyHash value

         Try {
             $file = $_
             if ($file.originalHash -eq $file.copyhash) {
               $file
              }
             else {
                Throw 
              }
          } #try
          Catch {     
            Write-Error -RecommendedAction "Repeat File Copy" -Message "File hash mismatch between $($pv.fullname) and $($file.fullname)" -TargetObject $pv.fullname -Category "InvalidResult" -CategoryActivity "File Copy" -CategoryReason "Hash mismatch"
          }
         } #foreach
         } #scriptcmd

         $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
         $steppablePipeline.Begin($PSCmdlet)
     } catch {
         throw
     }
 }
 process {
     try {
     write-Verbose "Processing $_"
         #get the item and add a property for the hash
         $_ | Get-item | Add-member -MemberType ScriptProperty -Name "OriginalHash" -value {($this | Get-FileHash -Algorithm $script:hash).hash} -PassThru -PipelineVariable pv |
         foreach {
           $steppablePipeline.Process($psitem) 
         }
     } catch {
         throw
     }
 }
 
end {
     try {
         $steppablePipeline.End()
     } catch {
         throw
     }
 }

} #end function Copy-ItemWithHash

#define an optional alias
Set-Alias -name ch -value Copy-ItemWithHash