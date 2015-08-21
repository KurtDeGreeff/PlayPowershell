#requires -version 3.0

Function Out-HTMLReport {
<#
.SYNOPSIS
Send the output of a command to an HTML report.

.DESCRIPTION
Send output from a PowerShell expression to this command and create a formatted HTML report. For best results you should specify the properties to display or use Select-Object earlier in your expression. You can also group results by a property name.

.PARAMETER InputObject 
The output from some PowerShell expression.
.PARAMETER Path 
The filename and path for the HTML file.
.PARAMETER PreContent 
Content to be used at the beginning of your HTML document. This can include HTML tags.
.PARAMETER CssUri 
The path to a CSS file. See examples for how to embed a style sheet in the document.
.PARAMETER As 
Data will be formatted as fragments. It can be either a Table (default) or a List. All data will be formatted the same.
.PARAMETER Group 
The property to group data on. If you specify a grouping property, this property will not be displayed in the table or list output.
.PARAMETER Properties 
The properties to display in the report. The default will be all properties.
.PARAMETER Title 
The title for your HTML report.
.PARAMETER Head 
Content to use for the Head section of the HTML document.
.PARAMETER PostContent 
Content to be used at the end of your HTML document. This can include HTML tags.

.EXAMPLE
PS C:\> get-service | out-htmlreport c:\work\services.htm -properties Name,Displayname,Status

Create a very basic HTML report of service information with no formatting.
.EXAMPLE
PS C:\> get-process | Where Company | Out-HTMLReport -Path c:\work\procs.htm -Properties name,id,ws,vm,pm,path -title "Process Report by Company" -group Company -CssUri C:\scripts\blue.css

Get all processes where a Company property is defined and create an HTML report grouping on the company property. Selected properties for each object will be displayed as a table. This example is using an external CSS file.
.EXAMPLE
PS C:> dir -file | select Fullname,Name,@{Name="Size";Expression={$_.length}},CreationTime,LastWriteTime,@{Name="Age";Expression={(Get-Date) - $_.LastWriteTime}},Attributes,Extension | out-htmlreport c:\work\files.htm -Group extension -as List -title "File Report" -CssUri c:\scripts\blue.css

If you want to use custom properties, define them before sending to Out-HTMLReport. If you will be grouping be sure to include the grouping property.
.EXAMPLE
PS C:\> $data = Get-HotFix

Get hotfix data from the local computer.

PS C:\> $head = @"
<Title>Hot Fix Report</Title>
<style>
body { background-color:#FFFFFF;
       font-family:Tahoma;
       font-size:12pt; }
td, th { border:1px solid black; 
         border-collapse:collapse; }
th { color:white;
     background-color:black; }
table, tr, td, th { padding: 2px; margin: 0px }
tr:nth-child(odd) {background-color: lightgray}
table { width:95%;margin-left:5px; margin-bottom:20px;}
</style>
<br>
<H1>Hot Fix Report</H1>
"@

Define a here string for the HTML head. This includes an embedded style sheet.

PS C:\> $paramHash = @{
 Head = $head
 Title = "Hot Fix Report"
 Path = "c:\work\hotfix.htm"
 Group = "Description"
 As = "List"
 PostContent = "<H6>$(Get-Date)</H6>"
 Properties = "HotFixID","InstalledOn","InstalledBy","Caption","PSComputername"
}

Define a hash table of parameter values to splat to Out-HTMLReport

PS C:\> $data | Out-HTMLReport @paramHash

Create the report.
.NOTES
Version     : 1.0
Last Update : February 27, 2015
Author      : Jeff Hicks (@jeffhicks)

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/

  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************

.INPUTS
[object[]]
.OUTPUTS
none
.LINK
ConvertTo-HTML
#>

[cmdletbinding(SupportsShouldProcess=$True)]

Param (
[Parameter(Position=0,Mandatory,HelpMessage = "Enter the name of the report to create")]
[ValidateNotNullorEmpty()]
[string]$Path, 
[string]$Group, 
[ValidateNotNullorEmpty()]
[string[]]$Properties="*", 
[string]$CssUri, 
[ValidateSet("Table","List")]
[ValidateNotNullorEmpty()]
[string]$As = "Table", 
[string]$Title, 
[string]$Head, 
[string[]]$PreContent,
[string[]]$PostContent,
[Parameter(Position=1,Mandatory,ValueFromPipeline,
HelpMessage="Enter objects to format")]
[ValidateNotNullorEmpty()]
[object[]]$InputObject

)

Begin {
    Write-Verbose "Starting $($myinvocation.mycommand)"
    #copy most of the bound parameters since they will
    #be passed to Convertto-HTML
    Write-verbose "PSBoundParameters"
    write-Verbose ($PSBoundParameters | out-string)
        
    #initialize an array to hold all the processed data
    $data=@()

    #iniatilize a variable for the HTML body
    [string[]]$body=@()
    $body+=$PreContent
} #begin

Process {
    #add each input object to $data
    foreach ($item in $Inputobject) {
        $data+=$item
    }
} #process

End {
    Write-Verbose "Processing $($data.count) objects"

    #sort on grouping property if used
    if ($Group) {
        Write-Verbose "Grouping on $Group"
         $data | Group-Object -Property $Group |
         Sort-Object -Property Name |
         foreach {
            $body+="<H2>$($_.Name)</H2>"
            $body+= $_.Group | 
            Select-Object -property $Properties -ExcludeProperty $Group |
            ConvertTo-HTML -As $As -Fragment
         } #foreach
    }
    else {
        Write-Verbose "No grouping"
        $body+= $data | 
            Select-Object -property $Properties | 
            ConvertTo-HTML -As $As -Fragment
    }

    #create the HTML
    $htmlParams = $PSBoundParameters
    #remove conflicting or unused parameters
    "InputObject","Path","Group","Properties",
    "PreContent","WhatIf","Confirm" | 
    foreach {
        $htmlparams.Remove($_) | out-null
    }

    #add body
    $htmlParams.Add("Body",$body)

    Write-Verbose "Using these Convertto-HTML parameters"
    Write-Verbose ($htmlParams | out-string)

    #create the HTML
    $html = ConvertTo-HTML @htmlParams

    #create the file
    $html | Out-File -filepath $Path -encoding ASCII

    Write-Verbose "Report created at $path"
    Write-Verbose "Ending $($myinvocation.mycommand)"
} #end
 
} #end Out-Report function

#optional: define an alias
Set-Alias -Name ohr -Value Out-HTMLReport