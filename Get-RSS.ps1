<#Listing 40.1 The Get-RSS function
Figure 40.2 An RSS feed from Invoke-RestMethod
652 CHAPTER 40 Working with the web#>
Function Get-RSS {
[cmdletbinding()]
Param (
[Parameter(Position=0,ValueFromPipeline=$True,

ValueFromPipelineByPropertyName=$True)]
[ValidateNotNullOrEmpty()]
[ValidatePattern("^http")]
[Alias('url')]
[string[]]$Path="http://powershell.org/wp/feed/"
)
Begin {
Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"
[regex]$rx="<(.|\n)+?>"
} #begin
Process {
foreach ($item in $path) {
$data = Invoke-RestMethod -Method GET -Uri $item
foreach ($entry in $data) {
#link tag might vary
if ( $entry.origLink) {
$link = $entry.origLink
}
elseif ($entry.Link) {
$link = $entry.link
}
else {
$link = "undetermined"
}
if ($entry.description -is [string]) {
$description =
$rx.Replace($entry.Description.Trim(),"").Trim()
}
elseif ($entry.description -is [System.Xml.XmlElement]) {
$description =
$rx.Replace($entry.Description.innerText,"").Trim()
}
else {
$description = $entry.description
}
[pscustomobject][ordered]@{
Title = $entry.title
Published = $entry.pubDate -as [datetime]
Description = $description
Link = $Link
} #hash
} #foreach entry
} #foreach item
} #process
End {
Write-Verbose -Message "Ending $($MyInvocation.Mycommand)"
} #end
} #end Get-RSS