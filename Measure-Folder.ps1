#requires -version 4.0

Function Measure-Folder {

<#
.SYNOPSIS
Measure the size of a folder.

.DESCRIPTION
This command will take a file path and create a custom measurement object that shows the number of files and the total size. The default size will be in bytes but you can specify a different unit of measurement. The command will format the result accordingly and dynamically change the property name as well.

.PARAMETER Path
The default is the current path. The command will fail if it is not a FileSystem path.

.PARAMETER Average
Get the average file size. This will be formatted with the same unit as the total size.

.PARAMETER NoRecurse
The default behavior is to recurse through all subfolders. But you can suppress that by using -NoRecurse.

.PARAMETER Unit
The default unit of measurement is bytes, but you can use any of the standard PowerShell numeric shortcuts: "KB","MB","GB","TB","PB"

.PARAMETER Round
The number of decimal points to round the sum and average values. The default is 2. Use a value of 10 to not round. The maximum value is 10.

.EXAMPLE
PS C:\> measure-folder c:\scripts 

Path            Name         Count         Size
----            ----         -----         ----
C:\scripts      scripts       2858     43800390

Measure the scripts folder using the default size of bytes.

.EXAMPLE

PS C:\> dir c:\scripts -Directory | measure-folder -Unit kb | Sort Size* -Descending | Select -first 5 | format-table -AutoSize

Path                     Name          Count          SizeKB
----                     ----          -----          ------
C:\scripts\GP            GP               40         2287.08
C:\scripts\Workflow      Workflow         64         1253.02
C:\scripts\modhelp       modhelp           1          386.49
C:\scripts\stuff         stuff             4          309.09
C:\scripts\ADTFM-Scripts ADTFM-Scripts    76          297.78

Get all the child folders under C:\scripts, measuring the size in KB. Sort the results on the size property in descending order. Then select the first 5 objects and format the results as a table.

.EXAMPLE
PS C:\> measure-folder $env:temp -Average -unit MB -round 10

Path   : C:\Users\Jeff\AppData\Local\Temp
Name   : Temp
Count  : 64626
SizeMB : 6769.94603252411
AvgMB  : 0.104755764437287

Measure all the %TEMP% folder, including a file average all formatted in MB with no rounding
.NOTES
Last Updated: July 22, 2015
Version     : 2.2

Originally published at http://jdhitsolutions.com/blog/scripting/3715/friday-fun-the-measure-of-a-folder/

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/


  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************
  

.LINK
Get-ChildItem
Measure-Object

.INPUTS
string or directory

.OUTPUTS
Custom object
#>
[cmdletbinding()]

Param(
[Parameter(Position=0,ValueFromPipeline=$True,
ValueFromPipelineByPropertyName=$True)]
[ValidateScript({
if (Test-Path $_) {
   $True
}
else {
   Throw "Cannot validate path $_"
}
})]
[Alias("fullname")]
[string]$Path = ".",
[switch]$NoRecurse,
[Alias("avg")]
[switch]$Average,
[ValidateSet("bytes","KB","MB","GB","TB","PB")]
[string]$Unit = "bytes",
[ValidateRange(0,10)]
[int]$Round = 2
)

Begin {
    Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"  

    #hash table of parameters to Splat to Get-ChildItem
    $dirHash = @{
     File = $True
     Recurse = $True
    }
    if ($NoRecurse) {
        Write-Verbose "No recurse"
        $dirHash.remove("recurse")
    }

    #hash table of parameters to splat to measure-Object
    $measureHash = @{
        Property = "length"
        Sum = $True
    }
    if ($Average) {
        Write-Verbose "Including Average"
        $measureHash.Add("Average",$True)
    }
    Write-Verbose "Rounding to $Round decimal points."
} #begin

Process {
    $Resolved = Resolve-Path -Path $path
    $Name = Split-Path -Path $Resolved -Leaf

    #verify we are in the file system
    if ($Resolved.Provider.Name -eq 'FileSystem') {

    #define a hash table to hold new object properties
    $propHash = [ordered]@{
      Path=$Resolved.Path
      Name=$Name
    }

    Write-Verbose "Measuring $resolved in $unit"

    $dirHash.Path = $Resolved

    $stats = Get-ChildItem @dirHash | Measure-Object @measureHash

    Write-Verbose "Measured $($stats.count) files"

    $propHash.Add("Count",$stats.count)
    $unitHash = @{
         Bytes = 1
         KB = 1KB
         MB = 1MB
         GB = 1GB
         TB = 1TB
         PB = 1PB
     }

     $value = [Math]::Round($stats.sum/$UnitHash.item($unit),$Round)

     $Label = "Size"
     if ($unit -ne 'bytes') {
        $label+= $($unit.ToUpper())
     }

    $propHash.Add($label,$value)
    #repeat process for Average
    if ($Average) {
        $value = [Math]::Round($stats.average/$UnitHash.item($unit),$Round)
         $Label = "Avg"
        if ($unit -ne 'bytes') {
            $label+= $($unit.ToUpper())
        }
        $propHash.Add($label,$value)
    } #if Average

    #write the new object to the pipeline
    New-Object -TypeName PSobject -Property $propHash

    }
    else {
        Write-Warning "You must specify a file system path."
    }

} #process

End {
    Write-Verbose -Message "Ending $($MyInvocation.Mycommand)"
} #end

} #end function