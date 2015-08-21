# http://jdhitsolutions.com/blog/2013/05/friday-fun-view-objects-in-a-powershell-gridlist/?utm_source=feedburner&utm_medium=feed&utm_campaign=Feed%3A+JeffsScriptingBlogAndMore+%28The+Lonely+Administrator%29#utm_source=feed&utm_medium=feed&utm_campaign=feed?utm_source=rss&utm_medium=rss&utm_campaign=friday-fun-view-objects-in-a-powershell-gridlist

Function Out-GridList {
[cmdletbinding()]
 
Param(
[Parameter(Position=0,Mandatory,ValueFromPipeline)]
[object]$InputObject,
[string]$Title="Out-GridList",
[switch]$Passthru
)
 
Begin {
  #initialize data array
  $data=@()
}
Process {
#initialize a hashtable for properties
$propHash = @{}
#get property names from the first object in the array
$properties = $InputObject | Get-Member -MemberType Properties
 
$properties.name | foreach {
Write-Verbose "Adding $_"
  $propHash.add($_,$InputObject.$_)
  
} #foreach
 
  $data +=$propHash
 
} #Process
 
End {
 
#tweak hashtable output
$data.GetEnumerator().GetEnumerator() | 
select @{Name="Property";Expression={$_.name}},Value |
Out-GridView -Title $Title -PassThru:$Passthru
}
 
} #end Out-Gridlist