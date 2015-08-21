#requires -version 2.0

# -----------------------------------------------------------------------------
# Script: Get-FileHash.ps1
# Version: 1.0
# Author: Jeffery Hicks
#    http://jdhitsolutions.com/blog
#    http://twitter.com/JeffHicks
# Date: 3/31/2011
# Keywords: MD5, SHA1, Checksum
# Comments:
#
# "Those who forget to script are doomed to repeat their work."
#
#  ****************************************************************
#  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
#  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
#  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
#  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
#  ****************************************************************
# -----------------------------------------------------------------------------

Function Get-FileHash {

<#
.SYNOPSIS
Calculate file hash or checksum.

.DESCRIPTION
This command will compute a checksum or filehash for one or more files. The default hashing
algorithm is MD5 but you can also specify SHA1 or SHA256. The command will write a custom
object to the pipeline like this:

Date     : 3/30/2011 2:31:42 PM
FullName : C:\scripts\get-filehash.ps1
FileHash : 26B527B37717E2F1A85BD91EF40BCBBE
HashType : MD5
Filename : get-filehash.ps1
Size     : 9244

NOTE: You must have permissions to read the file. This will work with system and read-only
files but not with hidden files unless you use -FORCE.
.PARAMETER PSPath
The filename and path of the file to compute. This has aliases of name,file, and path.

.PARAMETER Type
The hashing algorithm. The default is MD5. Other options are SHA1 and SHA256.

.PARAMETER Force
Process hidden files.

.EXAMPLE
PS C:\> Get-Filehash $profile
Date     : 3/30/2011 2:29:09 PM
FullName : C:\Users\Jeff\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1
FileHash : C68E7BC1755A59EABB0C4BFC12A98C0B
HashType : MD5
Filename : Microsoft.PowerShellISE_profile.ps1
Size     : 2760

Return the file hash of the PowerShell profile script.
.EXAMPLE
PS C:\> dir c:\scripts\ -recurse -include *.ps*,*.vbs,*.bat | Get-Filehash | Export-CLIXML E:\ScriptsHash.xml
Get file hashes for all scripts and export to an XML file.

.NOTES
NAME        :  Get-FileHash
VERSION     :  1.0 
LAST UPDATED:  3/30/2011
AUTHOR      :  Jeffery Hicks

Learn more with a copy of Windows PowerShell 2.0: TFM (SAPIEN Press 2010)

.LINK
http://jdhitsolutions.com/blog/2011/03/get-file-hash/
.LINK
Get-Item 

.INPUTS
Strings for filenames and paths.

.OUTPUTS
Custom object
#>

[cmdletbinding(SupportsShouldProcess=$True,ConfirmImpact="Low")]

Param (
  [Parameter(Position=0,Mandatory=$True,HelpMessage="Enter file name and path.",
  ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
  [ValidateNotNullorEmpty()]
  [Alias("name","file","path")]
  [string[]]$PSPath,
  [Parameter(Position=1,Mandatory=$False)]
  [Alias("hash")]
  [ValidateSet("MD5","SHA1","SHA256")]
  [string]$Type = "MD5",
  [switch]$Force
)

Begin 
{
    #what time are we starting?
    $cmdStart=Get-Date
    Write-Verbose "$(Get-Date) Starting $($myinvocation.mycommand)"
    
    if ($force)
    {
        Write-Verbose "$(Get-Date) Using -Force to find hidden files"
    }
    #create the hash provider
    Switch ($Type) {
    "sha1"  {
                $provider = New-Object System.Security.Cryptography.SHA1CryptoServiceProvider
            }
    "sha256"  {
                $provider = New-Object System.Security.Cryptography.SHA256CryptoServiceProvider
            }
    "md5"   {
                $provider = New-Object System.Security.Cryptography.MD5CryptoServiceProvider
            }
     }
   Write-Verbose "$(Get-Date) Calculating $type hash"
} #begin

Process
{
    Foreach ($name in $PSPath) {
        Write-Verbose "$(Get-Date) Verifying $name"
        
        #verify file exists
        if (Test-Path -Path $name)
        {
            Write-Verbose "$(Get-Date) Path verified"
            
            Try
            {
                #get the file item
                if ($force)
                {
                    $file=Get-Item -Path $name -force -ErrorAction "Stop"
                }
                else
                {
                   $file=Get-Item -Path $name -ErrorAction "Stop"
                }
            }
            
            Catch
            {
                Write-Warning "Cannot get item $name. Verify it is not a hidden file (did you use -Force?) and that you have correct permissions."
            }
            
            #only process if we were able to get the item
            if ($file)
            {
                #only process if file size is greater than 0 
                #this will also fail if the object is not from the 
                #filesystem provider
                if ($file.length -gt 0)
                {
                    Write-Verbose "$(Get-Date) Opening file stream"
                    if ($pscmdlet.ShouldProcess($file.fullname))
                    {
                      Try
                      {
                        $inStream = $file.OpenRead()
                        Write-Verbose "$(Get-Date) Computing hash"
                        $start=Get-Date
                        $hashBytes = $provider.ComputeHash($inStream)
                        $end=Get-Date
                        Write-Verbose "$(Get-Date) hash computed in $(($end-$start).ToString())"
                        Write-Verbose "$(Get-Date) Closing file stream"
                        $inStream.Close() | Out-Null
                   
                        #define a hash string variable
                        $hashString=""
                        Write-Verbose "$(Get-Date) hashing file bytes"
                        
                        foreach ($byte in $hashBytes)
                        {
                            #calculate the hash
                            $hashString+=$byte.ToString("X2")
                        }
                          
                          #write the hash object to the pipeline
                          New-Object -TypeName PSObject -Property @{
                            Filename=$file.name
                            FullName=$file.Fullname
                            FileHash=$hashString
                            HashType=$Type
                            Size=$file.length
                            Date=Get-Date
                          }
                       } #try
                       Catch
                       {
                          Write-Warning "Failed to get file contents for $($file.name)."
                          Write-Warning $_.Exception.Message
                       }                
                     } #should process 
                    } #if $file.length
                    else
                     {
                        Write-Warning "$(Get-Date) File size for $name is 0 or is not from the filesystem provider."
                     }
             }#if $file
        } #if Test-Path
        else
        {
            Write-Warning "$(Get-Date) Failed to find $name."
        }
    
    } #foreach $file
  
} #process

End
{
    Write-Verbose "$(Get-Date) Ending $($myinvocation.mycommand)"
    #what time did we finish?
    $cmdEnd=Get-Date
    Write-Verbose "$(Get-Date) Total processing time $(($cmdEnd-$cmdStart).ToString())"
}

} #end function 

