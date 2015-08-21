#requires -version 3.0

Function Get-FileData {
<#
.Synopsis
Get file aging and owner data
.Description
This command will get file aging information, including the number of days
since the file was created and last modified. It will also return the owner
of the file.

Name            : FixMe.ps1
FullName        : C:\scripts\FixMe.ps1
Size            : 482
CreationTime    : 8/15/2012 11:12:46 PM
LastWriteTime   : 8/3/2011 12:12:15 PM
CreationAge     : 173
ModificationAge : 551
Owner           : Serenity\Jeff
IsExecutable    : True

.Parameter Path
The folder path to analyze. The default is the current directory.
.Parameter Extensions
An array of file extensions to be considered "Executable". 
.Parameter Recurse
Include all subfolders in the analysis.
.Example
PS C:\> Get-FileData C:\Work

Get file information from C:\Work but don't check any subfolders.
.Example
PS C:\> Get-FileData R:\Files -recurse | Export-CSV T:\FileReport.csv

Process R:\files recursively and export data to a csv file.
.Notes
  version 2.0

  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************

.Link
    Get-Childitem
Measure-Object
    .Inputs
Strings
.Outputs
    Custom object
#>

[cmdletbinding()]

Param(
[Parameter(Position=0)]
[ValidateScript({Test-Path -Path $_})]
[string]$Path = ".",
[ValidateNotNullorEmpty()]
[string[]]$Extensions = @(".ps1",".psm1",".bat",".vbs",".wsf",".cmd",".exe",".com"),
[switch]$Recurse
)

Set-StrictMode -Version Latest

Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"

#region Setup variables

#define a hash table of parameters for Get-ChildItem
$paramhash=@{Path=$Path;File=$True;ErrorAction='Stop'}

if ($Recurse) {
    <#
     add the -Recurse parameter to the hash table if 
     passed as a function parameter
    #>
    $paramhash.Add("Recurse",$True)
} #if $recurse

#view the contents of the parameter hash table
Write-Verbose -Message ($paramhash | Out-String)

#endregion

#region get file data

Try {
    Write-Verbose -Message "Analyzing $Path"
    #splat the hash table of parameter values to Get-ChildItem
    $files = Get-ChildItem @paramhash
    #measure the total number of files found
    $count = $files | Measure-Object | Select-Object -ExpandProperty Count

    #only process if files were found.
    if ($files) {
        #define a counter
        $i=0
        foreach ($file in $files) {
            #increment the counter by 1
            $i++

            #calculate a percent complete from the total number of files
            $percentComplete = ($i/$count)*100 

            <#
              display a progress bar. The Write-Progress
              command is using the backtick to break
              the command so it is easier to read here
            #>
            Write-Progress -Activity "File Data" `
            -Status "Processing $($file.Directory)" `
            -CurrentOperation $File.Name `
            -PercentComplete $PercentComplete
    
            <#
              pipe a file to Select-Object and get a few key properties,
              plus define some new ones using custom hash tables
            #>
             $file | Select-Object -Property Name,Fullname,
                @{Name="Size";Expression={$_.length}},
                CreationTime,LastWriteTime,
                @{Name="CreationAge";Expression={
                <#
                 Get a timespan object for the current date minus the creation time
                 and then take the TotalDays property, treated as an integer.
                #>
                ((Get-Date)-$_.CreationTime).TotalDays -as [int]}},
                @{Name="ModificationAge";Expression={
                #Do the same thing with the LastWriteTime property
                ((Get-Date)-$_.LastWriteTime).TotalDays -as [int]}},
                @{Name="Owner";Expression={
                #Get the ACL of the file and then retrieve the Owner property
                (Get-Acl -path $_.fullName ).Owner }},
                @{Name="IsExecutable";Expression={ 
                <#
                 determine if the file is considered an executable based on 
                 its extension.
                #>
                if ($Extensions -contains $_.extension) { 
                  $True
                } 
                else {
                   $False
                }
                }}
        } #foreach
     } #if $files
} #Try

Catch {
    Write-Warning -Message ("Failed to retrieve files from {0}. {1}" -f $Path,$_.Exception.Message)
} #catch

#endregion

#region Exit function

Finally {
    Write-Verbose -Message "Ending $($MyInvocation.Mycommand)"
} #finally

#endregion

} #end function Get-FileData

# Get-Filedata c:\work | out-gridview -title "My Files"