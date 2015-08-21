Function Export-IniToXML {
<#
.Synopsis
Export a traditional INI file to XML
.Description
This command will convert a traditional INI file to XML and save to a file. Blank lines and comments starting with ; will be ignored.

An ini file like this:
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

Will be exported to an XML file like this:

<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Sections>
  <General>
    <Action>Start</Action>
    <Directory>c:\work</Directory>
    <ID>123ABC</ID>
  </General>
  <Application>
    <Name>foo.exe</Name>
    <Version>1.0</Version>
  </Application>
  <User>
    <Name>Jeff</Name>
    <Company>Globomantics</Company>
  </User>
</Sections>

IMPORTANT: Due to the nature of XML especially in regard to limitations in naming nodes, some ini settings might not be "exportable" to this format.
.Parameter Path
The filename and path to the INI file.
.Parameter ExportPath
The filename and path for the saved XML file.
.Example
PS C:\> export-initoxml c:\scripts\sample.ini c:\scripts\sample.xml

.Notes
Last Updated: June 5, 2015
Version     : 1.0

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/

  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************
#>


[cmdletbinding(SupportsShouldProcess)]
Param(
[Parameter(Position=0,Mandatory,HelpMessage="Enter the path to an INI file")]
[Alias("fullname","pspath")]
[ValidateScript({
if (Test-Path $_) {
   $True
}
else {
   Throw "Cannot validate path $_"
}
})]     
[string]$Path,

[Parameter(Position=1,Mandatory,HelpMessage = "Enter the filename and path for the XML file")]
[ValidateNotNullorEmpty()]
[ValidateScript({
$parent = Split-Path $_
if (Test-Path $parent) {
  $True
}
else {
  Throw "Cannot validate path $parent"
}
})]
[string]$ExportPath
)

Begin {
    Write-Verbose "Starting $($MyInvocation.Mycommand)"      
} #begin

Process {
    Write-Verbose "Getting content from $(Resolve-Path $path)"
    #strip out comments that start with ; and blank lines
    $all = Get-Content -Path $path | Where {$_ -notmatch "^(\s+)?;|^\s*$"}

    Write-Verbose "Creating XML document"
    $xml = New-Object System.Xml.XmlDocument

    #create an XML declaration section
    $declare = $xml.CreateXmlDeclaration("1.0","UTF-8","yes")

    $xml.AppendChild($declare) | Out-Null

    #create section node
    $sectionNode = $xml.CreateNode("element","Sections","")
    $xml.AppendChild($sectionNode) | Out-Null

    foreach ($line in $all) {

        Write-Verbose "Processing $line"

        if ($line -match "^\[.*\]$") {
            #get section name
            $sectionName = $line -replace "\[|\]",""
            #create XML node
            $section = $xml.CreateNode("element",$sectionName,"") 
            #append node to document
            $sectionNode.AppendChild($section) | Out-Null
        }
        elseif ($line -match "=") {
            #parse data
            $data = $line.split("=").trim()
            #create child node
            $setting = $xml.CreateNode("element",$data[0],"") 
            #set value as inner text
            $setting.InnerText = $data[1] 
            #append node
            $section.AppendChild($setting)  | Out-Null
        }
        else {
            #this should probably never happen
            Write-Warning "Unexpected line $line"
        }
    } #foreach

   #Save the file to a resolved path.
   $ExportDir = (Split-Path -Path $ExportPath -Parent | Resolve-Path).Path
   $ExportFile = Split-Path -Path $ExportPath -Leaf
   Write-verbose $ExportFile
   Write-Verbose $ExportDir
   $saveTo = Join-Path -path $ExportDir -ChildPath $ExportFile

   #code to support -WhatIf since the Save() method doesn't know how
   if ($PSCmdlet.ShouldProcess($Path,"Export as XML to $SaveTo")) {
    $xml.Save($saveTo)
    Write-Verbose "File saved to $SaveTo"
   } #WhatIf

} #process

End {
    Write-Verbose "Ending $($MyInvocation.Mycommand)"
} #end

} #end function