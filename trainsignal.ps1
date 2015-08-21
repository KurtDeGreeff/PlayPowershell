#requires -version 3.0
 
<#
 a version of a demo from my PowerShell 3 course
 https://www.trainsignal.com/course/209/powershell-v3-essentials
 
 Do NOT run this in the PowerShell ISE as there is a memory bug
 with Invoke-WebRequest
#>
 
$base = "http://trainsignal.com"
$uri = "$base/Browse"
$r = Invoke-WebRequest $uri
 
<# 
look at links if you want
$r.links[0..5]
$r.links | select OuterText,href
#>
 
#let's get just courses
$courses = $r.links | where {$_.href -match "^/Course"} 
 
#format course data
$data = $courses |
Select @{Name="Title";Expression={$_.OuterText.Split("`n")[0].Trim()}},
@{Name="Instructor";Expression={$_.OuterText.Split("`n")[1].Trim()}},
@{Name="Date";Expression={$_.OuterText.Split("`n")[2].Trim() -as [datetime]}},
@{Name="Link";Expression={"$base$($_.href)"}} 
 
#send the data to Out-Gridview 
$data | 
Out-GridView -Title "Trainsignal Courses: select one or more courses" -PassThru |
Foreach { 
 #open selected links in the browser
 start $_.link
}
 
#end of script