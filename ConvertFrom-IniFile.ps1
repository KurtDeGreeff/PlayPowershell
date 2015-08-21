Function ConvertFrom-IniFile {

<#
.Synopsis
Convert an INI file to an object
.Description
Use this command to convert a legacy INI file into a PowerShell custom object. Each INI section will become a property name. Then each section setting will become a nested object. Blank lines and comments starting with ; will be ignored. 

It is assumed that your ini file follows a typical layout like this:

;This is a sample ini
[General]
Action = Start
Directory = c:\work
ID = 123ABC

 ;this is another comment
[Application]
Name = foo.exe
Version = 1.0

[User]
Name = Jeff
Company = Globomantics

.Parameter Path
The path to the INI file.
.Example
PS C:\> $sample = ConvertFrom-IniFile c:\scripts\sample.ini
PS C:\> $sample

General                           Application                      User                            
-------                           -----------                      ----                            
@{Directory=c:\work; ID=123ABC... @{Version=1.0; Name=foo.exe}     @{Name=Jeff; Company=Globoman...

PS C:\> $sample.general.action
Start

In this example, a sample ini file is converted to an object with each section a separate property.
.Example
PS C:\> ConvertFrom-IniFile c:\windows\system.ini | export-clixml c:\work\system.ini

Convert the System.ini file and export results to an XML format.
.Notes
Last Updated: June 5, 2015
Version     : 1.0

https://www.petri.com/managing-ini-files-with-powershell

.Link
Get-Content
.Inputs
[string]
.Outputs
[pscustomobject]
#>

[cmdletbinding()]
Param(
[Parameter(Position=0,Mandatory,HelpMessage="Enter the path to an INI file",
ValueFromPipeline, ValueFromPipelineByPropertyName)]
[Alias("fullname","pspath")]
[ValidateScript({
if (Test-Path $_) {
   $True
}
else {
  Throw "Cannot validate path $_"
}
})]     
[string]$Path
)


Begin {
    Write-Verbose "Starting $($MyInvocation.Mycommand)"  
} #begin

Process {
    Write-Verbose "Getting content from $(Resolve-Path $path)"
    #strip out comments that start with ; and blank lines
    $all = Get-content -Path $path | Where {$_ -notmatch "^(\s+)?;|^\s*$"}

    $obj = New-Object -TypeName PSObject -Property @{}
    $hash = [ordered]@{}

    foreach ($line in $all) {

        Write-Verbose "Processing $line"

        if ($line -match "^\[.*\]$" -AND $hash.count -gt 0) {
            #has a hash count and is the next setting
            #add the section as a property
            write-Verbose "Creating section $section"
            Write-verbose ([pscustomobject]$hash | out-string)
            $obj | Add-Member -MemberType Noteproperty -Name $Section -Value $([pscustomobject]$Hash) -Force
            #reset hash
            Write-Verbose "Resetting hashtable"
            $hash=[ordered]@{}
            #define the next section
            $section = $line -replace "\[|\]",""
            Write-Verbose "Next section $section"
        }
        elseif ($line -match "^\[.*\]$") {
            #Get section name. This will only run for the first section heading
            $section = $line -replace "\[|\]",""
            Write-Verbose "New section $section"
        }
        elseif ($line -match "=") {
            #parse data
            $data = $line.split("=").trim()
            $hash.add($data[0],$data[1])    
        }
        else {
            #this should probably never happen
            Write-Warning "Unexpected line $line"
        }

    } #foreach

    #get last section
    If ($hash.count -gt 0) {
      Write-Verbose "Creating final section $section"
      Write-Verbose ([pscustomobject]$hash | Out-String)
     #add the section as a property
     $obj | Add-Member -MemberType Noteproperty -Name $Section -Value $([pscustomobject]$Hash) -Force
    }

    #write the result to the pipeline
    $obj
} #process

End {
    Write-Verbose "Ending $($MyInvocation.Mycommand)"
} #end

} #end function